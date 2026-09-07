"""scripts/load_cues.py: validation, refusal reasons, and reload idempotency.

Structural validation (_validate_structure) is a pure function, tested
directly with one deliberately broken row per rule. doc_id resolution and
idempotency need a real database -- tested through load() itself, against
db_session, with CUES_PATH and SessionLocal monkeypatched per test.
"""

from __future__ import annotations

import json
import sys

sys.path.insert(0, "scripts")

from load_cues import _validate_structure, load  # noqa: E402
from sqlalchemy import select  # noqa: E402

from app.core.models import CorpusDocument, DistinguishingCue  # noqa: E402

VALID_CUE = {
    "cue_text": "Blast lesions are spindle-shaped; brown spot lesions are round.",
    "question_text": "Is the spot pointed at both ends, like a narrow diamond?",
    "discriminates": ["paddy_blast", "paddy_brown_spot"],
    "answer_yes_implies": "paddy_blast",
    "doc_id": None,
}


# ===========================================================================
# Structural validation -- one deliberately broken row per rule
# ===========================================================================


def test_a_fully_valid_cue_is_accepted() -> None:
    clean, refusal = _validate_structure(VALID_CUE, 1)
    assert refusal is None
    assert clean is not None
    assert clean.discriminates == ["paddy_blast", "paddy_brown_spot"]
    assert clean.doc_id is None


def test_missing_cue_text_is_refused() -> None:
    row = {**VALID_CUE, "cue_text": ""}
    clean, refusal = _validate_structure(row, 1)
    assert clean is None
    assert refusal is not None
    assert any("cue_text" in r for r in refusal.reasons)


def test_missing_question_text_is_refused() -> None:
    row = {**VALID_CUE, "question_text": None}
    clean, refusal = _validate_structure(row, 1)
    assert clean is None
    assert any("question_text" in r for r in refusal.reasons)


def test_discriminates_with_three_elements_is_refused() -> None:
    """The DB CHECK requires exactly 2; a 3-element row would also silently
    corrupt _find_discriminating_cue's @> containment lookup."""
    row = {
        **VALID_CUE,
        "discriminates": ["paddy_blast", "paddy_brown_spot", "paddy_bacterial_leaf_blight"],
    }
    clean, refusal = _validate_structure(row, 1)
    assert clean is None
    assert any("exactly 2" in r for r in refusal.reasons)


def test_discriminates_with_one_element_is_refused() -> None:
    row = {**VALID_CUE, "discriminates": ["paddy_blast"]}
    clean, refusal = _validate_structure(row, 1)
    assert clean is None
    assert any("exactly 2" in r for r in refusal.reasons)


def test_discriminates_with_a_label_not_in_target_label_is_refused() -> None:
    row = {**VALID_CUE, "discriminates": ["paddy_blast", "leaf_gremlins"]}
    clean, refusal = _validate_structure(row, 1)
    assert clean is None
    assert any("not in the frozen TargetLabel enum" in r for r in refusal.reasons)


def test_answer_yes_implies_not_in_target_label_is_refused() -> None:
    row = {**VALID_CUE, "answer_yes_implies": "leaf_gremlins"}
    clean, refusal = _validate_structure(row, 1)
    assert clean is None
    assert any(
        "answer_yes_implies" in r and "not an exact member" in r for r in refusal.reasons
    )


def test_answer_yes_implies_outside_the_discriminated_pair_is_refused() -> None:
    """A cue whose 'yes' answer points outside the pair it discriminates --
    not a shape problem, a logic problem the DB CHECK cannot catch."""
    row = {**VALID_CUE, "answer_yes_implies": "paddy_bacterial_leaf_blight"}
    clean, refusal = _validate_structure(row, 1)
    assert clean is None
    assert any("not one of the two labels in discriminates" in r for r in refusal.reasons)


def test_null_doc_id_is_allowed_not_a_refusal() -> None:
    """Explicit regression guard: null doc_id means 'not tied to a document',
    matching the shipped paddy cue -- it must never be treated as a missing
    required field."""
    row = {**VALID_CUE, "doc_id": None}
    clean, refusal = _validate_structure(row, 1)
    assert refusal is None
    assert clean.doc_id is None


def test_non_string_doc_id_is_refused() -> None:
    row = {**VALID_CUE, "doc_id": 12345}
    clean, refusal = _validate_structure(row, 1)
    assert clean is None
    assert any("doc_id" in r for r in refusal.reasons)


# ===========================================================================
# doc_id resolution and idempotency against the real database -- via load()
# ===========================================================================


class _SessionCtx:
    """`async with SessionLocal() as session` without closing db_session out
    from under the rest of the test -- db_session's own fixture owns the
    close/rollback, this must not."""

    def __init__(self, session) -> None:
        self._session = session

    async def __aenter__(self):
        return self._session

    async def __aexit__(self, *exc_info: object) -> bool:
        return False


def _patch_loader(monkeypatch, db_session, cues: list[dict], tmp_path) -> None:
    cues_path = tmp_path / "distinguishing_cues.json"
    cues_path.write_text(json.dumps(cues))
    monkeypatch.setattr("load_cues.CUES_PATH", cues_path)
    monkeypatch.setattr("load_cues.SessionLocal", lambda: _SessionCtx(db_session))

    async def _flush_not_commit() -> None:
        # db_session's own transaction is rolled back by the fixture; a real
        # commit() here would end that outer transaction early.
        await db_session.flush()

    monkeypatch.setattr(db_session, "commit", _flush_not_commit)


async def test_a_doc_id_that_does_not_resolve_is_refused(db_session, monkeypatch, tmp_path) -> None:
    pair = ["cotton_whitefly", "cotton_thrips"]
    bad_row = {
        **VALID_CUE,
        "discriminates": pair,
        "answer_yes_implies": pair[0],
        "doc_id": "no-such-document",
    }
    _patch_loader(monkeypatch, db_session, [bad_row], tmp_path)

    await load(dry_run=False)

    query = select(DistinguishingCue).where(DistinguishingCue.discriminates == pair)
    rows = (await db_session.execute(query)).scalars().all()
    assert rows == []


async def test_a_doc_id_that_resolves_loads_successfully(db_session, monkeypatch, tmp_path) -> None:
    db_session.add(CorpusDocument(doc_id="real-doc"))
    await db_session.flush()

    _patch_loader(monkeypatch, db_session, [{**VALID_CUE, "doc_id": "real-doc"}], tmp_path)

    await load(dry_run=False)

    rows = (await db_session.execute(select(DistinguishingCue))).scalars().all()
    assert len(rows) == 1
    assert rows[0].doc_id == "real-doc"


async def test_reload_is_idempotent_per_discriminated_pair(
    db_session, monkeypatch, tmp_path
) -> None:
    """Running the loader twice against the same file must not duplicate the
    row -- delete-then-insert per (discriminates) pair."""
    _patch_loader(monkeypatch, db_session, [VALID_CUE], tmp_path)

    await load(dry_run=False)
    await load(dry_run=False)

    rows = (await db_session.execute(select(DistinguishingCue))).scalars().all()
    assert len(rows) == 1
    assert rows[0].discriminates == ["paddy_blast", "paddy_brown_spot"]


async def test_empty_cue_array_succeeds_cleanly(db_session, monkeypatch, tmp_path) -> None:
    before = (await db_session.execute(select(DistinguishingCue))).scalars().all()

    _patch_loader(monkeypatch, db_session, [], tmp_path)
    exit_code = await load(dry_run=False)
    assert exit_code == 0

    after = (await db_session.execute(select(DistinguishingCue))).scalars().all()
    assert len(after) == len(before)
