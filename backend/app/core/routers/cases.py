"""F12 - expert validation and the case bundle.

OWNER: split, deliberately. See docs/API_CONTRACT.md §13, ownership note.

    POST /cases/{id}/confirm         Shreekumar  (this file)
    GET  /agronomist/case-queue      Shreekumar  (this file)
    GET  /cases/{id}                 Thaariha    (this file)
    POST /cases/{id}/request-info     Thaariha    (NOT here - still 501)

docs/API_CONTRACT.md §16 lists the whole of §12/§13 as Thaariha's. §13's confirm
endpoint has no intelligence in it: it takes a verdict, writes a Confirmation,
and its four downstream effects — problem resolution, the prior, the spread
fan-out, the F15 aggregates — are all core features. Bundle compilation is the
part with reasoning in it and stays hers.

Specified by: docs/API_CONTRACT.md §12 and §13.
"""

from __future__ import annotations

import uuid

from fastapi import APIRouter, Depends, Query
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.contracts.enums import CaseStatus, Role
from app.core.models import Asset, Case, Diagnosis, Farm, FollowUp, LabelCheck, Observation, Problem
from app.core.schemas.bundle import CaseBundleOut
from app.core.schemas.cases import CaseQueueItem, CaseQueueOut, ConfirmIn, ConfirmOut
from app.core.services.confirmation import confirm_case
from app.db import get_session
from app.deps import Principal, require_role
from app.errors import BhoomiError, ErrorCode, NotFound, error_response
from app.intelligence.bundle import compile_bundle

router = APIRouter(tags=["agronomist"])

# Built once at import rather than per request. Calling require_role() inside a
# Depends() default constructs a fresh guard on every call, which works but
# makes the dependency non-identical between routes and defeats FastAPI's
# per-request dependency caching.
AGRONOMIST_ONLY = Depends(require_role(Role.AGRONOMIST))

_UNAUTHENTICATED = error_response(401, "No, or an invalid, bearer token.")
_NOT_AN_AGRONOMIST = error_response(403, "The caller's role is not agronomist.")


@router.get(
    "/agronomist/case-queue",
    response_model=CaseQueueOut,
    responses={
        **_UNAUTHENTICATED,
        **_NOT_AN_AGRONOMIST,
        **error_response(422, "`status` is not a recognised case_status value."),
    },
)
async def case_queue(
    status: CaseStatus = Query(default=CaseStatus.ASSIGNED),
    principal: Principal = AGRONOMIST_ONLY,
    session: AsyncSession = Depends(get_session),
) -> CaseQueueOut:
    """Cases for this agronomist, oldest first. docs/API_CONTRACT.md §13.

    Oldest first, not highest severity first: a queue ordered by urgency starves
    its tail, and the farmer whose case has waited longest is the one most
    likely to have stopped trusting that anyone is coming.
    """
    rows = (
        await session.execute(
            select(Case, Problem, Farm)
            .join(Problem, Problem.id == Case.problem_id)
            .join(Farm, Farm.id == Problem.farm_id)
            .where(Case.status == status)
            .order_by(Case.created_at)
        )
    ).all()

    return CaseQueueOut(
        cases=[
            CaseQueueItem(
                case_id=case.id,
                problem_id=problem.id,
                farm_id=farm.id,
                region=farm.region,
                label=problem.label,
                status=case.status,
                queue_position=position,
                eta_minutes=case.eta_minutes,
                created_at=case.created_at,
            )
            # queue_position is recomputed from the live ordering rather than
            # read off the row: the stored value was correct when the case was
            # opened and is stale the moment anything ahead of it resolves.
            for position, (case, problem, farm) in enumerate(rows, start=1)
        ]
    )


