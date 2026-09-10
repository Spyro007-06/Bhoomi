"""Load seed/corpus/distinguishing_cues.json into distinguishing_cue.

OWNER: Shreekumar. Spec: docs/DESIGN.md §5, §7 (v3).

Run from backend/:

    python scripts/load_cues.py
    python scripts/load_cues.py --dry-run

Fifth loader in this family (seed/risk_targets.json, seed/inspection_tasks.json
via app/core/services/risk.py, scripts/load_registered_use.py,
scripts/load_corpus.py): validates and refuses, never coerces. A cue this
loader accepts is read directly by _find_discriminating_cue()
(app/core/routers/diagnose.py) at request time -- a malformed row here is not
a data-quality nuisance, it is a wrong or missing Doubt Doctor question served
to a farmer.

Idempotent per (sorted discriminates pair): delete-then-reinsert, same
pattern as load_corpus.py's (doc_id, target) idempotency and for the same
reason -- there is no per-cue natural key stable enough to upsert against
that survives an author rewording cue_text or question_text, but the pair a
cue discriminates IS stable, and this table's own CHECK
(ck_distinguishing_cue_pair) guarantees that pair is always exactly two
labels. distinguishing_cue.id has no durable external reference except an
ON DELETE SET NULL foreign key, so regenerating it on reload degrades
gracefully by the schema's own design -- the same way corpus_doc's per-chunk
ids already do on every corpus reload.

Must succeed cleanly on an empty cue array (`[]`).

-----------------------------------------------------------------------------
VALIDATION -- refuses, never coerces

discriminates          Exactly 2 elements, both exact TargetLabel members.
                        The DB CHECK already enforces the length; refusing
                        here reports it as a shaped, addressable data error
                        instead of a bare Postgres CHECK violation surfacing
                        as a crash. Two elements matters beyond the CHECK,
                        too: _find_discriminating_cue's `@>` containment
                        lookup (app/core/routers/diagnose.py) is only an
                        exact-set match BECAUSE discriminates is always
                        exactly 2 -- a 3-element row would still satisfy `@>`
                        for any 2 of its 3 labels, matching pairs it was
                        never authored for, silently.
answer_yes_implies     Exact TargetLabel member, AND one of the two labels
                        already named in discriminates. A cue whose "yes"
                        answer points outside the pair it discriminates is
                        not a separate data problem -- it is the same
                        first-class defect the DB CHECK does not (and
                        cannot, from one column alone) catch.
doc_id                 null is allowed -- means "not tied to a document", not
                        a refusal (the shipped paddy cue ships with doc_id
                        null today). Non-null must resolve to a real
                        corpus_document row. Checked once against a single
                        query of every known doc_id, not per row.
-----------------------------------------------------------------------------
"""

from __future__ import annotations

import argparse
import asyncio
import json
import pathlib
import sys
from dataclasses import dataclass, field

sys.path.insert(0, str(pathlib.Path(__file__).resolve().parents[1]))

from sqlalchemy import delete, select  # noqa: E402

from app.contracts.enums import TargetLabel  # noqa: E402
from app.core.models import CorpusDocument, DistinguishingCue  # noqa: E402
from app.db import SessionLocal, dispose_engine  # noqa: E402

CUES_PATH = (
    pathlib.Path(__file__).resolve().parents[1] / "seed" / "corpus" / "distinguishing_cues.json"
)

_TARGET_VALUES = {t.value for t in TargetLabel}


@dataclass
class CleanCue:
    cue_text: str
    question_text: str
    discriminates: list[str]
    answer_yes_implies: str
    doc_id: str | None


@dataclass
class Refusal:
    index: int
    label: str
    reasons: list[str] = field(default_factory=list)


def _identify(raw: dict, index: int) -> str:
    """Best-effort label for a refused row in the report -- never used to
    accept a row, only to make a human's job of finding it in the source
    JSON easier."""
    discriminates = raw.get("discriminates")
    if isinstance(discriminates, list) and discriminates:
        return " vs ".join(str(d) for d in discriminates)
    question = raw.get("question_text")
    if isinstance(question, str) and question:
        return question[:60] + ("…" if len(question) > 60 else "")
    return f"(entry {index})"


