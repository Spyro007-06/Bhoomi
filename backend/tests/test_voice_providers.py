"""Provider seam: stubs are loud, deterministic, and floor-safe by construction.

Spec: docs/DESIGN.md §8, §12, docs/API_CONTRACT.md §4.

Stub tests pass `session=None` for `SpeechToText`/`TextToSpeech`'s `session`
param: the stubs never touch it (providers.py's Stub* docstrings), so `None`
proves that at the type level without needing a real DB session.
"""

from __future__ import annotations

import pytest

from app.config import ASR_FLOOR, settings
from app.voice.providers import (
    LiveSpeechToText,
    LiveTextToSpeech,
    LiveTranslator,
    StubSpeechToText,
    StubTextToSpeech,
    StubTranslator,
    get_speech_to_text,
    get_text_to_speech,
    get_translator,
)


async def test_stub_speech_to_text_is_detectable_and_below_floor() -> None:
    result = await StubSpeechToText().transcribe(None, "a_1", "mr-IN", "query")
    assert result.is_stub is True
    assert result.confidence < ASR_FLOOR


async def test_stub_speech_to_text_is_deterministic_and_ignores_asset_id() -> None:
    first = await StubSpeechToText().transcribe(None, "a_1", "mr-IN", "query")
    second = await StubSpeechToText().transcribe(
        None, "a_completely_different_asset", "mr-IN", "query"
    )
    assert first.text == second.text
    assert first.confidence == second.confidence == pytest.approx(ASR_FLOOR * 0.5)


async def test_stub_text_to_speech_is_detectable_and_uses_presign_expiry() -> None:
    result = await StubTextToSpeech().synthesize(None, "hello", "mr-IN")
    assert result.is_stub is True
    assert result.expires_in == settings.presign_expiry_seconds


async def test_stub_text_to_speech_is_deterministic_and_ignores_text() -> None:
    first = await StubTextToSpeech().synthesize(None, "hello", "mr-IN")
    second = await StubTextToSpeech().synthesize(None, "something else entirely", "hi-IN")
    assert first.audio_url == second.audio_url


def test_stub_translator_is_detectable_and_is_identity() -> None:
    result = StubTranslator().translate("माझ्या भातावर करपा आहे", "mr-IN")
    assert result.is_stub is True
    assert result.text == "माझ्या भातावर करपा आहे"


@pytest.mark.parametrize(
    ("factory", "stub_type"),
    [
        (get_speech_to_text, StubSpeechToText),
        (get_text_to_speech, StubTextToSpeech),
        (get_translator, StubTranslator),
    ],
)
def test_factory_returns_stub_by_default(factory, stub_type) -> None:
    assert isinstance(factory(), stub_type)


@pytest.mark.parametrize(
    ("factory", "live_type"),
    [
        (get_speech_to_text, LiveSpeechToText),
        (get_text_to_speech, LiveTextToSpeech),
        (get_translator, LiveTranslator),
    ],
)
def test_factory_returns_live_when_selected(monkeypatch, factory, live_type) -> None:
    monkeypatch.setattr(settings, "asr_provider", "live")
    assert isinstance(factory(), live_type)
