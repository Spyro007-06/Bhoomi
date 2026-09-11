"""F7 orchestration: embed -> search -> compose, shared by three callers.

OWNER: Shreekumar (orchestration) — calls into Suchit's/Thaariha's modules,
same split as routers/diagnose.py's own module docstring ("OWNER: Thaariha +
Suchit; orchestration by Shreekumar").

Three callers share this rather than each re-implementing the sequence:

  POST /advisory/query               (routers/advisory.py)         -- a
      standalone farmer question, docs/API_CONTRACT.md §8.
  the `advise` branch of
  POST /farms/{id}/diagnose          (routers/diagnose.py)          -- the
      query is synthesised from the predicted label, not typed by the farmer.
  the `resolved` branch of
  POST /problems/{id}/clarify        (routers/clarify.py)           -- the
      query is synthesised from the resolved label, same reasoning.

One implementation is what keeps RAG_THRESHOLD applied the same way, and the
chemical-rung candidate set built the same way (registered_use.for_advisory()),
across all three call sites.

Split into two functions rather than one, so a caller that only needs
`retrieval_score` for `gate.decide()` (diagnose.py, before it knows the gate
will even reach `advise`) does not pay for an LLM call it may never need.
"""

from __future__ import annotations

import uuid
from dataclasses import dataclass, field

from sqlalchemy.ext.asyncio import AsyncSession

from app.config import settings
from app.core.models import Advisory
from app.core.schemas.problems import AdvisoryOut, CitationOut, LadderRungOut
from app.core.services import registered_use
from app.core.services.corpus import CorpusChunk
from app.core.services.corpus import search as corpus_search
from app.intelligence.rag import ComposedAdvisory, compose, embed
from app.voice.embedding_text import to_embedding_text


@dataclass(frozen=True, slots=True)
class RetrievalResult:
    """`embeddable_text` is carried forward so `compose_advisory()` below
    does not re-translate the same query — `to_embedding_text()` is a real
    (possibly billed) Sarvam call in live mode, not a pure function to
    re-run casually."""

    embeddable_text: str | None
    best_relevance: float | None
    chunks: list[CorpusChunk] = field(default_factory=list)


async def retrieve(
    session: AsyncSession, crop: str, target: str, query_text: str, lang: str
) -> RetrievalResult:
    """embed() + corpus.search(). Honestly empty (not an error) when:
    `settings.llm_enabled` is false (docs/DESIGN.md §12's three flags --
    retrieval is gated as one unit with composition, see
    app/intelligence/rag.py's module docstring), or `to_embedding_text()`
    refuses degenerate input (docs/DESIGN.md §8's length guard).
    """
    if not settings.llm_enabled:
        return RetrievalResult(embeddable_text=None, best_relevance=None, chunks=[])

    try:
        embeddable_text = to_embedding_text(query_text, lang)
    except ValueError:
        return RetrievalResult(embeddable_text=None, best_relevance=None, chunks=[])

    vector = embed(embeddable_text)
    hits = await corpus_search(session, crop, target, vector)
    best_relevance = hits[0][1] if hits else None
    return RetrievalResult(
        embeddable_text=embeddable_text, best_relevance=best_relevance, chunks=[c for c, _ in hits]
    )


async def compose_advisory(
    session: AsyncSession,
    crop: str,
    target: str,
    retrieval: RetrievalResult,
    days_to_harvest: int | None,
) -> ComposedAdvisory | None:
    """Finish the pipeline `retrieve()` started. `None` on either an empty
    retrieval (nothing to ground on -- caller should not normally reach here
    without checking `retrieval.best_relevance` against RAG_THRESHOLD first)
    or a composition that failed validation (app.intelligence.rag.compose()'s
    own `None` case) -- both mean the same thing to every caller: treat this
    exactly like `NO_RELEVANT_SOURCE`/`retrieved: false`.
    """
    if retrieval.embeddable_text is None or not retrieval.chunks:
        return None
    advisory_use_rows = await registered_use.for_advisory(session, target, crop)
    return await compose(
        retrieval.embeddable_text, crop, target, retrieval.chunks, advisory_use_rows,
        days_to_harvest,
    )


def persist(session: AsyncSession, problem_id: uuid.UUID, composed: ComposedAdvisory) -> Advisory:
    """Write `composed` as an Advisory row. Caller commits/flushes and reads
    `.id`/`.created_at` back afterward for `to_advisory_out()` below --
    mirrors every other write helper in this package (e.g.
    services/escalation.py's `escalate()`), which add-and-flush rather than
    commit themselves so the caller controls the transaction boundary.

    `ladder`/`citations` are stored as the plain JSON-serialisable dicts the
    DB's CHECK constraints (chemical-last, ladder-is-an-array) validate
    against -- see Advisory's own docstring, app/core/models.py.
    """
    advisory = Advisory(
        problem_id=problem_id,
        possible_issue=composed.possible_issue,
        what_to_check=composed.what_to_check,
        what_to_avoid=composed.what_to_avoid,
        ladder=[
            {
                "tier": rung.tier.value,
                "action": rung.action,
                "dosage": rung.dosage,
                "phi_days": rung.phi_days,
                "reentry_hours": rung.reentry_hours,
            }
            for rung in composed.ladder
        ],
        expert_trigger=composed.expert_trigger,
        citations=[
            {"doc_id": c.doc_id, "title": c.title, "reviewed_on": c.reviewed_on}
            for c in composed.citations
        ],
    )
    session.add(advisory)
    return advisory


def to_advisory_out(advisory: Advisory) -> AdvisoryOut:
    """`advisory` must already be flushed — `.id`/`.created_at` are DB-
    generated and `persist()` above does not populate them."""
    return AdvisoryOut(
        id=advisory.id,
        possible_issue=advisory.possible_issue,
        what_to_check=advisory.what_to_check,
        what_to_avoid=advisory.what_to_avoid,
        ladder=[LadderRungOut(**rung) for rung in advisory.ladder],
        expert_trigger=advisory.expert_trigger,
        citations=[CitationOut(**c) for c in advisory.citations],
        created_at=advisory.created_at,
    )
