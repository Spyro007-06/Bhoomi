"""verdict() -- covers only the sanity check added when merging Thaariha's
delivery (app/intelligence/verdict.py), not the full decision table. That
function is hers, reviewed and delivered; this pins the one behaviour that
did not exist in her original (a getattr() result computed and never used,
ruff F841) and was turned into a caller-bug tripwire rather than removed
outright -- see verdict.py's own docstring for the reasoning.
"""

from __future__ import annotations

from datetime import date

from app.contracts.enums import VerdictCode
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

    result = verdict(extracted, crop="paddy", target="paddy_blast", days_to_harvest=None,
                      matched_rows=rows)

    assert result.code == VerdictCode.NO_OBJECTION_FOUND


def test_matched_rows_for_a_different_ingredient_raises() -> None:
    """The caller bug this check exists to catch: registered_use.lookup()
    was called with a different ingredient than OCR actually extracted."""
    extracted = type("Extracted", (), {"active_ingredient": "carbendazim"})()
    rows = [_row(active_ingredient="glyphosate")]

    try:
        verdict(extracted, crop="paddy", target="paddy_blast", days_to_harvest=None,
                matched_rows=rows)
    except AssertionError as exc:
        assert "carbendazim" in str(exc)
        assert "glyphosate" in str(exc)
    else:
        raise AssertionError("expected verdict() to raise on a mismatched ingredient")