@router.get(
    "/cases/{case_id}",
    response_model=CaseBundleOut,
    responses={
        **_UNAUTHENTICATED,
        **_NOT_AN_AGRONOMIST,
        **error_response(404, "That case does not exist."),
    },
)
async def get_case_bundle(
    case_id: uuid.UUID,
    principal: Principal = AGRONOMIST_ONLY,
    session: AsyncSession = Depends(get_session),
) -> CaseBundleOut:
    """The bundle the agronomist opens. docs/API_CONTRACT.md §12.

    Compiled on read from live rows, not served out of Case.bundle -- that
    column exists for a future cached-write path (docs/DESIGN.md §5) but
    reading it directly risks serving a bundle that predates events recorded
    since it was last written. compile_bundle() (app/intelligence/bundle.py)
    does the shaping; this function only fetches.
    """
    case = await session.get(Case, case_id)
    if case is None:
        raise NotFound("That case does not exist.")

    problem = await session.get(Problem, case.problem_id)
    if problem is None:
        raise NotFound("That case's problem no longer exists.")
    farm = await session.get(Farm, problem.farm_id)
    if farm is None:
        raise NotFound("That case's farm no longer exists.")

    diagnosis = (
        await session.execute(
            select(Diagnosis)
            .where(Diagnosis.problem_id == problem.id)
            .order_by(Diagnosis.created_at.desc())
            .limit(1)
        )
    ).scalar_one_or_none()

    observations = (
        await session.execute(
            select(Observation).where(Observation.problem_id == problem.id)
        )
    ).scalars().all()

    label_checks = (
        await session.execute(
            select(LabelCheck).where(LabelCheck.problem_id == problem.id)
        )
    ).scalars().all()

    followups = (
        await session.execute(
            select(FollowUp).where(FollowUp.problem_id == problem.id)
        )
    ).scalars().all()

    # Images: every asset referenced by a diagnosis or a follow-up on this
    # problem. Not Asset.farm_id -- that column is farm-wide (every photo
    # ever uploaded for the farm), which would pull in images from unrelated
    # problems on a multi-problem farm.
    image_ids = {d.image_asset_id for d in [diagnosis] if d and d.image_asset_id}
    image_ids |= {f.image_asset_id for f in followups if f.image_asset_id}
    images = []
    if image_ids:
        images = (
            await session.execute(select(Asset).where(Asset.id.in_(image_ids)))
        ).scalars().all()

    return compile_bundle(
        case_id=case.id,
        status=case.status,
        farm=farm,
        problem=problem,
        diagnosis=diagnosis,
        observations=list(observations),
        images=list(images),
        label_checks=list(label_checks),
        followups=list(followups),
    )


@router.post(
    "/cases/{case_id}/confirm",
    response_model=ConfirmOut,
    responses={
        **_UNAUTHENTICATED,
        **_NOT_AN_AGRONOMIST,
        **error_response(404, "That case does not exist."),
        **error_response(
            422,
            "The request body did not parse (including corrected_label "
            "required/forbidden per verdict, ConfirmIn's own rule), OR that "
            "case has already been resolved.",
        ),
    },
)
async def confirm(
    case_id: uuid.UUID,
    payload: ConfirmIn,
    principal: Principal = AGRONOMIST_ONLY,
    session: AsyncSession = Depends(get_session),
) -> ConfirmOut:
    """Record the agronomist's verdict and everything that follows.

    `spread_alerts_issued` is the F6 fan-out count — the moment one confirmation
    becomes a village-wide warning, and the most demonstrable thing in the
    product. It counts upgraded alerts as well as new ones: a farm whose
    existing weather card was upgraded to `combined` has been warned.
    """
    case = await session.get(Case, case_id)
    if case is None:
        raise NotFound("That case does not exist.")
    if case.status == CaseStatus.RESOLVED:
        raise BhoomiError(
            ErrorCode.VALIDATION_FAILED, "That case has already been resolved."
        )

    result = await confirm_case(
        session,
        case=case,
        agronomist_id=principal.subject,
        verdict=payload.verdict,
        corrected_label=payload.corrected_label,
        treatment=payload.treatment,
        notes=payload.notes,
    )
    await session.commit()

    return ConfirmOut(
        case_id=case.id,
        status=result.case.status,
        problem_status=result.problem.status,
        confirmation_id=result.confirmation.id,
        spread_alerts_issued=result.spread.total,
    )
