"""The confidence gate (F2) — the single most important function in the build.

OWNER: Thaariha. Spec: docs/DESIGN.md §6.

Everything consequential passes through `decide()`. It is deterministic code
comparing probabilities against constants, not a prompt — that is what makes the
"never fabricate" guarantee something you can point at.

Properties that must hold and must have tests (docs/DESIGN.md §6, §13):
  - Exactly one outcome. Never both advice and escalation; never neither.
  - `alternatives` populated on every branch, including `advise`.
  - No advisory composition happens before this returns `advise`.
  - Thresholds are imported from app.config. A threshold literal appearing here
    is a bug.

Ordering note from §6: the ambiguity check runs BEFORE the absolute-gate check.
0.68/0.12 is clear but under the gate -> escalate. 0.58/0.49 is ambiguous ->
Doubt Doctor, even though neither clears the gate. Ambiguity is the more
informative signal and is worth a question.

Phase 3 update: §6's final branch is now wired in — `retrieval_score <
RAG_THRESHOLD -> escalate`, reason NO_RELEVANT_SOURCE. This check runs last,
after out-of-scope/floor/ambiguity/gate all clear, i.e. it is the gate on the
path that would otherwise return `advise`: no corpus match strong enough to
back an advisory means the classifier confidence alone is not enough.

FAILS CLOSED on `retrieval_score is None`. This changed from the first draft,
which skipped the check on `None` ("no relevance check requested yet") to
avoid disturbing callers that hadn't wired retrieval. That reasoning inverted
the risk: `None` does not mean "retrieval was not asked for", it means
"nobody has verified whether a source exists" — and PRD §8 forbids composing
an advisory with no source behind it regardless of *why* the check was
skipped. The system's one real caller today (diagnose.py) passes `None`
because retrieval genuinely isn't wired yet; treating that as "assume a
source exists" would let an unsourced advisory ship the moment the composer
(rag.py compose()) lands, silently, with no code change to gate.py required
to cause it. Failing closed means every confident, in-scope, unambiguous
prediction escalates with NO_RELEVANT_SOURCE until retrieval is real — a
less impressive demo path today, but the correct one, and it replaces a 501
(the composer isn't built either) with a complete, honest response.

Crop-scope note: `topk.out_of_scope` is contract C1 — vision/ decides whether
the crop or target is in the bounded set (docs/DESIGN.md §4) and hands the
gate a plain bool. The gate does not keep its own crop list and never
inspects `topk.predictions` labels to make that call; it only reads the flag.
That is what makes the out-of-scope check crop-aware without this module
naming a single crop.
"""

from __future__ import annotations

from app.config import FLOOR, GATE, MARGIN, RAG_THRESHOLD
from app.contracts.enums import GateOutcome, GateReasonCode
from app.contracts.gate import GateDecision
from app.contracts.vision import TopK


def decide(topk: TopK, retrieval_score: float | None) -> GateDecision:
    """Map a classifier output to one gate outcome. See module docstring for
    what this does and does not implement.

    Args:
        topk: contract C1 from vision/.
        retrieval_score: corpus retrieval relevance for the query. `None`
            means "not verified" and fails CLOSED — it is treated the same
            as a score below RAG_THRESHOLD, not skipped. A caller that has
            not wired real retrieval yet will see every otherwise-advise
            case escalate with NO_RELEVANT_SOURCE; that is correct until it
            has one.

    Returns:
        GateDecision with exactly one outcome and populated alternatives.
    """
    alternatives = list(topk.predictions)

    if topk.out_of_scope:
        return GateDecision(
            outcome=GateOutcome.ESCALATE,
            confidence=topk.predictions[0].confidence,
            threshold_applied=GATE,
            reason_code=GateReasonCode.OUT_OF_SCOPE,
            alternatives=alternatives,
        )

    top1, top2 = topk.predictions[0], topk.predictions[1]

    if top1.confidence < FLOOR:
        return GateDecision(
            outcome=GateOutcome.ESCALATE,
            confidence=top1.confidence,
            threshold_applied=FLOOR,
            reason_code=GateReasonCode.BELOW_FLOOR,
            alternatives=alternatives,
        )

    if top1.confidence - top2.confidence < MARGIN:
        return GateDecision(
            outcome=GateOutcome.CLARIFY,
            confidence=top1.confidence,
            threshold_applied=MARGIN,
            reason_code=GateReasonCode.AMBIGUOUS,
            alternatives=alternatives,
        )

    if top1.confidence < GATE:
        # No reason code of its own exists for "clear but under the gate"
        # (GateReasonCode has five members total) — docs/DESIGN.md §6's own
        # pseudocode reuses BELOW_FLOOR here, so this does too.
        return GateDecision(
            outcome=GateOutcome.ESCALATE,
            confidence=top1.confidence,
            threshold_applied=GATE,
            reason_code=GateReasonCode.BELOW_FLOOR,
            alternatives=alternatives,
        )

    # Fails closed: retrieval_score is None or below threshold both escalate.
    # See module docstring — None is "not verified", not "not requested".
    if retrieval_score is None or retrieval_score < RAG_THRESHOLD:
        return GateDecision(
            outcome=GateOutcome.ESCALATE,
            confidence=top1.confidence,
            threshold_applied=RAG_THRESHOLD,
            reason_code=GateReasonCode.NO_RELEVANT_SOURCE,
            alternatives=alternatives,
        )

    return GateDecision(
        outcome=GateOutcome.ADVISE,
        confidence=top1.confidence,
        threshold_applied=GATE,
        reason_code=GateReasonCode.ABOVE_GATE,
        alternatives=alternatives,
    )
