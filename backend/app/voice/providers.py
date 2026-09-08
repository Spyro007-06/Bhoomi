"""Provider seam — Sarvam STT/TTS/Translator behind stub and live implementations.

OWNER: Shruthi. Spec: docs/DESIGN.md §8, §12, docs/API_CONTRACT.md §4.

`settings.asr_provider` ("stub" | "live") governs all three providers together:
stub means no Sarvam call anywhere in the voice pipeline, live means all three
call Sarvam. `asr.py`, `tts.py` and `embedding_text.py` call through the
factories below rather than instantiating a provider directly, so S3 swaps the
Live* bodies for real Sarvam calls without touching any caller.

The stub implementations are loud on purpose, mirroring vision/classifier.py's
own stub convention (docs/DESIGN.md §12): fixed, deterministic output that
never reads its input, `is_stub=True` on every result, and a warning logged on
every call.
"""

from __future__ import annotations

import base64
import logging
from dataclasses import dataclass
from typing import Protocol

import httpx
from sqlalchemy.ext.asyncio import AsyncSession

from app.config import (
    ASR_FLOOR,
    SARVAM_STT_MODEL,
    SARVAM_TRANSLATE_MODE,
    SARVAM_TRANSLATE_MODEL,
    SARVAM_TTS_MODEL,
    settings,
)
from app.contracts.enums import AssetKind, Lang
from app.core.services.assets import get_asset_bytes, store_bytes
from app.errors import BhoomiError, ErrorCode, NotFound

log = logging.getLogger("bhoomi.voice")

# ---------------------------------------------------------------------------
# Result shapes. Internal only — no frozen wire contract exists for voice yet
# (docs/API_CONTRACT.md §4 is prose, not a type in contracts/), so these are
# plain frozen dataclasses, not pydantic models: they never leave this process
# in this phase and shouldn't be mistaken for a team-reviewed C-contract.
# ---------------------------------------------------------------------------


@dataclass(frozen=True, slots=True)
class ParsedIntent:
    field: str
    value: str


@dataclass(frozen=True, slots=True)
class TranscriptResult:
    text: str
    confidence: float | None
    """None means "the provider does not report one" (live Saaras never does),
    not "we forgot to check" — never a fabricated sentinel. asr.transcribe()
    falls back to a transcript-quality heuristic instead of an ASR_FLOOR
    comparison when this is None. docs/API_CONTRACT.md §4 shows `confidence`
    as always-numeric; that is a deliberate deviation in live mode, flagged
    for the doc to catch up, not silently done."""
    lang: str
    parsed_intent: ParsedIntent | None
    needs_confirmation: bool
    is_stub: bool


@dataclass(frozen=True, slots=True)
class SynthesisResult:
    audio_url: str
    expires_in: int
    is_stub: bool


@dataclass(frozen=True, slots=True)
class TranslationResult:
    text: str
    is_stub: bool


# ---------------------------------------------------------------------------
# Protocols. S3 implements the Live* bodies against these; nothing else in the
# codebase changes when it does.
# ---------------------------------------------------------------------------


class SpeechToText(Protocol):
    async def transcribe(
        self, session: AsyncSession, asset_id: str, lang: str, context: str
    ) -> TranscriptResult: ...


class TextToSpeech(Protocol):
    async def synthesize(self, session: AsyncSession, text: str, lang: str) -> SynthesisResult: ...


class Translator(Protocol):
    def translate(self, text: str, source_lang: str) -> TranslationResult: ...


# ---------------------------------------------------------------------------
# Stubs. Fixed, deterministic, never read their input. docs/DESIGN.md §12.
# ---------------------------------------------------------------------------

_STUB_TRANSCRIPT_TEXT = "[stub transcript — ASR not implemented, provider=stub]"
_STUB_AUDIO_URL = "stub://voice-tts/not-implemented"


