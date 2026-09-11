"""POST /farms/{id}/diagnose -- the orchestration. docs/API_CONTRACT.md §6.

Calls diagnose_farm() directly rather than through TestClient/HTTP: the
client fixture's TestClient runs against app.db's own engine, a separate
connection from db_session's rolled-back-on-teardown transaction, so data
created here would be invisible to it (or would leak permanently if made
visible). diagnose_farm() is a plain async function -- FastAPI route
handlers always are -- so it is called directly with a real Farm/Asset row
from the same session, same style test_alert_response.py already uses for
alerts_service.record_response().

The four original fixture-band tests were ALSO verified live over real HTTP
first -- see that task's pasted curl output; this file is the regression net
for those, not the first proof. The VISION_MODEL=real tests added later
(search "the real classifier path" below) are NOT covered by that claim:
get_asset_bytes()/classify() are mocked in those three, and as of when they
were added, neither had been run live -- no real model checkpoint or object
storage was reachable from the environment that wrote them. Said explicitly
here rather than left for a reader to assume from the sentence above, which
predates them and was never true of them.
"""

from __future__ import annotations

import uuid

import pytest
from sqlalchemy import select

from app.contracts.enums import AssetKind, Crop, GateOutcome, Role, TargetLabel
from app.core.models import (
    Asset,
    Diagnosis,
    DistinguishingCue,
    Farm,
    LabelPrior,
    LabelReference,
    Problem,
    User,
)
from app.core.routers.diagnose import diagnose_farm
from app.core.schemas.diagnose import DiagnoseIn
from app.deps import Principal


def _unique_region() -> str:
    """A region string that cannot collide with real seeded/live data.

    LabelPrior's primary key is (region, crop, growth_stage, label) with no
    upsert on the write path this test exercises directly -- a fixed region
    like "Nashik" collided with a real LabelPrior row this suite's own live
    verification had already committed for real (Nashik/paddy/tillering/
    paddy_blast, via POST /cases/{id}/confirm against the same database).
    db_session's rollback-on-teardown isolates what THIS test writes; it does
    not protect against colliding with what already exists.
    """
    return f"probe-{uuid.uuid4()}"


async def _farm(
    session, *, crop: Crop = Crop.PADDY, growth_stage: str = "tillering", region: str | None = None
) -> Farm:
    farmer = User(role=Role.FARMER, phone=f"+9199{uuid.uuid4().int % 10**8:08d}", name="probe")
    session.add(farmer)
    await session.flush()
    farm = Farm(
        farmer_id=farmer.id,
        crop=crop,
        growth_stage=growth_stage,
        region=region or _unique_region(),
        location="SRID=4326;POINT(73.7898 19.9975)",
    )
    session.add(farm)
    await session.flush()
    return farm


async def _asset(session, farm: Farm) -> Asset:
    asset = Asset(
        kind=AssetKind.IMAGE, content_type="image/jpeg",
        object_key=f"probe/{uuid.uuid4()}.jpg", farm_id=farm.id,
    )
    session.add(asset)
    await session.flush()
    return asset


async def _diagnose(session, farm: Farm, fixture: str | None) -> object:
    asset = await _asset(session, farm)
    payload = DiagnoseIn(image_asset_id=asset.id, lang="mr-IN")
    principal = Principal(subject=farm.farmer_id, role=Role.FARMER)
    return await diagnose_farm(
        farm_id=farm.id, payload=payload, x_vision_fixture=fixture,
        principal=principal, session=session,
    )


# --- the four fixtures, each gate outcome ------------------------------------


async def test_low_confidence_escalates_below_floor(db_session) -> None:
    farm = await _farm(db_session)
    out = await _diagnose(db_session, farm, "low_confidence")

    assert out.gate.outcome == "escalate"
    assert out.gate.reason_code == "BELOW_FLOOR"
    assert out.gate.is_stub is True
    assert len(out.gate.alternatives) == 3
    assert out.escalation is not None
    assert out.escalation.case_id is not None


