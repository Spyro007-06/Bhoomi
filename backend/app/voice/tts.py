"""Text to speech for `spoken_summary` playback.

OWNER: Shruthi. Spec: docs/API_CONTRACT.md §4, stack docs/DESIGN.md §1.

Live provider: Sarvam Bulbul (config.SARVAM_TTS_MODEL). The provider sits behind
this function on purpose: a future custom/cloned regional voice (Bulbul supports
cloning; needs consented audio) is then a config change, not a change to callers.

spoken_summary may be composed in colloquial/local wording — an output choice
that does not affect retrieval. The one exception is F8 pesticide verdict
strings, which are fixed server copy read verbatim, never slang-rephrased.
"""

from __future__ import annotations

from sqlalchemy.ext.asyncio import AsyncSession

from app.voice.providers import SynthesisResult, get_text_to_speech


async def synthesize(session: AsyncSession, text: str, lang: str) -> SynthesisResult:
    """Render text to an audio object and return a presigned URL.

    `session` is forwarded to the live provider (which needs it to store the
    synthesized audio via core.services.assets.store_bytes) and ignored by
    the stub. tts.py never queries with it itself — core/ is the only
    package that touches the database or object storage (docs/DESIGN.md §3).

    Return shape is docs/API_CONTRACT.md §4: audio_url, expires_in.
    """
    return await get_text_to_speech().synthesize(session, text, lang)
