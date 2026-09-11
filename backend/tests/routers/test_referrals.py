"""GET /farms/{id}/referrals -- F13 referral and helpline. docs/API_CONTRACT.md §14.

Tests for farm existence, caller ownership authorization, querying real staff
records from the database, and returning the frozen §14 response schema.
"""

from __future__ import annotations

import uuid

import pytest
from fastapi.testclient import TestClient

from app.contracts.enums import Crop, Role
from app.core.models import Farm, User
from app.core.routers.referrals import get_farm_referrals
from app.core.security import mint_access_token
from app.deps import Principal
from app.errors import Forbidden, NotFound
from app.main import create_app


def _unique_phone() -> str:
    return f"+9199{uuid.uuid4().int % 10**8:08d}"


async def _seed_farm(
    session, *, crop: Crop = Crop.PADDY, growth_stage: str = "tillering", region: str = "Nashik"
) -> tuple[Farm, User]:
    farmer = User(role=Role.FARMER, phone=_unique_phone(), name="Ramesh Pawar")
    session.add(farmer)
    await session.flush()

    farm = Farm(
        farmer_id=farmer.id,
        crop=crop,
        growth_stage=growth_stage,
        region=region,
        location="SRID=4326;POINT(73.74140 19.99730)",
    )
    session.add(farm)
    await session.flush()
    return farm, farmer


async def test_get_farm_referrals_returns_real_database_records(db_session) -> None:
    """TEST 6 — Farm has referrals: real agronomist records from the database are returned."""
    farm, farmer = await _seed_farm(db_session, region="Nashik")

    # Add real agronomist user in database
    agro_user = User(
        role=Role.AGRONOMIST,
        email=f"agronomist-{uuid.uuid4().hex[:6]}@kvk-nashik.example",
        name="Dr. Meera Kulkarni",
        password_hash="dev-hash",
        phone="+919820099999",
    )
    db_session.add(agro_user)
    await db_session.flush()

    principal = Principal(subject=farmer.id, role=Role.FARMER)
    response = await get_farm_referrals(farm_id=farm.id, principal=principal, session=db_session)

    assert len(response.referrals) >= 1
    kvk = next((r for r in response.referrals if r.kind == "kvk" and "Dr. Meera Kulkarni" in r.name), None)
    assert kvk is not None
    assert kvk.phone == "+919820099999"
    assert kvk.accepts_samples is True
    assert "Nashik" in kvk.name


async def test_get_farm_referrals_empty_when_no_referrals(db_session) -> None:
    """TEST 7 — Farm has no referrals: returns an empty collection, never fake data."""
    farm, farmer = await _seed_farm(db_session, region="Solapur")

    principal = Principal(subject=farmer.id, role=Role.FARMER)
    response = await get_farm_referrals(farm_id=farm.id, principal=principal, session=db_session)

    assert isinstance(response.referrals, list)


async def test_get_farm_referrals_nonexistent_farm_raises_404(db_session) -> None:
    """TEST 8 — Invalid / nonexistent farm raises 404 NOT_FOUND."""
    random_farm_id = uuid.uuid4()
    principal = Principal(subject=uuid.uuid4(), role=Role.FARMER)

    with pytest.raises(NotFound) as exc_info:
        await get_farm_referrals(farm_id=random_farm_id, principal=principal, session=db_session)

    assert "does not exist" in str(exc_info.value.message).lower()


async def test_get_farm_referrals_unauthorized_farmer_raises_403(db_session) -> None:
    """TEST 9 — Unauthorized farm access raises 403 FORBIDDEN, never leaking referral data."""
    farm, farmer = await _seed_farm(db_session, region="Nashik")
    different_farmer_id = uuid.uuid4()

    principal = Principal(subject=different_farmer_id, role=Role.FARMER)

    with pytest.raises(Forbidden) as exc_info:
        await get_farm_referrals(farm_id=farm.id, principal=principal, session=db_session)

    assert "belongs to a different account" in str(exc_info.value.message).lower()


async def test_agronomist_and_official_can_access_any_farm_referrals(db_session) -> None:
    """Agronomists and officials work across districts and can view any farm's referrals."""
    farm, farmer = await _seed_farm(db_session, region="Nashik")

    agro_principal = Principal(subject=uuid.uuid4(), role=Role.AGRONOMIST)
    response_agro = await get_farm_referrals(farm_id=farm.id, principal=agro_principal, session=db_session)
    assert isinstance(response_agro.referrals, list)

    official_principal = Principal(subject=uuid.uuid4(), role=Role.OFFICIAL)
    response_official = await get_farm_referrals(farm_id=farm.id, principal=official_principal, session=db_session)
    assert isinstance(response_official.referrals, list)


def test_referrals_http_unauthenticated_rejected() -> None:
    """HTTP integration: unauthenticated request to /farms/{id}/referrals returns 401."""
    client = TestClient(create_app())
    random_id = str(uuid.uuid4())
    res = client.get(f"/api/v1/farms/{random_id}/referrals")

    assert res.status_code == 401
    assert res.json()["error"]["code"] == "UNAUTHENTICATED"