async def test_torn_is_ambiguous_then_escalated_no_cue_exists(db_session) -> None:
    """DistinguishingCue is empty in this environment -- docs/DESIGN.md §7's
    "not found -> escalate". reason_code stays AMBIGUOUS (why); outcome
    reports escalate (what actually happened)."""
    farm = await _farm(db_session)
    out = await _diagnose(db_session, farm, "torn")

    assert out.gate.outcome == "escalate"
    assert out.gate.reason_code == "AMBIGUOUS"
    assert out.escalation is not None


async def test_torn_renders_the_doubt_doctor_question_when_a_cue_matches(db_session) -> None:
    """F4's question rendering -- the branch that used to 501. A matching
    DistinguishingCue for (paddy_blast, paddy_brown_spot) makes the gate's
    `clarify` outcome carry a real `clarification`, not an escalation. One
    candidate (paddy_blast) has a LabelReference row; the other
    (paddy_brown_spot) does not -- signature/image_url on that candidate
    must be honestly None, not fabricated."""
    farm = await _farm(db_session)

    db_session.add(
        DistinguishingCue(
            cue_text="probe cue",
            question_text="Is it pointed at both ends?",
            discriminates=["paddy_blast", "paddy_brown_spot"],
            answer_yes_implies=TargetLabel.PADDY_BLAST,
        )
    )
    db_session.add(
        LabelReference(label=TargetLabel.PADDY_BLAST, signature="Diamond-shaped, grey centre")
    )
    await db_session.flush()

    out = await _diagnose(db_session, farm, "torn")

    assert out.gate.outcome == "clarify"
    assert out.escalation is None
    assert out.advisory is None
    assert out.clarification is not None
    assert out.clarification.question == "Is it pointed at both ends?"
    assert out.clarification.question_localized is None
    assert {c.label for c in out.clarification.candidates} == {
        TargetLabel.PADDY_BLAST,
        TargetLabel.PADDY_BROWN_SPOT,
    }
    blast = next(c for c in out.clarification.candidates if c.label == TargetLabel.PADDY_BLAST)
    brown_spot = next(
        c for c in out.clarification.candidates if c.label == TargetLabel.PADDY_BROWN_SPOT
    )
    assert blast.signature == "Diamond-shaped, grey centre"
    assert blast.image_url is None
    assert brown_spot.signature is None
    assert brown_spot.image_url is None


async def test_out_of_scope_escalates(db_session) -> None:
    farm = await _farm(db_session)
    out = await _diagnose(db_session, farm, "out_of_scope")

    assert out.gate.outcome == "escalate"
    assert out.gate.reason_code == "OUT_OF_SCOPE"
    assert out.escalation is not None


async def test_confident_fixture_escalates_with_no_relevant_source(db_session) -> None:
    """gate.py's fail-closed fix (merged 4a4fe1a) changed this: retrieval_score
    is always None here (diagnose.py never wires retrieval to the corpus --
    see this file's docstring / the comment at the retrieval_score assignment
    in diagnose_farm()), and the gate now treats None the same as a score
    below RAG_THRESHOLD rather than skipping the check on it. A confident,
    in-scope, unambiguous prediction used to reach advise (and get refused
    with a 501, since the composer isn't built either) -- it now escalates
    honestly with NO_RELEVANT_SOURCE instead, a complete response rather than
    a refusal. This was previously (wrongly) pinned as the 501 case; see
    tests/test_gate.py for the same behaviour change at the gate.decide()
    level."""
    farm = await _farm(db_session)

    out = await _diagnose(db_session, farm, "confident")

    assert out.gate.outcome == "escalate"
    assert out.gate.reason_code == "NO_RELEVANT_SOURCE"
    assert out.escalation is not None


# --- VISION_MODEL=real, no fixture header: the real classifier path ---------
#
# get_asset_bytes() and classify() are mocked here rather than exercised for
# real: a real run needs an actual model checkpoint loaded (torch/PIL, not
# installed in every environment this suite runs in) and a real object in
# storage (MinIO/S3, not running in every environment either). These tests
# cover the ORCHESTRATION -- that diagnose_farm() calls the two in the right
# order with the right arguments when the branch is taken, and that a bad
# image_asset_id produces a real BhoomiError rather than a 500 -- not vision
# model correctness, which is Suchit's classify() to test.


