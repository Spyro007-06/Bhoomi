"""F7 — grounded advisory with the IPM ladder.

OWNER: Thaariha

Serves:
    POST /advisory/query

Specified by: docs/API_CONTRACT.md §8, docs/DESIGN.md §8.

Orchestration only — the retrieval/composition logic lives in
app.core.services.advisory (shared with diagnose.py's `advise` branch and
clarify.py's `resolved` branch) and app.intelligence.rag (Thaariha's).
"""

from __future__ import annotations

import uuid
from datetime import UTC, datetime

from fastapi import APIRouter, Depends
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.config import RAG_THRESHOLD
from app.core.models import Problem
from app.core.routers.problems import _owned_farm
from app.core.schemas.advisory import AdvisoryNotRetrievedOut, AdvisoryQueryIn, AdvisoryRetrievedOut
from app.core.schemas.problems import AdvisoryOut, CitationOut, LadderRungOut
from app.core.services.advisory import compose_advisory, retrieve
from app.db import get_session
from app.deps import Principal, current_principal
from app.errors import error_response

router = APIRouter(tags=["advisory"])


@router.post(
    "/advisory/query",
    response_model=AdvisoryRetrievedOut | AdvisoryNotRetrievedOut,
    responses={
        **error_response(401, "No, or an invalid, bearer token."),
        **error_response(403, "The caller is not a farmer, or the farm belongs to someone else."),
        **error_response(404, "That farm does not exist."),
        **error_response(422, "The request body did not parse."),
    },
)
async def advisory_query(
    payload: AdvisoryQueryIn,
    principal: Principal = Depends(current_principal),
    session: AsyncSession = Depends(get_session),
) -> AdvisoryRetrievedOut | AdvisoryNotRetrievedOut:
    """docs/API_CONTRACT.md §8's standalone question. Not tied to a Problem
    -- see app/core/schemas/advisory.py's module docstring for why the
    returned advisory is never persisted to the `advisory` table.

    `target` isn't part of the request contract (only `farm_id`,
    `query_text`, `lang`) -- retrieval is scoped to the farm's crop and, for
    target, the farm's most recently opened Problem's label if it has one,
    falling back to no target filter otherwise. docs/API_CONTRACT.md §8
    doesn't specify how a standalone question resolves a target; this is the
    orchestration's own reasonable choice, not a guess dressed as the spec.
    """
    farm = await _owned_farm(payload.farm_id, principal, session)

    # No target given in the request -- corpus.search() is filtered by
    # (crop, target), so it needs one. Inferred from the farm's most
    # recently opened labelled Problem, queried directly rather than via
    # Farm.problems (a lazy relationship this async session cannot resolve
    # implicitly). No such problem -> honest "not retrieved", not a
    # fabricated target guess.
    latest_problem = (
        await session.execute(
            select(Problem)
            .where(Problem.farm_id == farm.id, Problem.label.is_not(None))
            .order_by(Problem.opened_at.desc())
            .limit(1)
        )
    ).scalar_one_or_none()
    target = latest_problem.label.value if latest_problem else None

    if target is None:
        return AdvisoryNotRetrievedOut(
            spoken_summary="याबद्दल माझ्याकडे विश्वसनीय माहिती नाही. तज्ञाकडे पाठवू का?"
        )

    retrieval = await retrieve(session, farm.crop.value, target, payload.query_text, payload.lang)

    if retrieval.best_relevance is None or retrieval.best_relevance < RAG_THRESHOLD:
        return AdvisoryNotRetrievedOut(
            spoken_summary="याबद्दल माझ्याकडे विश्वसनीय माहिती नाही. तज्ञाकडे पाठवू का?"
        )

    composed = await compose_advisory(session, farm.crop.value, target, retrieval, None)
    if composed is None:
        return AdvisoryNotRetrievedOut(
            spoken_summary="याबद्दल माझ्याकडे विश्वसनीय माहिती नाही. तज्ञाकडे पाठवू का?"
        )

    citations = [
        CitationOut(doc_id=c.doc_id, title=c.title, reviewed_on=c.reviewed_on)
        for c in composed.citations
    ]
    advisory_out = AdvisoryOut(
        id=uuid.uuid4(),
        possible_issue=composed.possible_issue,
        what_to_check=composed.what_to_check,
        what_to_avoid=composed.what_to_avoid,
        ladder=[
            LadderRungOut(
                tier=rung.tier.value, action=rung.action, dosage=rung.dosage,
                phi_days=rung.phi_days, reentry_hours=rung.reentry_hours,
            )
            for rung in composed.ladder
        ],
        expert_trigger=composed.expert_trigger,
        citations=citations,
        created_at=datetime.now(UTC),
    )
    return AdvisoryRetrievedOut(advisory=advisory_out, citations=citations)
