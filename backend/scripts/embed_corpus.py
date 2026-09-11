"""Backfill CorpusDoc.embedding for rows loaded with embedding=NULL.

OWNER: Shreekumar (script, mirrors scripts/load_corpus.py's shape) — calls
app.intelligence.rag.embed() (Thaariha's), the piece scripts/load_corpus.py's
own docstring said didn't exist yet ("Embeddings: no vector-generation path
exists in this codebase as of this loader ... Every row loads with
embedding = NULL").

Run from backend/, with LLM_ENABLED=true (embed() refuses otherwise --
app.intelligence.rag.embed()'s own docstring):

    LLM_ENABLED=true python -m scripts.embed_corpus
    LLM_ENABLED=true python -m scripts.embed_corpus --dry-run
    LLM_ENABLED=true python -m scripts.embed_corpus --force   # re-embed every row

Idempotent by default: only rows with `embedding IS NULL` are touched, so
running this after every `load_corpus.py` reload only pays the BGE-m3 cost
for chunks that are actually new. `--force` re-embeds every row regardless
(e.g. after a real model swap) — a deliberate, explicit choice, never the
default.

Embeds `content` directly, NOT `to_embedding_text(content, lang)`
(app.voice.embedding_text) — that function's translate-then-normalise-then-
glossary-pin pipeline exists for a QUERY written in an arbitrary farmer
language; every corpus document is authored in English already (the
manifest schema and every delivered .md file), so there is no language to
translate from. Running it through to_embedding_text() anyway would
identity-translate (English source_lang) and then glossary-pin domain terms
that are already in their canonical form — a no-op dressed as a safety
step, and the wrong function's job here (docs/DESIGN.md §8 gates that
pipeline's Devanagari-trap fix to QUERY-time embedding, not corpus
ingestion).
"""

from __future__ import annotations

import argparse
import asyncio
import pathlib
import sys

sys.path.insert(0, str(pathlib.Path(__file__).resolve().parents[1]))

from sqlalchemy import select  # noqa: E402
from sqlalchemy.ext.asyncio import AsyncSession  # noqa: E402

from app.config import settings  # noqa: E402
from app.core.models import CorpusDoc  # noqa: E402
from app.db import SessionLocal, dispose_engine  # noqa: E402
from app.intelligence.rag import embed  # noqa: E402


async def run(dry_run: bool, force: bool) -> int:
    if not settings.llm_enabled:
        print(
            "\n  LLM_ENABLED is not true -- embed() refuses to run "
            "(app.intelligence.rag.embed()'s own docstring). Set "
            "LLM_ENABLED=true for this one run.\n"
        )
        return 1

    async with SessionLocal() as session:
        rows = await _rows_to_embed(session, force)
        print(f"\n  rows to embed  {len(rows)}{'  (dry run, nothing written)' if dry_run else ''}")
        if dry_run or not rows:
            return 0

        embedded = 0
        for row in rows:
            row.embedding = embed(row.content)
            embedded += 1
            if embedded % 25 == 0:
                print(f"  ...{embedded}/{len(rows)}")
        await session.commit()
        print(f"  embedded and committed  {embedded}")
    return 0


async def _rows_to_embed(session: AsyncSession, force: bool) -> list[CorpusDoc]:
    statement = select(CorpusDoc) if force else select(CorpusDoc).where(
        CorpusDoc.embedding.is_(None)
    )
    return list((await session.execute(statement)).scalars().all())


async def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--dry-run", action="store_true",
        help="report how many rows would be embedded, write nothing",
    )
    parser.add_argument(
        "--force", action="store_true", help="re-embed every row, not just embedding IS NULL ones"
    )
    args = parser.parse_args()
    try:
        return await run(dry_run=args.dry_run, force=args.force)
    finally:
        await dispose_engine()


if __name__ == "__main__":
    raise SystemExit(asyncio.run(main()))