async def test_real_vision_model_with_no_fixture_calls_the_real_classifier(
    db_session, monkeypatch: pytest.MonkeyPatch
) -> None:
    """VISION_MODEL=real, no X-Vision-Fixture header: the one path that must
    read the uploaded image's real bytes (expected_kind=IMAGE, not the
    AUDIO default get_asset_bytes() carries for voice/) and run them through
    classify(), instead of falling through to _resolve_topk()'s stub."""
    from app.contracts.vision import Prediction, TopK
    from app.core.routers import diagnose as diagnose_module

    monkeypatch.setattr(diagnose_module.settings, "vision_model", "real")

    farm = await _farm(db_session)
    asset = await _asset(db_session, farm)
    seen_calls: dict[str, object] = {}

    async def _fake_get_asset_bytes(session, asset_id, *, expected_kind):
        seen_calls["asset_id"] = asset_id
        seen_calls["expected_kind"] = expected_kind
        return b"fake-real-photo-bytes"

    def _fake_classify(image_bytes):
        seen_calls["image_bytes"] = image_bytes
        return TopK(
            predictions=[
                Prediction(label="paddy_blast", confidence=0.38),
                Prediction(label="paddy_brown_spot", confidence=0.33),
                Prediction(label="paddy_bacterial_leaf_blight", confidence=0.29),
            ],
            out_of_scope=False,
            model_version="fake-real-v1",
            is_stub=False,
        )

    monkeypatch.setattr(diagnose_module, "get_asset_bytes", _fake_get_asset_bytes)
    monkeypatch.setattr(diagnose_module, "classify", _fake_classify)

    payload = DiagnoseIn(image_asset_id=asset.id, lang="mr-IN")
    principal = Principal(subject=farm.farmer_id, role=Role.FARMER)
    out = await diagnose_module.diagnose_farm(
        farm_id=farm.id, payload=payload, x_vision_fixture=None,
        principal=principal, session=db_session,
    )

    assert seen_calls["asset_id"] == asset.id
    assert seen_calls["expected_kind"] == AssetKind.IMAGE
    assert seen_calls["image_bytes"] == b"fake-real-photo-bytes"
    assert out.gate.outcome == "escalate"
    assert out.gate.is_stub is False


async def test_real_vision_model_propagates_not_found_for_a_bad_asset(
    db_session, monkeypatch: pytest.MonkeyPatch
) -> None:
    """A bad image_asset_id under VISION_MODEL=real must not become a 500 --
    get_asset_bytes()'s NotFound is a BhoomiError and propagates untouched,
    not caught and rewrapped here."""
    from app.core.routers import diagnose as diagnose_module
    from app.errors import NotFound

    monkeypatch.setattr(diagnose_module.settings, "vision_model", "real")

    farm = await _farm(db_session)
    payload = DiagnoseIn(image_asset_id=uuid.uuid4(), lang="mr-IN")  # never created
    principal = Principal(subject=farm.farmer_id, role=Role.FARMER)

    with pytest.raises(NotFound):
        await diagnose_module.diagnose_farm(
            farm_id=farm.id, payload=payload, x_vision_fixture=None,
            principal=principal, session=db_session,
        )


async def test_real_vision_model_with_a_fixture_header_still_uses_the_fixture(
    db_session, monkeypatch: pytest.MonkeyPatch
) -> None:
    """VISION_MODEL=real is not sufficient on its own to take the real-
    classifier branch -- an X-Vision-Fixture header still routes through
    _resolve_topk(), which refuses it with FIXTURES_DISABLED (unchanged
    behaviour, asserted here only to pin that the new branch's condition is
    genuinely `real AND no header`, not `real` alone)."""
    from app.core.routers import diagnose as diagnose_module
    from app.errors import BhoomiError

    monkeypatch.setattr(diagnose_module.settings, "vision_model", "real")

    farm = await _farm(db_session)

    with pytest.raises(BhoomiError) as caught:
        await _diagnose(db_session, farm, "confident")

    assert caught.value.code.value == "FIXTURES_DISABLED"