class StubSpeechToText:
    """Fixed low-confidence transcript. Never reads the audio asset.

    Confidence is derived from `ASR_FLOOR` (not an independent literal), so it
    stays below the floor by construction even if the floor is retuned — the
    ASR_FLOOR re-prompt path (docs/API_CONTRACT.md §4) is always exercisable
    without a key or network.

    `needs_confirmation` here is a placeholder (False); `asr.transcribe()` is
    the sole authority on that field and recomputes it from whether
    `parsed_intent` survives the floor gate.

    Takes `session` only to satisfy the `SpeechToText` protocol shared with
    `LiveSpeechToText` — never touches it, never awaits anything real. A
    caller may pass anything here, including `None`.
    """

    async def transcribe(
        self, session: AsyncSession, asset_id: str, lang: str, context: str
    ) -> TranscriptResult:
        log.warning(
            "voice.transcribe() served by STUB — fixed transcript, audio not "
            "read. is_stub=true. docs/DESIGN.md §12."
        )
        return TranscriptResult(
            text=_STUB_TRANSCRIPT_TEXT,
            confidence=ASR_FLOOR * 0.5,
            lang=lang,
            # "tillering" is a stage_key, not an enum member (v3: growth stages
            # are rows in the growth_stage table, contracts/farm.py). It's the
            # paddy value the v2 GrowthStage enum used to carry here, fixed and
            # deterministic like the rest of this stub -- not read from a crop,
            # since the stub never sees one.
            parsed_intent=ParsedIntent(field="growth_stage", value="tillering"),
            needs_confirmation=False,
            is_stub=True,
        )


class StubTextToSpeech:
    """Fixed placeholder audio URL. Never reads or renders `text`.

    Takes `session` only to satisfy the `TextToSpeech` protocol shared with
    `LiveTextToSpeech` — never touches it, never writes to storage. A caller
    may pass anything here, including `None`.
    """

    async def synthesize(self, session: AsyncSession, text: str, lang: str) -> SynthesisResult:
        log.warning(
            "voice.synthesize() served by STUB — fixed audio_url, text not "
            "rendered. is_stub=true. docs/DESIGN.md §12."
        )
        return SynthesisResult(
            audio_url=_STUB_AUDIO_URL,
            expires_in=settings.presign_expiry_seconds,
            is_stub=True,
        )


class StubTranslator:
    """Identity passthrough — performs no real translation.

    Until S3 wires live Mayura, the Devanagari-trap fix in `to_embedding_text()`
    is carried entirely by `glossary.py`'s domain-term pinning, not by this
    class. That is a documented property of this stub, not an oversight.
    """

    def translate(self, text: str, source_lang: str) -> TranslationResult:
        log.warning(
            "voice.to_embedding_text() translator served by STUB — identity "
            "passthrough, no real translation. is_stub=true. docs/DESIGN.md §12."
        )
        return TranslationResult(text=text, is_stub=True)


# ---------------------------------------------------------------------------
# Live providers. S4: Sarvam over HTTP via httpx — no sarvamai SDK, no other
# network call. Endpoints, headers and field names verified against
# docs.sarvam.ai (2026-08); see the S3 PR notes for the exact pages checked.
#
# core/services/assets.py (Shreekumar) exposes the two functions that closed
# the gap S3 flagged here: `get_asset_bytes(session, asset_id) -> bytes` for
# the read side (LiveSpeechToText) and `store_bytes(session, kind,
# content_type, data) -> StoredAsset` for the write side (LiveTextToSpeech).
# Both take the request's `session` — passed down from the router via
# asr.transcribe()/tts.synthesize(), never created here — so voice/ still
# never touches the database or S3 directly, preserving the module boundary
# docs/DESIGN.md §3 draws.
# ---------------------------------------------------------------------------

_SARVAM_BASE_URL = "https://api.sarvam.ai"
_SARVAM_API_KEY_HEADER = "api-subscription-key"


def _sarvam_headers() -> dict[str, str]:
    return {_SARVAM_API_KEY_HEADER: settings.sarvamai_api_key or ""}


