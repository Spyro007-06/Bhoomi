"""F8 — pesticide label check.

OWNER: Suchit (extraction) + Shreekumar (lookup) + Thaariha (verdict)

Serves:
    POST /problems/{id}/label-check

Specified by: docs/API_CONTRACT.md §9, docs/DESIGN.md §9.

Orchestration only — no new decision logic lives here:

  1. OCR the label (app.vision.ocr.extract_label — Suchit's).
  2. Below OCR_FLOOR -> OCR_UNREADABLE, verdict never computed. Above it,
  3. look up the ingredient (app.core.services.registered_use.lookup —
     Shreekumar's), scoped to the farm's crop.
  4. Select the verdict (app.intelligence.verdict.verdict — Thaariha's),
     passing problem.problem_type straight through (see verdict.py's
     SECOND SIGNATURE NOTE for why this router, not that function, is the
     one that knows it).
  5. Persist a LabelCheck row either way — an OCR attempt happened and is
     recorded even when it could not be read, same convention as
     diagnose.py writing a Diagnosis row on every gate branch including the
     ones it cannot compose a full response for.

THE LANDMINE (vision/ocr.py's own docstring, LabelExtract): `registered_use`'s
active_ingredient column stores the FULL printed name including concentration
and formulation ("Isoprothiolane 40% EC"), and lookup() is an exact
casefold+trim match against that whole string. `extracted.raw_line` — the
untouched OCR line the ingredient/concentration/formulation were parsed out
of — is the closest available string to that full printed form, so it is
what gets looked up, not the bare `active_ingredient` field alone. A wrong
key here means a real label MISSES and returns NOT_IN_RECORDS, which is the
safe failure per registered_use.py's own docstring ("wrong-row-returned is
the failure mode that matters; no-row-returned is safe") — not a silent
wrong match.
"""

from __future__ import annotations

import uuid

from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession

from app.config import OCR_FLOOR
from app.contracts.enums import AssetKind
from app.core.models import LabelCheck
from app.core.routers.problems import _owned_problem
from app.core.schemas.labelcheck import (
    ExtractedOut,
    FallbackOut,
    LabelCheckErrorOut,
    LabelCheckIn,
    LabelCheckResponse,
    VerdictOut,
)
from app.core.services.assets import get_asset_bytes
from app.core.services.registered_use import lookup
from app.db import get_session
from app.deps import Principal, current_principal
from app.errors import ErrorCode, error_response
from app.intelligence.verdict import verdict as select_verdict
from app.vision.ocr import LabelExtract, extract_label

router = APIRouter(tags=["label check"])


def _extracted_out(extracted: LabelExtract) -> ExtractedOut:
    return ExtractedOut(
        active_ingredient=extracted.active_ingredient,
        concentration=extracted.concentration,
        formulation=extracted.formulation,
        ocr_confidence=extracted.ocr_confidence,
    )


def _lookup_key(extracted: LabelExtract) -> str:
    """The string handed to registered_use.lookup(). See the module
    docstring's LANDMINE note — raw_line is the closest thing to the CSV's
    full printed-name column this module has. Falls back to the bare
    active_ingredient only when OCR found no full line at all (raw_line is
    None but active_ingredient somehow isn't — a synthetic LabelExtract, not
    a shape extract_label() itself produces), so a caller never crashes on a
    missing raw_line; it just gets the weaker key and, most likely, an
    honest NOT_IN_RECORDS."""
    return extracted.raw_line or extracted.active_ingredient or ""


@router.post(
    "/problems/{problem_id}/label-check",
    response_model=LabelCheckResponse,
    response_model_exclude_none=True,
    responses={
        **error_response(401, "No, or an invalid, bearer token."),
        **error_response(403, "The caller is not the farmer who owns this problem."),
        **error_response(404, "That problem does not exist, or belongs to a different account."),
        **error_response(
            422,
            "The request body did not parse, or image_asset_id resolves to an "
            "Asset that is not kind=image.",
        ),
    },
)
async def label_check(
    problem_id: uuid.UUID,
    payload: LabelCheckIn,
    principal: Principal = Depends(current_principal),
    session: AsyncSession = Depends(get_session),
) -> LabelCheckResponse:
    """docs/API_CONTRACT.md §9. See the module docstring for the five-step
    orchestration; every step below is a call into another owner's module,
    not new logic."""
    problem, farm = await _owned_problem(problem_id, principal, session)

    image_bytes = await get_asset_bytes(
        session, payload.image_asset_id, expected_kind=AssetKind.IMAGE
    )
    extracted = extract_label(image_bytes)

    if extracted.ocr_confidence < OCR_FLOOR:
        session.add(
            LabelCheck(
                problem_id=problem.id,
                image_asset_id=payload.image_asset_id,
                extracted={
                    "active_ingredient": extracted.active_ingredient,
                    "concentration": extracted.concentration,
                    "formulation": extracted.formulation,
                },
                ocr_confidence=extracted.ocr_confidence,
                verdict_code=None,
                matched_row_id=None,
            )
        )
        await session.commit()
        return LabelCheckResponse(
            extracted=ExtractedOut(ocr_confidence=extracted.ocr_confidence),
            verdict=None,
            error=LabelCheckErrorOut(
                code=str(ErrorCode.OCR_UNREADABLE),
                message=(
                    "Couldn't read the label. Try a clearer photo, or say the "
                    "product name."
                ),
            ),
            fallback=FallbackOut(),
        )

    matched_rows = await lookup(session, _lookup_key(extracted), farm.crop.value)
    result = select_verdict(
        extracted,
        crop=farm.crop.value,
        target=problem.label.value if problem.label else "",
        problem_type=problem.problem_type,
        days_to_harvest=payload.days_to_harvest,
        matched_rows=matched_rows,
    )

    session.add(
        LabelCheck(
            problem_id=problem.id,
            image_asset_id=payload.image_asset_id,
            extracted={
                "active_ingredient": extracted.active_ingredient,
                "concentration": extracted.concentration,
                "formulation": extracted.formulation,
            },
            ocr_confidence=extracted.ocr_confidence,
            verdict_code=result.code,
            matched_row_id=result.matched_row_id,
        )
    )
    await session.commit()

    return LabelCheckResponse(
        extracted=_extracted_out(extracted),
        verdict=VerdictOut(
            code=result.code, message=result.message, matched_row_id=result.matched_row_id
        ),
    )
