"""F4 — the Doubt Doctor.

OWNER: Thaariha

Serves:
    POST /problems/{id}/clarify

Specified by: docs/API_CONTRACT.md §7, docs/DESIGN.md §7.

Orchestration only:
  1. Load the cue, resolve the answer (app.intelligence.clarify.resolve() --
     pure decision logic, no I/O, per that module's own docstring).
  2. Persist the Observation either way -- "the observation is stored either
     way and travels into the case bundle" (docs/API_CONTRACT.md §7).
  3. Resolved -> update the Problem's working label, then run the SAME
     retrieval+composition pipeline diagnose.py's `advise` branch uses
     (app.core.services.advisory), synthesising the query from the resolved
     label since there is no free-text farmer query at this point in the
     flow.
     Not resolved -> escalate(), matching docs/DESIGN.md §7's "not found ->
     escalate" rule, applied here to "did not discriminate" rather than
     "no cue found" (diagnose.py's own not-found branch).

RESOLVED-BUT-NO-ADVISORY, the one case docs/API_CONTRACT.md §7's own example
doesn't show: the cue resolves the label, but F7 cannot produce a grounded
advisory for it (no relevant source, or compose() rejects after its retry).
`resolved` stays `true` -- the Doubt Doctor's job is discriminating between
two labels, which succeeded -- and the response carries an `escalation`
instead of an `advisory`, never a fabricated one. See schemas/clarify.py's
module docstring.
"""

from __future__ import annotations

import uuid
from datetime import UTC, datetime

from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession

from app.config import RAG_THRESHOLD
from app.contracts.enums import TargetLabel
from app.core.models import DistinguishingCue, Observation
from app.core.routers.diagnose import _escalation_out
from app.core.routers.problems import _owned_problem
from app.core.schemas.clarify import (
    ClarifyIn,
    ClarifyNotResolvedOut,
    ClarifyResolvedOut,
    ResolvedDiagnosisOut,
)
from app.core.schemas.problems import AdvisoryOut, CitationOut, LadderRungOut
from app.core.services.advisory import compose_advisory, retrieve
from app.core.services.escalation import escalate
from app.db import get_session
from app.deps import Principal, current_principal
from app.errors import NotFound, error_response
from app.intelligence.clarify import resolve

router = APIRouter(tags=["doubt doctor"])


@router.post(
    "/problems/{problem_id}/clarify",
    response_model=ClarifyResolvedOut | ClarifyNotResolvedOut,
    responses={
        **error_response(401, "No, or an invalid, bearer token."),
        **error_response(403, "The caller is not the farmer who owns this problem."),
        **error_response(
            404,
            "That problem does not exist, belongs to a different account, or "
            "cue_id does not exist.",
        ),
        **error_response(422, "The request body did not parse."),
    },
)
async def clarify(
    problem_id: uuid.UUID,
    payload: ClarifyIn,
    principal: Principal = Depends(current_principal),
    session: AsyncSession = Depends(get_session),
) -> ClarifyResolvedOut | ClarifyNotResolvedOut:
    problem, farm = await _owned_problem(problem_id, principal, session)

    cue = await session.get(DistinguishingCue, payload.cue_id)
    if cue is None:
        raise NotFound("That cue does not exist.")

    resolution = resolve(cue.discriminates, cue.answer_yes_implies, payload.answer)

    observation = Observation(
        problem_id=problem.id,
        kind="doubt_doctor",
        question=cue.question_text,
        answer=payload.answer,
        cue_id=cue.id,
    )
    session.add(observation)
    await session.flush()

    if not resolution.resolved:
        case = await escalate(
            session, problem.id, reason=f"clarify: {resolution.reason}"
        )
        await session.commit()
        return ClarifyNotResolvedOut(
            reason=resolution.reason or "answer_did_not_discriminate",
            observation_id=observation.id,
            escalation=await _escalation_out(session, case),
        )

    resolved_label: TargetLabel = resolution.resolved_label
    problem.label = resolved_label
    await session.flush()

    retrieval = await retrieve(
        session, farm.crop.value, resolved_label.value,
        resolved_label.value.replace("_", " "), "en-IN",
    )

    advisory_out: AdvisoryOut | None = None
    citations: list[CitationOut] = []
    escalation_out = None

    if retrieval.best_relevance is not None and retrieval.best_relevance >= RAG_THRESHOLD:
        composed = await compose_advisory(
            session, farm.crop.value, resolved_label.value, retrieval, None
        )
        if composed is not None:
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

    if advisory_out is None:
        # RESOLVED-BUT-NO-ADVISORY -- see the module docstring.
        case = await escalate(
            session, problem.id, reason="clarify: resolved but no grounded advisory"
        )
        escalation_out = await _escalation_out(session, case)

    await session.commit()
    return ClarifyResolvedOut(
        diagnosis=ResolvedDiagnosisOut(label=resolved_label, severity=problem.severity),
        observation_id=observation.id,
        advisory=advisory_out,
        citations=citations,
        escalation=escalation_out,
    )