def _sarvam_post(path: str, provider: str, **kwargs: object) -> dict:
    """POST to Sarvam; non-200 or a transport failure becomes a clean
    BhoomiError, never a raw httpx exception past this module boundary.

    `ErrorCode.VOICE_PROVIDER_UNAVAILABLE` (503, app/errors.py) is distinct
    from `AGRONOMIST_UNAVAILABLE`: that code carries a specific escalation
    meaning clients may branch on, and a Sarvam outage is an unrelated
    upstream-provider failure — this is its own code, not a reuse.
    """
    try:
        response = httpx.post(f"{_SARVAM_BASE_URL}{path}", headers=_sarvam_headers(), **kwargs)
    except httpx.HTTPError as exc:
        raise BhoomiError(
            ErrorCode.VOICE_PROVIDER_UNAVAILABLE,
            f"Voice service ({provider}) is temporarily unavailable. Try again shortly.",
            details={"error": str(exc)},
        ) from exc
    if response.status_code != 200:
        raise BhoomiError(
            ErrorCode.VOICE_PROVIDER_UNAVAILABLE,
            f"Voice service ({provider}) is temporarily unavailable. Try again shortly.",
            details={"status_code": response.status_code},
        )
    return response.json()


async def _sarvam_post_async(path: str, provider: str, **kwargs: object) -> dict:
    """Async twin of `_sarvam_post`, for the two Live providers that now run
    inside an async call chain (LiveSpeechToText, LiveTextToSpeech).

    Deliberately NOT unified with `_sarvam_post`: that sync helper is also
    used by `LiveTranslator.translate()`, which is called synchronously from
    `voice/embedding_text.py::to_embedding_text()`, itself called
    synchronously from `intelligence/rag.py` (Thaariha's module, out of S4's
    scope). Making `_sarvam_post` async would force that whole chain async
    too. Small, deliberate duplication instead — flagged in the S4 PR
    description as a follow-up: unify once/if Translator's callers go async.
    """
    try:
        async with httpx.AsyncClient() as client:
            response = await client.post(
                f"{_SARVAM_BASE_URL}{path}", headers=_sarvam_headers(), **kwargs
            )
    except httpx.HTTPError as exc:
        raise BhoomiError(
            ErrorCode.VOICE_PROVIDER_UNAVAILABLE,
            f"Voice service ({provider}) is temporarily unavailable. Try again shortly.",
            details={"error": str(exc)},
        ) from exc
    if response.status_code != 200:
        raise BhoomiError(
            ErrorCode.VOICE_PROVIDER_UNAVAILABLE,
            f"Voice service ({provider}) is temporarily unavailable. Try again shortly.",
            details={"status_code": response.status_code},
        )
    return response.json()


class LiveSpeechToText:
    """Sarvam Saaras, transcribe mode. docs.sarvam.ai/api-reference/speech-to-text/transcribe.

    `transcribe()` resolves `asset_id` -> bytes via
    `core.services.assets.get_asset_bytes(session, asset_id)`, then hands the
    bytes to `_transcribe_bytes()` for the actual Sarvam call.

    `get_asset_bytes` raises `NotFound` for two distinct core-level failures —
    no such Asset row, or a row whose presigned PUT was minted but never
    completed — collapsed into one code because the correct client action is
    identical either way: record and upload again. This method re-raises
    `NotFound` with farmer-safe copy (no "presigned"/"PUT" wording) and moves
    core's diagnostic message into `details.cause` for logs. `ValidationFailed`
    (wrong asset kind) passes through unchanged — that is a real client bug
    with an already-clear message, not a re-record case.
    """

    async def transcribe(
        self, session: AsyncSession, asset_id: str, lang: str, context: str
    ) -> TranscriptResult:
        try:
            audio = await get_asset_bytes(session, asset_id)
        except NotFound as exc:
            raise NotFound(
                "That recording could not be found. Please record your message "
                "again and try once more.",
                details={"asset_id": str(asset_id), "cause": exc.message},
            ) from exc
        return await self._transcribe_bytes(audio, lang)

    async def _transcribe_bytes(self, audio: bytes, lang: str) -> TranscriptResult:
        """The Sarvam call itself, given raw audio bytes already in hand.

        Sarvam's response carries no transcript-confidence field — only
        `language_probability`, which scores language *detection*, not
        transcription quality, and is nullable even then. `confidence` is
        `None` here, always — never a fabricated sentinel;
        `asr.transcribe()` falls back to a transcript-quality heuristic
        instead of an ASR_FLOOR comparison when it sees `None`.

        `parsed_intent` is always `None`: Sarvam Saaras transcribes, it does
        not extract intent, and no NLU component exists anywhere in this
        stack. Building one is out of S3's Sarvam-only scope — flagged as a
        deliberate default, not an oversight.
        """
        body = await _sarvam_post_async(
            "/speech-to-text",
            "speech-to-text",
            data={"model": SARVAM_STT_MODEL, "language_code": lang, "mode": "transcribe"},
            files={"file": ("audio", audio)},
        )
        return TranscriptResult(
            text=body["transcript"],
            confidence=None,
            lang=lang,
            parsed_intent=None,
            needs_confirmation=False,
            is_stub=False,
        )


