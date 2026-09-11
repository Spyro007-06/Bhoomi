"""Corpus reads: crop/target retrieval, with the authoritative filter.

OWNER: Shreekumar

Specified by: docs/DESIGN.md §5 and §8 (v3).

-----------------------------------------------------------------------------
Two read paths, deliberately different.

`chunks_for(crop, target)` returns everything -- background reading, unfiltered.

`authoritative_chunks(crop, target)` excludes `authoritative = false` rows.
This is the ONLY function that may feed a chemical rung. Every corpus document
carries a Chemical Management section written from training knowledge and
flagged by the manifest itself as unverified against any registration table
(scripts/load_corpus.py). DESIGN §8 (v3) requires a chemical rung to resolve
against `registered_use` at composition time regardless of what the corpus
says -- that check belongs to whoever builds compose() (Thaariha,
app/intelligence/rag.py, currently NotImplementedError). This function is the
half of that guarantee that lives on the read side: compose() must call
authoritative_chunks(), never chunks_for(), when the retrieved text is about
to inform a dosage. A citation attached to an unverified figure is more
dangerous than no citation, because it looks checked.

core/ owns this because docs/DESIGN.md §3 keeps every database read inside
core/; intelligence/ receives typed results, never a session.
-----------------------------------------------------------------------------
"""

from __future__ import annotations

from dataclasses import dataclass
from datetime import date

from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.models import CorpusDoc


@dataclass(frozen=True, slots=True)
class CorpusChunk:
    """One retrievable section, detached from the ORM.

    Same reasoning as RegisteredUseRow in services/registered_use.py:
    intelligence/ never touches the database, so it receives a plain value
    rather than a lazy-loading ORM instance.
    """

    id: str
    doc_id: str
    title: str
    source: str
    content: str
    authoritative: bool
    reviewed_on: date | None
    """Added alongside search() (F7 wiring): docs/API_CONTRACT.md §8's
    CitationOut carries `reviewed_on` and had nowhere to read it from -- this
    dataclass is what compose()'s citations are built from."""


def _as_chunk(row: CorpusDoc) -> CorpusChunk:
    return CorpusChunk(
        id=str(row.id), doc_id=row.doc_id, title=row.title, source=row.source,
        content=row.content, authoritative=row.authoritative, reviewed_on=row.reviewed_on,
    )


async def chunks_for(session: AsyncSession, crop: str, target: str) -> list[CorpusChunk]:
    """Every chunk for a crop/target, authoritative and not.

    For background reading and for anything that is NOT composing a chemical
    rung -- what-to-check text, cultural and biological ladder rungs, Doubt
    Doctor context. Use authoritative_chunks() instead for anything that could
    end up as a dosage a farmer acts on.
    """
    rows = (
        await session.execute(
            select(CorpusDoc).where(CorpusDoc.crop == crop, CorpusDoc.target == target)
        )
    ).scalars().all()
    return [_as_chunk(r) for r in rows]


async def authoritative_chunks(
    session: AsyncSession, crop: str, target: str
) -> list[CorpusChunk]:
    """Chunks safe to inform a chemical rung. Excludes authoritative=false.

    THE function to call before any chemical-composition decision. See the
    module docstring.
    """
    rows = (
        await session.execute(
            select(CorpusDoc).where(
                CorpusDoc.crop == crop,
                CorpusDoc.target == target,
                CorpusDoc.authoritative.is_(True),
            )
        )
    ).scalars().all()
    return [_as_chunk(r) for r in rows]


async def search(
    session: AsyncSession, crop: str, target: str, query_embedding: list[float], limit: int = 5
) -> list[tuple[CorpusChunk, float]]:
    """pgvector similarity search, filtered by crop + target. docs/DESIGN.md §8.

    Args:
        query_embedding: the query's BGE-m3 vector (app.intelligence.rag.embed()
            -- intelligence/ computes the vector, this module is what actually
            touches the database with it, same split as everywhere else in this
            file).
        limit: candidates returned, most similar first.

    Returns:
        `(chunk, similarity)` pairs, similarity descending, similarity in
        [-1, 1] (cosine similarity = 1 - cosine_distance). Empty if the
        crop/target combination has no chunks, or every chunk for it still
        has `embedding IS NULL` (not yet backfilled by
        scripts/embed_corpus.py) -- both are honest "nothing to retrieve"
        results, not errors.

        Rows with a NULL embedding are excluded from the ORDER BY entirely
        (pgvector's `<=>` operator on NULL is NULL, which sorts
        unpredictably against real distances rather than sorting last) --
        the WHERE clause below filters them out explicitly rather than
        relying on ordering to push them to the end.

    The retrieval relevance check itself (`max(similarity) < RAG_THRESHOLD`
    -> escalate) is the gate's job (app.intelligence.gate.decide()), not
    this function's -- this is the read, not the decision.
    """
    distance = CorpusDoc.embedding.cosine_distance(query_embedding)
    statement = (
        select(CorpusDoc, distance.label("distance"))
        .where(
            CorpusDoc.crop == crop,
            CorpusDoc.target == target,
            CorpusDoc.embedding.is_not(None),
        )
        .order_by(distance)
        .limit(limit)
    )
    rows = (await session.execute(statement)).all()
    return [(_as_chunk(row), 1.0 - float(dist)) for row, dist in rows]
