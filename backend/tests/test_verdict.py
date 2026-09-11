"""verdict() -- covers the sanity check added when merging Thaariha's
delivery (app/intelligence/verdict.py) plus the WRONG_CLASS branch added
once `problem_type` was threaded through from the labelcheck router. Not the
full decision table -- see verdict.py's own docstring for the reasoning
behind the ingredient-mismatch tripwire.
"""

from __future__ import annotations

from datetime import date

from app.contracts.enums import ProblemType, VerdictCode
from app.core.services.registered_use import RegisteredUseRow
from app.intelligence.verdict import verdict


def _row(**overrides) -> RegisteredUseRow:
    defaults = dict(
        id="ru_1",
        active_ingredient="carbendazim",
        crop="paddy",
        target="paddy_blast",
        pesticide_class="fungicide",
        dosage_text="1g/L",
        phi_days=14,
        reentry_hours=24,
        source="CIB&RC",
        source_dated=date(2020, 1, 1),
        last_verified=None,
        restriction_note=None,
    )
    defaults.update(overrides)
    return RegisteredUseRow(**defaults)


def test_matched_rows_for_the_extracted_ingredient_pass_silently() -> None:
    """The normal path: caller's lookup() was scoped to the same ingredient
    OCR extracted. Casing/whitespace differ (OCR text vs. the normalised
    column) and must not trip the check."""
    extracted = type("Extracted", (), {"active_ingredient": "  Carbendazim "})()
    rows = [_row()]

    result = verdict(extracted, crop="paddy", target="paddy_blast",
                      problem_type=ProblemType.DISEASE, days_to_harvest=None,
                      matched_rows=rows)

    assert result.code == VerdictCode.NO_OBJECTION_FOUND


def test_matched_rows_for_a_different_ingredient_raises() -> None:
    """The caller bug this check exists to catch: registered_use.lookup()
    was called with a different ingredient than OCR actually extracted."""
    extracted = type("Extracted", (), {"active_ingredient": "carbendazim"})()
    rows = [_row(active_ingredient="glyphosate")]

    try:
        verdict(extracted, crop="paddy", target="paddy_blast",
                problem_type=ProblemType.DISEASE, days_to_harvest=None,
                matched_rows=rows)
    except AssertionError as exc:
        assert "carbendazim" in str(exc)
        assert "glyphosate" in str(exc)
    else:
        raise AssertionError("expected verdict() to raise on a mismatched ingredient")


def test_fungicide_against_a_pest_problem_is_wrong_class() -> None:
    """docs/DESIGN.md §9's own example: a fungicide matched against an
    insect-pest problem. problem_type comes from the Problem row, not from
    `target` -- see verdict.py's SECOND SIGNATURE NOTE."""
    extracted = type("Extracted", (), {"active_ingredient": "carbendazim"})()
    rows = [_row(target="paddy_yellow_stem_borer")]

    result = verdict(extracted, crop="paddy", target="paddy_yellow_stem_borer",
                      problem_type=ProblemType.PEST, days_to_harvest=None,
                      matched_rows=rows)

    assert result.code == VerdictCode.WRONG_CLASS
    assert result.matched_row_id == "ru_1"


def test_insecticide_against_a_disease_problem_is_wrong_class() -> None:
    """The mirror case: an insecticide (or acaricide/nematicide) matched
    against a disease is just as much a class mismatch as the fungicide/pest
    example docs/DESIGN.md §9 spells out."""
    extracted = type("Extracted", (), {"active_ingredient": "imidacloprid"})()
    rows = [_row(active_ingredient="imidacloprid", pesticide_class="insecticide")]

    result = verdict(extracted, crop="paddy", target="paddy_blast",
                      problem_type=ProblemType.DISEASE, days_to_harvest=None,
                      matched_rows=rows)

    assert result.code == VerdictCode.WRONG_CLASS


def test_herbicide_is_wrong_class_against_either_problem_type() -> None:
    """Herbicide is registered for weeds -- never a correct match for a
    disease or a pest problem, so it is absent from both compatibility sets
    rather than special-cased (see verdict.py's compatibility table)."""
    extracted = type("Extracted", (), {"active_ingredient": "glyphosate"})()
    rows = [_row(active_ingredient="glyphosate", pesticide_class="herbicide")]

    for problem_type in (ProblemType.DISEASE, ProblemType.PEST):
        result = verdict(extracted, crop="paddy", target="paddy_blast",
                          problem_type=problem_type, days_to_harvest=None,
                          matched_rows=rows)
        assert result.code == VerdictCode.WRONG_CLASS


def test_matching_class_still_checks_phi_before_no_objection() -> None:
    """Passing the new class-compatibility check must not short-circuit the
    existing PHI_CONFLICT / NO_OBJECTION_FOUND branches below it."""
    extracted = type("Extracted", (), {"active_ingredient": "carbendazim"})()
    rows = [_row(phi_days=14)]

    conflict = verdict(extracted, crop="paddy", target="paddy_blast",
                        problem_type=ProblemType.DISEASE, days_to_harvest=5,
                        matched_rows=rows)
    assert conflict.code == VerdictCode.PHI_CONFLICT

    clear = verdict(extracted, crop="paddy", target="paddy_blast",
                     problem_type=ProblemType.DISEASE, days_to_harvest=20,
                     matched_rows=rows)
    assert clear.code == VerdictCode.NO_OBJECTION_FOUND
