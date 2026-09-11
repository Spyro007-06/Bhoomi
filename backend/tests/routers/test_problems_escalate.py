"""POST /problems/{id}/escalate -- the manual trigger. docs/API_CONTRACT.md §12.

Calls escalate_problem() directly rather than through TestClient/HTTP, same
reason test_farms_diagnose.py does: the client fixture's TestClient runs
against app.db's own engine, a separate connection from db_session's
rolled-back-on-teardown transaction, so a Farm/Problem row created here
would be invisible to it.

A route-surface addition only -- escalate() itself (core/services/
escalation.py) is pre-existing, tested elsewhere via its three existing
callers, and its idempotency guarantee is not re-derived here, only relied
on and proven live at this new call site too.
"""

from __future__ import annotations

import uuid

import pytest
from sqlalchemy import select

from app.contracts.enums import Crop, ProblemType, Role, TargetLabel
from app.core.models import Case, Farm, Problem, User
from app.core.routers.problems import escalate_problem
from app.deps import Principal
from app.errors import Forbidden, NotFound


async def _farm(session) -> Farm:
    farmer = User(role=Role.FARMER, phone=f"+9199{uuid.uuid4().int % 10**8:08d}", name="probe")
    session.add(farmer)
    await session.flush()
    farm = Farm(
        farmer_id=farmer.id,
        crop=Crop.PADDY,
        growth_stage="tillering",
        region=f"probe-{uuid.uuid4()}",
        location="SRID=4326;POINT(73.7898 19.9975)",
    )
    session.add(farm)
    await session.flush()
    return farm


async def _problem(session, farm: Farm) -> Problem:
    problem = Problem(
        farm_id=farm.id, problem_type=ProblemType.DISEASE, label=TargetLabel.PADDY_BLAST
    )
    session.add(problem)
    await session.flush()
    return problem


async def test_escalate_a_real_problem_matches_the_contract_shape(db_session) -> None:
    """A fresh, not-yet-escalated problem: the response has every field
    API_CONTRACT §12 names, with the right types."""
    farm = await _farm(db_session)
    problem = await _problem(db_session, farm)
    principal = Principal(subject=farm.farmer_id, role=Role.FARMER)

    out = await escalate_problem(problem_id=problem.id, principal=principal, session=db_session)

    assert out.case_id is not None
    assert out.status in ("open", "assigned", "resolved")
    assert out.assigned_to is None or isinstance(out.assigned_to, str)
    assert out.queue_position is None or out.queue_position >= 1
    assert out.eta_minutes is None or out.eta_minutes >= 0

    row = await db_session.get(Case, out.case_id)
    assert row is not None
    assert row.problem_id == problem.id


async def test_escalate_twice_returns_the_same_case(db_session) -> None:
    """escalate()'s own idempotency guarantee, proven at this call site: a
    second call on the same problem must not open a second case."""
    farm = await _farm(db_session)
    problem = await _problem(db_session, farm)
    principal = Principal(subject=farm.farmer_id, role=Role.FARMER)

    first = await escalate_problem(problem_id=problem.id, principal=principal, session=db_session)
    second = await escalate_problem(
        problem_id=problem.id, principal=principal, session=db_session
    )

    assert second.case_id == first.case_id

    cases = (
        await db_session.execute(select(Case).where(Case.problem_id == problem.id))
    ).scalars().all()
    assert len(cases) == 1


async def test_escalate_a_nonexistent_problem_is_not_found(db_session) -> None:
    principal = Principal(subject=uuid.uuid4(), role=Role.FARMER)

    with pytest.raises(NotFound):
        await escalate_problem(problem_id=uuid.uuid4(), principal=principal, session=db_session)


async def test_escalate_someone_elses_problem_is_not_found_not_forbidden(db_session) -> None:
    """Same collapse as _owned_problem's read routes: telling a caller a
    problem exists but belongs to someone else leaks the id space."""
    farm = await _farm(db_session)
    problem = await _problem(db_session, farm)
    other_principal = Principal(subject=uuid.uuid4(), role=Role.FARMER)

    with pytest.raises(NotFound):
        await escalate_problem(
            problem_id=problem.id, principal=other_principal, session=db_session
        )


async def test_escalate_refuses_a_non_farmer(db_session) -> None:
    farm = await _farm(db_session)
    problem = await _problem(db_session, farm)
    agronomist_principal = Principal(subject=uuid.uuid4(), role=Role.AGRONOMIST)

    with pytest.raises(Forbidden):
        await escalate_problem(
            problem_id=problem.id, principal=agronomist_principal, session=db_session
        )
