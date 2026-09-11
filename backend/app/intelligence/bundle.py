"""Case bundle compiler (F12) — what the agronomist opens.

OWNER: Thaariha. Spec: docs/API_CONTRACT.md §12.

Contract rule: every field is populated from live data. No placeholder strings —
no "Unregistered Farmer", no empty history array on a case that has history, no
null confidence where a diagnosis exists. A bundle failing this on a real case is
a failed feature, not a cosmetic issue.

docs/DESIGN.md §13 lists this among the two tests that exist because both have
failed before in this project's history.

KNOWN GAP, stated rather than papered over: docs/API_CONTRACT.md §12's example
bundle carries a `treatments_tried` array ("Field drained 48h", "Nitrogen
withheld"). No table in app/core/models.py stores free-text treatment actions a
farmer took before escalation — Confirmation.treatment is the agronomist's
post-hoc instruction, not the farmer's prior actions, and FollowUp.response is
an enum (improved/no_change/got_worse), not free text. This function returns
`[]` for that field until a real data source exists; that is the honest
current answer, not a fabricated one, but it is a genuine open question for
whoever owns the farmer-facing "what have you tried" capture — not something
to guess at here.
"""

from __future__ import annotations

from app.contracts.vision import Prediction
from app.core.models import Asset, Diagnosis, Farm, LabelCheck, Observation, Problem
from app.core.schemas.bundle import (
    BundleFarm,
    BundleGate,
    BundleImage,
    BundleLabelCheck,
    BundleObservation,
    BundleProblem,
    CaseBundleOut,
)


def compile_bundle(
    case_id,
    status,
    farm: Farm,
    problem: Problem,
    diagnosis: Diagnosis | None,
    observations: list[Observation],
    images: list[Asset],
    label_checks: list[LabelCheck],
    followups: list,
) -> CaseBundleOut:
    """Assemble the agronomist's case bundle from live records.

    core/ reads the rows and passes them in; this function shapes them. Return
    shape is docs/API_CONTRACT.md §12.

    Args:
        case_id, status: the Case row's id/status — the caller (cases.py)
            already has the Case open, so this takes the two bundle-relevant
            fields rather than the whole ORM row.
        farm, problem: the farm and problem this case is about.
        diagnosis: the most recent Diagnosis for this problem, or None if the
            case was escalated from a follow-up rather than a photo — see
            Confirmation.model_label's docstring for the same nullability.
        observations: every Observation on this problem, any order.
        images: every Asset (kind=image) attached to this problem's diagnoses
            and follow-ups.
        label_checks: every LabelCheck on this problem.
        followups: every FollowUp on this problem, used only for the trend.

    Returns:
        CaseBundleOut — every field populated from what was passed in. Empty
        lists mean "genuinely no history of that kind for this case", not
        "not implemented".
    """
    model_hypotheses: list[Prediction] = []
    gate: BundleGate | None = None
    if diagnosis is not None:
        model_hypotheses = [
            Prediction(label=p["label"], confidence=p["confidence"])
            for p in diagnosis.topk.get("predictions", [])
        ]
        gate = BundleGate(
            outcome=diagnosis.gate_outcome.value
            if hasattr(diagnosis.gate_outcome, "value")
            else str(diagnosis.gate_outcome),
            reason_code=diagnosis.reason_code.value
            if hasattr(diagnosis.reason_code, "value")
            else str(diagnosis.reason_code),
            threshold_applied=float(diagnosis.gate_confidence),
        )

    field_observations = [
        BundleObservation(question=o.question, answer=o.answer, at=o.created_at)
        for o in sorted(observations, key=lambda o: o.created_at)
    ]

    bundle_images = [
        BundleImage(asset_id=a.id, url=None, at=a.uploaded_at or a.created_at)
        for a in sorted(images, key=lambda a: a.uploaded_at or a.created_at)
    ]

    bundle_label_checks = [
        BundleLabelCheck(
            ingredient=lc.extracted.get("active_ingredient"),
            verdict=lc.verdict_code.value if lc.verdict_code else None,
            at=lc.created_at,
        )
        for lc in sorted(label_checks, key=lambda lc: lc.created_at)
    ]

    followup_trend: str | None = None
    answered = [f for f in followups if f.response is not None]
    if answered:
        latest = max(answered, key=lambda f: f.responded_at or f.due_at)
        followup_trend = (
            latest.response.value if hasattr(latest.response, "value") else str(latest.response)
        )

    return CaseBundleOut(
        case_id=case_id,
        status=status,
        farm=BundleFarm(
            id=farm.id,
            crop=farm.crop.value if hasattr(farm.crop, "value") else str(farm.crop),
            variety=farm.variety,
            growth_stage=farm.growth_stage,
            region=farm.region,
        ),
        problem=BundleProblem(
            id=problem.id,
            type=problem.problem_type,
            label=problem.label.value if problem.label else None,
            severity=problem.severity,
            status=problem.status,
            opened_at=problem.opened_at,
        ),
        model_hypotheses=model_hypotheses,
        gate=gate,
        field_observations=field_observations,
        images=bundle_images,
        # See module docstring's KNOWN GAP — no data source exists yet.
        treatments_tried=[],
        label_checks=bundle_label_checks,
        followup_trend=followup_trend,
        spoken_summary=None,
    )
