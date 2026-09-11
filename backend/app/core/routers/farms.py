"""F1 — farm persistent memory.

OWNER: Shreekumar

Serves:
    POST /farms
    GET /farms/{id}
    PATCH /farms/{id}
    GET /farms/{id}/summary

Specified by: docs/API_CONTRACT.md §5. Farm shape is contract C2, docs/DESIGN.md §4.
"""

from __future__ import annotations

import uuid
from typing import Literal

from fastapi import APIRouter, Depends, status
from geoalchemy2.shape import to_shape
from sqlalchemy import func, select
from sqlalchemy.ext.asyncio import AsyncSession

from app.contracts.enums import FollowupResponse
from app.contracts.farm import SRID, GeoPoint
from app.core.models import Alert, Farm, FollowUp, Problem
from app.core.schemas.farms import (
    VOICE_CONFIRMATION_FIELDS,
    FarmCreate,
    FarmOut,
    FarmSummaryOut,
    FarmUpdate,
    HealthOut,
    HomeSummaryOut,
)
from app.db import get_session
from app.deps import Principal, current_principal
from app.errors import Forbidden, NotFound, error_response

router = APIRouter(prefix="/farms", tags=["farms"])

_UNAUTHENTICATED = error_response(401, "No, or an invalid, bearer token.")
_MALFORMED = error_response(422, "The request body did not parse.")
_MALFORMED_OR_UNCONFIRMED_VOICE = error_response(
    422,
    "The request body did not parse, OR input_source is \"voice\" and "
    "confirmed is not true -- a voice-derived value must be read back and "
    "confirmed before it can be saved (see VOICE_CONFIRMATION_FIELDS).",
)
# Every route below with a {farm_id} path param goes through _load_owned,
# which raises both for the same two reasons every time.
_FARM_NOT_FOUND_OR_FORBIDDEN = {
    **error_response(404, "That farm does not exist."),
    **error_response(
        403, "The caller is a farmer and that farm belongs to a different account."
    ),
}


def _point_wkt(location: GeoPoint) -> str:
    """POINT(lng lat) — longitude first. Reversing this puts a Nashik farm in
    the Indian Ocean and every ST_DWithin result silently becomes empty."""
    return f"SRID={SRID};POINT({location.lng} {location.lat})"


def _to_geopoint(location) -> GeoPoint:
    shape = to_shape(location)
    return GeoPoint(lat=shape.y, lng=shape.x)


def _as_farm_out(farm: Farm) -> FarmOut:
    return FarmOut(
        id=farm.id,
        farmer_id=farm.farmer_id,
        crop=farm.crop,
        variety=farm.variety,
        growth_stage=farm.growth_stage,
        region=farm.region,
        sowing_date=farm.sowing_date,
        location=_to_geopoint(farm.location),
        created_at=farm.created_at,
    )


async def _load_owned(
    farm_id: uuid.UUID, principal: Principal, session: AsyncSession
) -> Farm:
    """Fetch a farm the caller is allowed to see.

    A farmer sees only their own. Agronomists and officials see any farm — they
    work cases and hotspots across a district by definition.
    """
    farm = await session.get(Farm, farm_id)
    if farm is None:
        raise NotFound("That farm does not exist.")
    if principal.role == "farmer" and farm.farmer_id != principal.subject:
        raise Forbidden("That farm belongs to a different account.")
    return farm


@router.post(
    "",
    response_model=FarmSummaryOut,
    status_code=status.HTTP_201_CREATED,
    responses={**_UNAUTHENTICATED, **_MALFORMED_OR_UNCONFIRMED_VOICE},
)
async def create_farm(
    payload: FarmCreate,
    principal: Principal = Depends(current_principal),
    session: AsyncSession = Depends(get_session),
) -> FarmSummaryOut:
    """Create a farm. `location` is required — see FarmCreate."""
    farm = Farm(
        farmer_id=principal.subject,
        crop=payload.crop,
        variety=payload.variety,
        growth_stage=payload.growth_stage,
        region=payload.region,
        sowing_date=payload.sowing_date,
        location=_point_wkt(payload.location),
    )
    session.add(farm)
    await session.commit()
    await session.refresh(farm)

    return FarmSummaryOut(
        id=farm.id, crop=farm.crop, growth_stage=farm.growth_stage, region=farm.region
    )


@router.get(
    "/{farm_id}",
    response_model=FarmOut,
    responses={**_UNAUTHENTICATED, **_FARM_NOT_FOUND_OR_FORBIDDEN, **_MALFORMED},
)
async def get_farm(
    farm_id: uuid.UUID,
    principal: Principal = Depends(current_principal),
    session: AsyncSession = Depends(get_session),
) -> FarmOut:
    return _as_farm_out(await _load_owned(farm_id, principal, session))