# --- no advisory/clarification object on any non-advise path ----------------


async def test_no_advisory_or_clarification_field_on_any_response(db_session) -> None:
    """Only `escalation` is ever populated by this build. Asserted against
    the response body's own field set, not just the service return, per the
    task's testable-invariant list."""
    farm = await _farm(db_session)
    for fixture in ("low_confidence", "torn", "out_of_scope"):
        out = await _diagnose(db_session, farm, fixture)
        dumped = out.model_dump(exclude_none=True)
        assert "advisory" not in dumped
        assert "clarification" not in dumped
        assert "escalation" in dumped


# --- the Problem/Diagnosis record, written regardless of branch -------------


async def test_problem_and_diagnosis_are_recorded_on_the_escalate_path(db_session) -> None:
    """Renamed from test_problem_and_diagnosis_are_recorded_even_on_the_501_
    branch: the confident fixture no longer reaches a 501 (see
    test_confident_fixture_escalates_with_no_relevant_source above) -- it
    escalates. The property this test actually pins -- a real classification
    event is recorded before the response is decided, regardless of which
    branch the gate reaches -- still holds and is still worth asserting on
    this specific fixture, now against the outcome it actually produces."""
    farm = await _farm(db_session)
    out = await _diagnose(db_session, farm, "confident")
    assert out.gate.outcome == "escalate"

    problems = (
        await db_session.execute(select(Problem).where(Problem.farm_id == farm.id))
    ).scalars().all()
    assert len(problems) == 1
    assert problems[0].label == "paddy_blast"
    assert problems[0].problem_type == "disease"

    diagnoses = (
        await db_session.execute(select(Diagnosis).where(Diagnosis.problem_id == problems[0].id))
    ).scalars().all()
    assert len(diagnoses) == 1
    assert diagnoses[0].gate_outcome == GateOutcome.ESCALATE
    assert diagnoses[0].is_stub is True


async def test_repeated_diagnose_on_the_same_label_reuses_the_open_problem(db_session) -> None:
    """_upsert_open_problem: a second diagnose call against the same
    (farm, label) must not create a duplicate Problem row."""
    farm = await _farm(db_session)
    first = await _diagnose(db_session, farm, "low_confidence")
    second = await _diagnose(db_session, farm, "torn")

    assert first.problem_id == second.problem_id
    problems = (
        await db_session.execute(select(Problem).where(Problem.farm_id == farm.id))
    ).scalars().all()
    assert len(problems) == 1


# --- the prior clamp holds through the full orchestration -------------------


async def test_prior_bias_is_applied_and_clamped_through_the_orchestration(db_session) -> None:
    """A raw bias big enough to flip low_confidence's top-1 across FLOOR would
    turn escalate into something else -- docs/DESIGN.md §11. Seed a
    LabelPrior row whose bias, unclamped, would do exactly that; confirm the
    orchestration still escalates BELOW_FLOOR -- the clamp held end to end,
    not just in prior.py's own unit tests."""
    farm = await _farm(db_session)
    # low_confidence: paddy_blast at 0.38, FLOOR is well above 0.38 + any
    # single-digit-net-confirmation bias -- 50 confirmed vs 0 corrected is
    # far past PRIOR_FULL_CONFIDENCE_COUNT, i.e. the largest bias the system
    # can produce, and it must still not cross FLOOR.
    session_row = LabelPrior(
        region=farm.region, crop=Crop.PADDY.value, growth_stage="tillering",
        label="paddy_blast", confirmed_count=50, corrected_count=0,
    )
    db_session.add(session_row)
    await db_session.flush()

    out = await _diagnose(db_session, farm, "low_confidence")

    assert out.gate.outcome == "escalate"
    assert out.gate.reason_code == "BELOW_FLOOR"
    # The bias was applied (alternatives reflect the post-prior confidence,
    # not the raw fixture value) but stayed clamped under FLOOR.
    top1 = out.gate.alternatives[0]
    assert top1.label == "paddy_blast"
    assert top1.confidence > 0.38
    from app.config import FLOOR

    assert top1.confidence < FLOOR