def _validate_structure(raw: dict, index: int) -> tuple[CleanCue | None, Refusal | None]:
    """Everything checkable without a database: shape, enum membership, and
    the discriminates/answer_yes_implies agreement. doc_id existence is
    checked separately, once, against a real query -- see load()."""
    reasons: list[str] = []

    cue_text = raw.get("cue_text")
    if not isinstance(cue_text, str) or not cue_text.strip():
        reasons.append("cue_text is missing or blank")

    question_text = raw.get("question_text")
    if not isinstance(question_text, str) or not question_text.strip():
        reasons.append("question_text is missing or blank")

    discriminates = raw.get("discriminates")
    valid_pair: list[str] | None = None
    if not isinstance(discriminates, list):
        reasons.append(f"discriminates is not a list ({discriminates!r})")
    elif len(discriminates) != 2:
        reasons.append(
            f"discriminates has {len(discriminates)} element(s), not exactly 2 "
            f"({discriminates!r}) -- the DB CHECK requires exactly 2, and "
            "_find_discriminating_cue's @> lookup is only an exact-set match "
            "because of that constraint; a 3-element row would match pairs "
            "it was never authored for"
        )
    else:
        bad_labels = [d for d in discriminates if d not in _TARGET_VALUES]
        if bad_labels:
            reasons.append(
                f"discriminates contains label(s) not in the frozen TargetLabel "
                f"enum: {bad_labels!r}"
            )
        else:
            valid_pair = [str(d) for d in discriminates]

    answer_yes_implies = raw.get("answer_yes_implies")
    if not isinstance(answer_yes_implies, str) or answer_yes_implies not in _TARGET_VALUES:
        reasons.append(
            f"answer_yes_implies {answer_yes_implies!r} is not an exact member of "
            "the frozen TargetLabel enum"
        )
    elif valid_pair is not None and answer_yes_implies not in valid_pair:
        reasons.append(
            f"answer_yes_implies {answer_yes_implies!r} is not one of the two "
            f"labels in discriminates ({valid_pair!r})"
        )

    doc_id = raw.get("doc_id")
    if doc_id is not None and (not isinstance(doc_id, str) or not doc_id.strip()):
        reasons.append(f"doc_id is present but not a non-empty string or null ({doc_id!r})")

    if reasons:
        return None, Refusal(index=index, label=_identify(raw, index), reasons=reasons)

    return (
        CleanCue(
            cue_text=cue_text.strip(),
            question_text=question_text.strip(),
            discriminates=valid_pair,  # type: ignore[arg-type]
            answer_yes_implies=answer_yes_implies,
            doc_id=doc_id,
        ),
        None,
    )


async def load(dry_run: bool = False) -> int:
    if not CUES_PATH.exists():
        print(
            f"\n  {CUES_PATH.relative_to(CUES_PATH.parents[2])} does not exist.\n"
            "  That is a clean, empty-cues state, not a failure -- nothing to load.\n"
        )
        return 0

    raw_cues = json.loads(CUES_PATH.read_text(encoding="utf-8"))
    if not isinstance(raw_cues, list):
        print("ERROR: distinguishing_cues.json must be a JSON array of cue objects.")
        return 1

    structurally_clean: list[CleanCue] = []
    refusals: list[Refusal] = []
    for index, raw in enumerate(raw_cues, start=1):
        clean, refusal = _validate_structure(raw, index)
        if refusal:
            refusals.append(refusal)
        else:
            structurally_clean.append(clean)  # type: ignore[arg-type]

    loaded = 0
    async with SessionLocal() as session:
        known_doc_ids = set(
            (await session.execute(select(CorpusDocument.doc_id))).scalars().all()
        )

        final: list[CleanCue] = []
        for cue in structurally_clean:
            if cue.doc_id is not None and cue.doc_id not in known_doc_ids:
                refusals.append(
                    Refusal(
                        index=0,
                        label=_identify(
                            {
                                "discriminates": cue.discriminates,
                                "question_text": cue.question_text,
                            },
                            0,
                        ),
                        reasons=[
                            f"doc_id {cue.doc_id!r} does not resolve to any corpus_document "
                            "row (null is allowed and means 'not tied to a document' -- this "
                            "is a non-null value that names a document that does not exist)"
                        ],
                    )
                )
            else:
                final.append(cue)

        if not dry_run:
            for cue in final:
                # Idempotent per pair: delete whichever cue currently
                # discriminates this exact pair (order-sensitive, matching
                # how the pair was authored) before inserting the fresh one.
                # See the module docstring for why this is delete-then-insert
                # rather than an upsert.
                await session.execute(
                    delete(DistinguishingCue).where(
                        DistinguishingCue.discriminates == cue.discriminates
                    )
                )
                session.add(
                    DistinguishingCue(
                        cue_text=cue.cue_text,
                        question_text=cue.question_text,
                        discriminates=cue.discriminates,
                        answer_yes_implies=cue.answer_yes_implies,
                        doc_id=cue.doc_id,
                    )
                )
                loaded += 1
            await session.commit()
        else:
            loaded = len(final)

    print(f"\n  source         {CUES_PATH.relative_to(CUES_PATH.parents[2])}")
    print(f"  cues read      {len(raw_cues)}")
    print(f"  cues loaded    {loaded}{'  (dry run, nothing written)' if dry_run else ''}")
    print(f"  cues refused   {len(refusals)}")

    if refusals:
        print("\n  refused rows - correct the source JSON, never here:")
        for r in refusals:
            print(f"    {r.label}")
            for reason in r.reasons:
                print(f"        - {reason}")

    if not raw_cues:
        print(
            "\n  The cue file holds an empty array. That is the current state and a\n"
            "  clean load, not a failure -- but F4's clarify branch resolves nothing\n"
            "  until it is populated. See scripts/corpus_coverage.py."
        )

    return 0


async def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--dry-run", action="store_true", help="validate and report, write nothing"
    )
    args = parser.parse_args()
    try:
        return await load(dry_run=args.dry_run)
    finally:
        await dispose_engine()


if __name__ == "__main__":
    raise SystemExit(asyncio.run(main()))
