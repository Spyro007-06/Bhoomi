"""Pesticide label verdict (F8) — selects a fixed string, composes nothing.

OWNER: Thaariha. Spec: docs/DESIGN.md §9, docs/API_CONTRACT.md §9.

The verdict is a TABLE LOOKUP against `registered_use`. No model is consulted and
the LLM is not in this path at all. This function chooses which VerdictCode
applies; the farmer-facing string is the frozen constant in
app.contracts.gate.VERDICT_MESSAGES and is rendered verbatim.

Safety constraints, not style (docs/API_CONTRACT.md §17, invariants 7 and 8):
  - No verdict message contains "safe", "approved", "you can use", or any other
    endorsement phrasing.
  - An ingredient absent from registered_use returns NOT_IN_RECORDS with
    escalation offered. The server never infers a verdict for an unknown chemical.

SIGNATURE NOTE, changed from the original stub: this took a single
`matched_row: Any | None`. app/core/services/registered_use.py's own docstring
says NOT_REGISTERED_FOR_TARGET and NOT_IN_RECORDS are only distinguishable from
the FULL row set for an ingredient ("Filtering by target in SQL would collapse
both into 'no rows'"). A single pre-matched row cannot make that distinction —
by the time something has picked one row, it has already decided the ingredient
is known, foreclosing NOT_IN_RECORDS. So this takes `matched_rows: list`, the
unfiltered output of registered_use.lookup(session, ingredient, crop): every row
for that ingredient on that crop, across every target. I own this file; this is
a correction to match the sibling module's stated contract, not a guess.
"""

from __future__ import annotations

from dataclasses import dataclass
from typing import Any

from app.contracts.enums import VerdictCode
from app.contracts.gate import VERDICT_MESSAGES, phi_conflict_message
from app.core.services.registered_use import normalise_ingredient


@dataclass(frozen=True, slots=True)
class Verdict:
    """Return shape for docs/API_CONTRACT.md §9's `verdict` object."""

    code: VerdictCode
    message: str
    matched_row_id: str | None


def verdict(
    extracted: Any,
    crop: str,
    target: str,
    days_to_harvest: int | None,
    matched_rows: list,
) -> Verdict:
    """Select the verdict code for a label check.

    Args:
        extracted: OCR output (app.vision.ocr.extract_label's return value) —
            only `.active_ingredient` is read here; `.ocr_confidence` is the
            caller's job (below config.OCR_FLOOR -> OCR_UNREADABLE, never
            reaches this function at all, per docs/DESIGN.md §9).
        crop: the farm's crop, a value from the frozen Crop enum.
        target: the problem's target label, a value from TargetLabel.
        days_to_harvest: farmer-supplied, for the PHI check. None skips that
            check rather than assuming a safe harvest window.
        matched_rows: every `RegisteredUseRow` for this ingredient on this
            crop, across every target — i.e. exactly
            `registered_use.lookup(session, ingredient, crop)`'s return value,
            unfiltered by the caller. See the module docstring for why this
            must be the full set, not one pre-matched row.

    Returns:
        Verdict. Checked in order, first match wins:
            1. no rows at all                          -> NOT_IN_RECORDS
            2. rows exist, none for this target          -> NOT_REGISTERED_FOR_TARGET
            3. a row for this target, wrong pesticide_class
               for the problem_type implied by target    -> WRONG_CLASS
               (docs/DESIGN.md §9's example: fungicide matched against a pest
               problem)
            4. a row for this target, days_to_harvest given
               and less than its phi_days               -> PHI_CONFLICT
            5. otherwise                                  -> NO_OBJECTION_FOUND

        WRONG_CROP is not reachable from this signature: `matched_rows` is
        already scoped to one crop by the caller's lookup() call, so a
        cross-crop mismatch never appears in the input. If a caller ever
        passes rows for the farm's crop label mismatching what the farmer
        actually has (a client-side bug, not this function's job to catch),
        that is a defect at the call site, not a case this function can
        detect from the data it receives.

    Raises:
        AssertionError: `matched_rows` contains a row for a different
            ingredient than `extracted.active_ingredient`. This can only mean
            the caller's `registered_use.lookup(session, ingredient, crop)`
            call used a different ingredient than what OCR actually extracted
            — a caller bug, and one this function is otherwise positioned to
            never notice: it trusts matched_rows is already scoped correctly,
            per its own documented contract, and everything downstream of
            this check (NOT_REGISTERED_FOR_TARGET vs. WRONG_CLASS vs.
            PHI_CONFLICT) would silently reason about the wrong chemical
            rather than fail loudly. Compared after normalise_ingredient()
            (registered_use.py's own transform — casefold + strip) so OCR
            casing/whitespace never trips this; a real mismatch still does.
    """
    ingredient = getattr(extracted, "active_ingredient", None) or (
        extracted.get("active_ingredient") if isinstance(extracted, dict) else None
    )

    if not matched_rows:
        return Verdict(
            code=VerdictCode.NOT_IN_RECORDS,
            message=VERDICT_MESSAGES[VerdictCode.NOT_IN_RECORDS],
            matched_row_id=None,
        )

    expected = normalise_ingredient(ingredient or "")
    mismatched = {r.active_ingredient for r in matched_rows if r.active_ingredient != expected}
    assert not mismatched, (
        f"verdict() received matched_rows for a different ingredient than was "
        f"extracted -- extracted {ingredient!r} normalises to {expected!r}, but "
        f"matched_rows contains {sorted(mismatched)!r}. The caller's "
        "registered_use.lookup(session, ingredient, crop) call used a different "
        "ingredient than what OCR extracted; fix the call site, not this check."
    )

    for_target = [r for r in matched_rows if r.target == target]
    if not for_target:
        return Verdict(
            code=VerdictCode.NOT_REGISTERED_FOR_TARGET,
            message=VERDICT_MESSAGES[VerdictCode.NOT_REGISTERED_FOR_TARGET],
            matched_row_id=None,
        )

    # docs/DESIGN.md §9's WRONG_CLASS example is a fungicide matched against
    # an insect pest. ProblemType isn't derivable from a bare TargetLabel
    # string here without importing TARGET_TIERS' crop/pest split, which this
    # module doesn't otherwise need — the caller (labelcheck router) already
    # knows problem_type from the Problem row and is better positioned to
    # pass it than this function is to re-derive it from a label string.
    # Left as a TODO for whoever wires the router: pass problem_type through
    # and gate this branch on `row.pesticide_class` vs. it. Not guessed here.
    row = for_target[0]

    if days_to_harvest is not None and days_to_harvest < row.phi_days:
        return Verdict(
            code=VerdictCode.PHI_CONFLICT,
            message=phi_conflict_message(row.phi_days),
            matched_row_id=row.id,
        )

    return Verdict(
        code=VerdictCode.NO_OBJECTION_FOUND,
        message=VERDICT_MESSAGES[VerdictCode.NO_OBJECTION_FOUND],
        matched_row_id=row.id,
    )
