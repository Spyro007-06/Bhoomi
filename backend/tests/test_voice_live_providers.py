"""Live Sarvam providers: request shape and error handling. docs.sarvam.ai.

Hermetic — `httpx.post` (LiveTranslator) and `httpx.AsyncClient`
(LiveSpeechToText, LiveTextToSpeech) are monkeypatched everywhere here;
nothing in this file touches the real network or a real database, and no
SARVAMAI_API_KEY is required to run it.
"""

from __future__ import annotations

import base64

import httpx
import pytest

from app.config import (
    SARVAM_STT_MODEL,
    SARVAM_TRANSLATE_MODE,
    SARVAM_TRANSLATE_MODEL,
    SARVAM_TTS_MODEL,
    settings,
)
from app.contracts.enums import Lang
from app.errors import BhoomiError, NotFound
from app.voice.providers import LiveSpeechToText, LiveTextToSpeech, LiveTranslator


def _fake_response(status_code: int, json_body: dict) -> httpx.Response:
    return httpx.Response(
        status_code, json=json_body, request=httpx.Request("POST", "https://api.sarvam.ai/x")
    )


@pytest.fixture(autouse=True)
def _fake_api_key(monkeypatch: pytest.MonkeyPatch) -> None:
    monkeypatch.setattr(settings, "sarvamai_api_key", "test-key-123")


class _FakeAsyncClient:
    """Stands in for `httpx.AsyncClient()` in an `async with` block.

    `handler(url, headers, **kwargs) -> httpx.Response | raises` mirrors the
    sync `fake_post` shape the LiveTranslator tests below already use, so the
    two styles read the same way despite one being sync and one async.
    """

    def __init__(self, handler) -> None:
        self._handler = handler

    async def __aenter__(self) -> _FakeAsyncClient:
        return self

    async def __aexit__(self, *exc_info: object) -> bool:
        return False

    async def post(self, url: str, headers: dict | None = None, **kwargs: object) -> httpx.Response:
        return self._handler(url, headers, **kwargs)


def _patch_async_client(monkeypatch: pytest.MonkeyPatch, handler) -> None:
    monkeypatch.setattr(
        "app.voice.providers.httpx.AsyncClient",
        lambda *a, **kw: _FakeAsyncClient(handler),
    )