@router.patch(
    "/{farm_id}",
    response_model=FarmOut,
    responses={
        **_UNAUTHENTICATED,
        **_FARM_NOT_FOUND_OR_FORBIDDEN,
        **_MALFORMED_OR_UNCONFIRMED_VOICE,
    },
)
async def update_farm(
    farm_id: uuid.UUID,
    payload: FarmUpdate,
    principal: Principal = Depends(current_principal),
    session: AsyncSession = Depends(get_session),
) -> FarmOut:
    """Update onboarding fields. Location is not one of them — see FarmUpdate.

    `input_source` / `confirmed` are validated by the schema (voice input must
    be confirmed or the request never reaches this body) and travel no
    further — excluded here so they are never passed to `setattr` against a
    model with no such columns. See VOICE_CONFIRMATION_FIELDS.
    """
    farm = await _load_owned(farm_id, principal, session)
    updates = payload.model_dump(exclude_unset=True, exclude=VOICE_CONFIRMATION_FIELDS)
    for field, value in updates.items():
        setattr(farm, field, value)
    await session.commit()
    await session.refresh(farm)
    return _as_farm_out(farm)


async def _health_summary(
    session: AsyncSession, farm: Farm, open_problems: int, active_alerts: int
) -> HealthOut:
    """F11, owner Thaariha. docs/API_CONTRACT.md §5: "a sentence and a trend
    arrow. There is no numeric score field, deliberately."

    First-cut heuristic, not a model -- there is no learned or authored
    health-scoring logic anywhere in this codebase to call instead, and F11
    was zero code before this. `trend` prefers the most recent FollowUp
    answer for this farm: that field exists precisely to record whether a
    farmer's symptoms got better, stayed the same, or got worse
    (`followup_response`, docs/DESIGN.md §5), which is a real signal rather
    than one inferred from bare counts. Only when no follow-up has ever been
    answered does trend fall back to "an active alert with an open problem
    reads as worsening, otherwise stable" -- still grounded in real rows, an
    honest first pass Thaariha can refine, not a placeholder.
    """
    latest_response = await session.scalar(
        select(FollowUp.response)
        .join(Problem, Problem.id == FollowUp.problem_id)
        .where(Problem.farm_id == farm.id, FollowUp.response.is_not(None))
        .order_by(FollowUp.responded_at.desc())
        .limit(1)
    )

    if latest_response == FollowupResponse.GOT_WORSE:
        trend: Literal["improving", "stable", "worsening"] = "worsening"
    elif latest_response == FollowupResponse.IMPROVED:
        trend = "improving"
    elif latest_response == FollowupResponse.NO_CHANGE:
        trend = "stable"
    else:
        trend = "worsening" if (active_alerts > 0 and open_problems > 0) else "stable"

    if open_problems == 0 and active_alerts == 0:
        sentence = "No open problems. Farm is being monitored."
    else:
        parts = []
        if open_problems:
            parts.append(f"{open_problems} open problem{'s' if open_problems != 1 else ''}")
        if active_alerts:
            parts.append(f"{active_alerts} active alert{'s' if active_alerts != 1 else ''}")
        sentence = ", ".join(parts).capitalize() + "."
        if latest_response == FollowupResponse.GOT_WORSE:
            sentence += " Latest follow-up reported symptoms getting worse."
        elif latest_response == FollowupResponse.IMPROVED:
            sentence += " Latest follow-up reported improvement."

    return HealthOut(sentence=sentence, trend=trend)


@router.get(
    "/{farm_id}/summary",
    response_model=HomeSummaryOut,
    responses={**_UNAUTHENTICATED, **_FARM_NOT_FOUND_OR_FORBIDDEN, **_MALFORMED},
)
async def farm_summary(
    farm_id: uuid.UUID,
    principal: Principal = Depends(current_principal),
    session: AsyncSession = Depends(get_session),
) -> HomeSummaryOut:
    """The home screen in one call. docs/API_CONTRACT.md §5.

    The three counts are real queries. `health` is computed by
    _health_summary() (F11, owner Thaariha) from real rows. `spoken_summary`
    stays null — see HomeSummaryOut for who owns it.
    """
    farm = await _load_owned(farm_id, principal, session)

    open_problems = await session.scalar(
        select(func.count())
        .select_from(Problem)
        .where(Problem.farm_id == farm.id, Problem.status == "open")
    )
    pending_followups = await session.scalar(
        select(func.count())
        .select_from(FollowUp)
        .join(Problem, Problem.id == FollowUp.problem_id)
        .where(Problem.farm_id == farm.id, FollowUp.responded_at.is_(None))
    )
    active_alerts = await session.scalar(
        select(func.count())
        .select_from(Alert)
        .where(Alert.farm_id == farm.id, Alert.outcome.is_(None))
    )

    open_problems = open_problems or 0
    active_alerts = active_alerts or 0

    return HomeSummaryOut(
        farm=FarmSummaryOut(
            id=farm.id, crop=farm.crop, growth_stage=farm.growth_stage, region=farm.region
        ),
        health=await _health_summary(session, farm, open_problems, active_alerts),
        open_problems=open_problems,
        pending_followups=pending_followups or 0,
        active_alerts=active_alerts,
    )
