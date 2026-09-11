"""`POST /problems/{id}/label-check` request/response models.

OWNER: Suchit (extraction) + Shreekumar (lookup) + Thaariha (verdict) —
same split as app/core/routers/labelcheck.py. Specified by
docs/API_CONTRACT.md §9.

Two response shapes, both under one model with fields present-by-omission
(the route sets response_model_exclude_none=True):

  readable   -- extracted + verdict present, error/fallback absent
  unreadable -- extracted (ocr_confidence only) + error + fallback present,
                verdict absent (None, not a placeholder verdict)

This is NOT the §0 error envelope: `error` is one field inside a normal 200
response that also carries `extracted` and `fallback` alongside it, not the
`{"error": {...}}` shape BhoomiError renders. docs/API_CONTRACT.md §9's own
"Unreadable" example makes this explicit.
"""

from __future__ import annotations

import uuid

from pydantic import BaseModel

from app.contracts.enums import VerdictCode


class LabelCheckIn(BaseModel):
    image_asset_id: uuid.UUID
    days_to_harvest: int | None = None


class ExtractedOut(BaseModel):
    active_ingredient: str | None = None
    concentration: str | None = None
    formulation: str | None = None
    ocr_confidence: float


class VerdictOut(BaseModel):
    code: VerdictCode
    message: str
    matched_row_id: str | None = None


class LabelCheckErrorOut(BaseModel):
    """Not the §0 envelope's `ErrorDetail` — see the module docstring."""

    code: str
    message: str


class FallbackOut(BaseModel):
    accepts: list[str] = ["voice", "text"]


class LabelCheckResponse(BaseModel):
    extracted: ExtractedOut
    verdict: VerdictOut | None = None
    error: LabelCheckErrorOut | None = None
    fallback: FallbackOut | None = None
    # Voice synthesis of the verdict message (docs/API_CONTRACT.md §9's
    # example carries a Marathi spoken_summary). Not wired here: rendering
    # this needs voice.tts.synthesize(), and translating VERDICT_MESSAGES'
    # fixed English strings into the farmer's language is a decision for
    # whoever owns that translation path, not one label-check should
    # improvise. None is an honest gap, not a placeholder — see
    # app/intelligence/bundle.py's IMAGE URLS note for the same convention.
    spoken_summary: str | None = None