class LiveTextToSpeech:
    """Sarvam Bulbul. docs.sarvam.ai/api-reference/text-to-speech/convert.

    `synthesize()` gets decoded audio bytes from `_synthesize_bytes()`, then
    hands them to `core.services.assets.store_bytes(session, AssetKind.AUDIO,
    "audio/wav", data)` — the write side of the same gap `LiveSpeechToText`
    read from — and maps the returned `StoredAsset.url`/`.expires_in` onto
    this module's `SynthesisResult` shape. voice/ never touches S3 or the
    database directly; that boundary is core's (docs/DESIGN.md §3).
    """

    async def synthesize(self, session: AsyncSession, text: str, lang: str) -> SynthesisResult:
        data = await self._synthesize_bytes(text, lang)
        stored = await store_bytes(session, AssetKind.AUDIO, "audio/wav", data)
        return SynthesisResult(audio_url=stored.url, expires_in=stored.expires_in, is_stub=False)

    async def _synthesize_bytes(self, text: str, lang: str) -> bytes:
        """The Sarvam call itself; returns decoded audio bytes.

        Storing these bytes and minting a URL is core's boundary — see the
        class docstring. This method stops at the bytes.
        """
        body = await _sarvam_post_async(
            "/text-to-speech",
            "text-to-speech",
            json={"text": text, "language_code": lang, "model": SARVAM_TTS_MODEL},
        )
        return base64.b64decode(body["audios"][0])


class LiveTranslator:
    """Sarvam Mayura, formal mode, pinned. docs.sarvam.ai/api-reference/text/translate-text.

    Fully unblocked: no boundary or schema issue. One engine for both
    voice-origin and typed-origin queries (docs/DESIGN.md §8) — always
    translates to `Lang.ENGLISH`, never an inline "en-IN" literal.
    """

    def translate(self, text: str, source_lang: str) -> TranslationResult:
        body = _sarvam_post(
            "/translate",
            "translate",
            json={
                "input": text,
                "source_language_code": source_lang,
                "target_language_code": Lang.ENGLISH.value,
                "model": SARVAM_TRANSLATE_MODEL,
                "mode": SARVAM_TRANSLATE_MODE,
            },
        )
        return TranslationResult(text=body["translated_text"], is_stub=False)


# ---------------------------------------------------------------------------
# Factories. One flag, `settings.asr_provider`, governs all three.
# ---------------------------------------------------------------------------


def get_speech_to_text() -> SpeechToText:
    if settings.asr_provider == "stub":
        return StubSpeechToText()
    return LiveSpeechToText()


def get_text_to_speech() -> TextToSpeech:
    if settings.asr_provider == "stub":
        return StubTextToSpeech()
    return LiveTextToSpeech()


def get_translator() -> Translator:
    if settings.asr_provider == "stub":
        return StubTranslator()
    return LiveTranslator()
