"""Manual smoke test against the REAL Sarvam API. Not part of the normal suite.

Skipped unless SARVAMAI_API_KEY is set in the environment — the default
`pytest` run and CI never touch the real network. Run explicitly with:

    SARVAMAI_API_KEY=... pytest -q tests/test_voice_live_smoke.py

All three of LiveTranslator, LiveTextToSpeech and LiveSpeechToText are
exercised here (S4 wired the latter two against core.services.assets). Each
test below calls the provider's low-level `_synthesize_bytes()` /
`_transcribe_bytes()` method directly, not `synthesize()`/`transcribe()` —
those public methods also need a real DB session (for `store_bytes()` /
`get_asset_bytes()`), which is a separate, DB-backed live verification and not
this file's job. This file verifies only that the Sarvam calls themselves work
against the real API with a real key.
"""

from __future__ import annotations

import os

import pytest

from app.config import settings
from app.voice.providers import LiveSpeechToText, LiveTextToSpeech, LiveTranslator

pytestmark = pytest.mark.skipif(
    not os.environ.get("SARVAMAI_API_KEY"),
    reason="set SARVAMAI_API_KEY to run this against the real Sarvam API",
)


def test_live_translator_against_real_sarvam(monkeypatch: pytest.MonkeyPatch) -> None:
    monkeypatch.setattr(settings, "sarvamai_api_key", os.environ["SARVAMAI_API_KEY"])

    result = LiveTranslator().translate("माझ्या भातावर करपा आहे", "mr-IN")

    assert result.text
    assert result.is_stub is False


async def test_live_tts_against_real_sarvam(monkeypatch: pytest.MonkeyPatch) -> None:
    """Sarvam Bulbul returns WAV bytes. Not asserting exact byte content —
    Sarvam's output isn't guaranteed byte-stable run to run — only that we
    got real, non-empty audio back with the RIFF header WAV starts with."""
    monkeypatch.setattr(settings, "sarvamai_api_key", os.environ["SARVAMAI_API_KEY"])

    audio = await LiveTextToSpeech()._synthesize_bytes("तुमचं भात कसं आहे?", "mr-IN")

    assert audio
    assert audio.startswith(b"RIFF")


async def test_live_stt_against_real_sarvam(monkeypatch: pytest.MonkeyPatch) -> None:
    """Round-trip: synthesize a known short Marathi phrase, then transcribe
    the audio back. Not asserting exact string equality with the original
    phrase — Sarvam may normalize wording in ways that are real but harmless
    (we've seen "तुमचं भात कसं" round-trip to "तुमचा भात कसा", a grammatical
    normalization, not a transcription failure). `confidence` is asserted
    `None` here because that is the property the whole ASR_FLOOR-fallback
    design in asr.py depends on (docs/API_CONTRACT.md §4's deliberate
    deviation) — worth a live-verified assertion, not just a mocked one.
    """
    monkeypatch.setattr(settings, "sarvamai_api_key", os.environ["SARVAMAI_API_KEY"])

    audio = await LiveTextToSpeech()._synthesize_bytes("तुमचं भात कसं आहे?", "mr-IN")
    result = await LiveSpeechToText()._transcribe_bytes(audio, "mr-IN")

    assert result.text
    assert result.confidence is None
