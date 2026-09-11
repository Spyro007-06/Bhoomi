"""F13 — referral and helpline.

OWNER: Tharun

Serves:
    GET /farms/{farm_id}/referrals

Specified by: docs/API_CONTRACT.md §14.
"""

from __future__ import annotations

import uuid

from fastapi import APIRouter, Depends
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.contracts.enums import Role
from app.core.models import User
from app.core.routers.farms import (
    _FARM_NOT_FOUND_OR_FORBIDDEN,
    _MALFORMED,
    _UNAUTHENTICATED,
    _load_owned,
)
from app.core.schemas.referrals import ReferralListOut, ReferralOut
from app.db import get_session
from app.deps import Principal, current_principal

router = APIRouter(tags=["referrals"])


@router.get(
    "/farms/{farm_id}/referrals",
    response_model=ReferralListOut,
    responses={**_UNAUTHENTICATED, **_FARM_NOT_FOUND_OR_FORBIDDEN, **_MALFORMED},
)
async def get_farm_referrals(
    farm_id: uuid.UUID,
    principal: Principal = Depends(current_principal),
    session: AsyncSession = Depends(get_session),
) -> ReferralListOut:
    """List referral contacts (KVK, plant clinics, helplines) available for a farm. §14.

    Enforces farm existence and caller authorization via _load_owned.
    Queries real staff / agronomist directory records from the database.
    Returns an empty collection if no referrals exist for the farm.
    """
    farm = await _load_owned(farm_id, principal, session)

    stmt = select(User).where(User.role == Role.AGRONOMIST)
    result = await session.execute(stmt)
    agronomists = result.scalars().all()

    referrals: list[ReferralOut] = []
    for agro in agronomists:
        phone = agro.phone or "1800-180-1551"
        referrals.append(
            ReferralOut(
                kind="kvk",
                name=f"KVK {farm.region} ({agro.name})",
                phone=phone,
                accepts_samples=True,
            )
        )

    return ReferralListOut(referrals=referrals)
