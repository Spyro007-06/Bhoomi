"""The confidence gate (F2) against Phase 1's vision fixtures.

docs/DESIGN.md §6. Runs decide() against the same four TopK objects the
POST /vision/classify fixture endpoint serves, so the gate is exercised
against realistic band-boundary values before any real corpus content exists
(Phase 2 brief: zero dependency on the corpus or registered_use.csv here).
"""

from __future__ import annotations

from app.core.routers.diagnose import _FIXTURES
from app.intelligence.gate import decide


def test_confident_fixture_with_no_retrieval_score_escalates() -> None:
    """Fails closed: `retrieval_score=None` means "not verified", not "not
    requested", and is treated the same as a score below RAG_THRESHOLD. This
    was previously (wrongly) an `advise` case -- see gate.py's module
    docstring for why that failed open. This is the one real caller today:
    diagnose.py passes None because retrieval isn't wired to the corpus yet."""
    decision = decide(_FIXTURES["confident"], None)
    assert decision.outcome == "escalate"
    assert decision.reason_code == "NO_RELEVANT_SOURCE"


def test_torn_fixture_goes_to_doubt_doctor() -> None:
    """blast vs brown_spot — the intended Doubt Doctor demo pair."""
    decision = decide(_FIXTURES["torn"], None)
    assert decision.outcome == "clarify"
    assert decision.reason_code == "AMBIGUOUS"
    competing = {p.label for p in decision.alternatives[:2]}
    assert competing == {"paddy_blast", "paddy_brown_spot"}


def test_low_confidence_fixture_escalates() -> None:
    decision = decide(_FIXTURES["low_confidence"], None)
    assert decision.outcome == "escalate"
    assert decision.reason_code == "BELOW_FLOOR"


def test_out_of_scope_fixture_escalates_regardless_of_confidence() -> None:
    """The out-of-scope flag must win even when top-1 clears the gate on its
    own -- this fixture's distribution is flat and low (v3: a bounded model
    cannot emit a confident label for a target outside the set), but the check
    is on `out_of_scope`, never on the confidence numbers."""
    decision = decide(_FIXTURES["out_of_scope"], None)
    assert decision.outcome == "escalate"
    assert decision.reason_code == "OUT_OF_SCOPE"


def test_alternatives_are_always_populated() -> None:
    """docs/API_CONTRACT.md §17 invariant 3, on every branch including advise."""
    for fixture in _FIXTURES.values():
        assert decide(fixture, None).alternatives


def test_confident_fixture_with_low_retrieval_score_escalates() -> None:
    """A confident, in-scope, unambiguous prediction with no grounded source
    must not reach advise. docs/DESIGN.md §6 final branch."""
    decision = decide(_FIXTURES["confident"], 0.10)
    assert decision.outcome == "escalate"
    assert decision.reason_code == "NO_RELEVANT_SOURCE"
    assert decision.threshold_applied == 0.60


def test_confident_fixture_with_high_retrieval_score_advises() -> None:
    """The only way to reach `advise` now: every earlier band clears AND a
    real retrieval score is present and above threshold."""
    decision = decide(_FIXTURES["confident"], 0.95)
    assert decision.outcome == "advise"
    assert decision.reason_code == "ABOVE_GATE"


def test_retrieval_score_not_consulted_before_earlier_bands() -> None:
    """A low retrieval_score must not override an earlier-band outcome — the
    ordering in the module docstring (scope/floor/ambiguity/gate, THEN
    retrieval) is load-bearing, not just documentation."""
    decision = decide(_FIXTURES["low_confidence"], 0.99)
    assert decision.outcome == "escalate"
    assert decision.reason_code == "BELOW_FLOOR"


def test_none_and_low_retrieval_score_are_equivalent() -> None:
    """The specific safety property the fail-closed fix exists for: an
    unverified score (None) must produce the identical outcome to a verified,
    low one -- "haven't checked" is not a more permissive state than
    "checked and it's bad"."""
    from_none = decide(_FIXTURES["confident"], None)
    from_low = decide(_FIXTURES["confident"], 0.0)
    assert from_none.outcome == from_low.outcome == "escalate"
    assert from_none.reason_code == from_low.reason_code == "NO_RELEVANT_SOURCE"
