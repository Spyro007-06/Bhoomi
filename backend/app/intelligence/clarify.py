"""Doubt Doctor answer resolution (F4). docs/DESIGN.md §7, docs/API_CONTRACT.md §7.

OWNER: Thaariha.

Pure decision logic only — no I/O, no DB, no advisory composition. Given the
cue that was asked and the farmer's answer, decides whether the pair is
resolved and to which label, or whether the answer escalates instead.

docs/API_CONTRACT.md §7: "There is no tiebreak branch: an inconclusive answer
escalates, it never selects the higher-confidence label." `unknown` and any
answer that does not match the cue's expected shape both escalate — this
module never falls back to picking the more-confident of the two candidates.
"""

from __future__ import annotations

from dataclasses import dataclass

from app.contracts.enums import CueAnswer, TargetLabel


@dataclass(frozen=True, slots=True)
class ClarifyResolution:
    """Either `resolved_label` is set (answer discriminated) or it is None
    (escalate) — never both, never neither. Mirrors the gate's own "exactly
    one outcome" property (docs/DESIGN.md §6) at Doubt Doctor's scale."""

    resolved: bool
    resolved_label: TargetLabel | None
    reason: str | None  # set only when resolved is False


def resolve(
    cue_discriminates: tuple[str, str] | list[str],
    cue_answer_yes_implies: TargetLabel,
    answer: CueAnswer,
) -> ClarifyResolution:
    """Decide the pair from a Doubt Doctor answer.

    Args:
        cue_discriminates: the DistinguishingCue's `discriminates` pair —
            exactly two TargetLabel values (DB CHECK enforces this; see
            app/core/models.py's DistinguishingCue and app/core/routers/
            diagnose.py's _find_discriminating_cue()).
        cue_answer_yes_implies: the cue's `answer_yes_implies` — which of the
            two labels a "yes" answer points to.
        answer: what the farmer answered.

    Returns:
        ClarifyResolution. "yes" resolves to answer_yes_implies. "no" resolves
        to the OTHER label in the pair — the cue is a yes/no discriminator
        between exactly two candidates, so a "no" is informative, not merely
        an absence of information. "unknown", or an answer that does not fit
        the pair, escalates with reason "answer_did_not_discriminate" —
        matching docs/API_CONTRACT.md §7's exact wire reason string.
    """
    pair = list(cue_discriminates)
    if len(pair) != 2 or cue_answer_yes_implies not in pair:
        # Malformed cue data reaching here is a data bug upstream (the DB
        # CHECK should have prevented it), not something to guess past.
        return ClarifyResolution(
            resolved=False, resolved_label=None, reason="answer_did_not_discriminate"
        )

    if answer == CueAnswer.YES:
        return ClarifyResolution(
            resolved=True, resolved_label=cue_answer_yes_implies, reason=None
        )

    if answer == CueAnswer.NO:
        other = next(label for label in pair if label != cue_answer_yes_implies)
        return ClarifyResolution(resolved=True, resolved_label=TargetLabel(other), reason=None)

    # CueAnswer.UNKNOWN, or anything else — no tiebreak, per the module
    # docstring.
    return ClarifyResolution(
        resolved=False, resolved_label=None, reason="answer_did_not_discriminate"
    )