def test_live_translator_sends_correct_request_and_parses_response(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    captured: dict = {}

    def fake_post(url: str, headers: dict, **kwargs: object) -> httpx.Response:
        captured["url"] = url
        captured["headers"] = headers
        captured["kwargs"] = kwargs
        return _fake_response(
            200,
            {
                "request_id": "r1",
                "translated_text": "my paddy has blast",
                "source_language_code": "mr-IN",
            },
        )

    monkeypatch.setattr("app.voice.providers.httpx.post", fake_post)

    result = LiveTranslator().translate("माझ्या भातावर करपा आहे", "mr-IN")

    assert captured["url"] == "https://api.sarvam.ai/translate"
    assert captured["headers"] == {"api-subscription-key": "test-key-123"}
    body = captured["kwargs"]["json"]
    assert body == {
        "input": "माझ्या भातावर करपा आहे",
        "source_language_code": "mr-IN",
        "target_language_code": Lang.ENGLISH.value,
        "model": SARVAM_TRANSLATE_MODEL,
        "mode": SARVAM_TRANSLATE_MODE,
    }
    assert result.text == "my paddy has blast"
    assert result.is_stub is False


def test_live_translator_non_200_raises_bhoomi_error_not_raw_exception(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    monkeypatch.setattr(
        "app.voice.providers.httpx.post",
        lambda *a, **kw: _fake_response(403, {"error": "forbidden"}),
    )

    with pytest.raises(BhoomiError):
        LiveTranslator().translate("hello", "en-IN")


def test_live_translator_transport_failure_raises_bhoomi_error_not_raw_exception(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    def fake_post(*a: object, **kw: object) -> httpx.Response:
        raise httpx.ConnectError("connection refused")

    monkeypatch.setattr("app.voice.providers.httpx.post", fake_post)

    with pytest.raises(BhoomiError):
        LiveTranslator().translate("hello", "en-IN")


async def test_live_stt_sends_correct_request(monkeypatch: pytest.MonkeyPatch) -> None:
    captured: dict = {}

    def handler(url: str, headers: dict, **kwargs: object) -> httpx.Response:
        captured["url"] = url
        captured["headers"] = headers
        captured["kwargs"] = kwargs
        return _fake_response(200, {"request_id": "r1", "transcript": "माझं भात तिळरी अवस्थेत आहे"})

    _patch_async_client(monkeypatch, handler)

    result = await LiveSpeechToText()._transcribe_bytes(b"fake-audio-bytes", "mr-IN")

    assert captured["url"] == "https://api.sarvam.ai/speech-to-text"
    assert captured["headers"] == {"api-subscription-key": "test-key-123"}
    assert captured["kwargs"]["data"] == {
        "model": SARVAM_STT_MODEL,
        "language_code": "mr-IN",
        "mode": "transcribe",
    }
    assert captured["kwargs"]["files"] == {"file": ("audio", b"fake-audio-bytes")}
    assert result.text == "माझं भात तिळरी अवस्थेत आहे"


async def test_live_stt_never_fabricates_a_confidence_number(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    _patch_async_client(
        monkeypatch,
        lambda *a, **kw: _fake_response(200, {"request_id": "r1", "transcript": "some words"}),
    )

    result = await LiveSpeechToText()._transcribe_bytes(b"fake-audio-bytes", "mr-IN")
    assert result.confidence is None


async def test_live_stt_empty_transcript_still_omits_parsed_intent(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    _patch_async_client(
        monkeypatch,
        lambda *a, **kw: _fake_response(200, {"request_id": "r1", "transcript": ""}),
    )

    result = await LiveSpeechToText()._transcribe_bytes(b"fake-audio-bytes", "mr-IN")
    assert result.text == ""
    assert result.parsed_intent is None
    assert result.needs_confirmation is False


async def test_live_stt_non_200_raises_bhoomi_error_not_raw_exception(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    _patch_async_client(
        monkeypatch,
        lambda *a, **kw: _fake_response(500, {"error": "internal"}),
    )

    with pytest.raises(BhoomiError):
        await LiveSpeechToText()._transcribe_bytes(b"fake-audio-bytes", "mr-IN")


async def test_live_tts_sends_correct_request_and_decodes_audio(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    captured: dict = {}
    encoded = base64.b64encode(b"fake-wav-bytes").decode()

    def handler(url: str, headers: dict, **kwargs: object) -> httpx.Response:
        captured["url"] = url
        captured["headers"] = headers
        captured["kwargs"] = kwargs
        return _fake_response(200, {"request_id": "r1", "audios": [encoded]})

    _patch_async_client(monkeypatch, handler)

    audio = await LiveTextToSpeech()._synthesize_bytes("hello", "mr-IN")

    assert captured["url"] == "https://api.sarvam.ai/text-to-speech"
    assert captured["headers"] == {"api-subscription-key": "test-key-123"}
    assert captured["kwargs"]["json"] == {
        "text": "hello",
        "language_code": "mr-IN",
        "model": SARVAM_TTS_MODEL,
    }
    assert audio == b"fake-wav-bytes"


async def test_live_tts_non_200_raises_bhoomi_error_not_raw_exception(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    _patch_async_client(
        monkeypatch,
        lambda *a, **kw: _fake_response(429, {"error": "rate limited"}),
    )

    with pytest.raises(BhoomiError):
        await LiveTextToSpeech()._synthesize_bytes("hello", "mr-IN")


async def test_live_stt_transcribe_maps_not_uploaded_to_farmer_safe_notfound(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    """`core.services.assets.get_asset_bytes` raises `NotFound` for the "row
    exists, no object was ever uploaded" case with a diagnostic message that
    talks about presigned PUTs — not farmer-facing copy.
    `LiveSpeechToText.transcribe()` must re-raise `NotFound` with client-safe
    wording (no "presigned"/"PUT") while preserving that diagnostic text in
    `details.cause`, per docs/API_CONTRACT.md §0 (one error envelope, no raw
    internals leaking to the client).
    """
    diagnostic = (
        "Asset a_1's row exists but no object was ever uploaded to storage — "
        "the presigned PUT for 'audio/a_1.webm' was minted but never "
        "completed, or failed partway."
    )

    async def fake_get_asset_bytes(session: object, asset_id: object) -> bytes:
        raise NotFound(diagnostic)

    monkeypatch.setattr("app.voice.providers.get_asset_bytes", fake_get_asset_bytes)

    with pytest.raises(NotFound) as excinfo:
        await LiveSpeechToText().transcribe(None, "a_1", "mr-IN", "query")

    message = excinfo.value.message
    assert "presigned" not in message.lower()
    assert "PUT" not in message
    assert excinfo.value.details["cause"] == diagnostic
