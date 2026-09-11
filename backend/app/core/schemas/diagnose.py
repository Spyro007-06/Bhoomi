"""POST /farms/{id}/diagnose response models. docs/API_CONTRACT.md §6.

OWNER: Shreekumar. Orchestration only — the shapes here cover exactly what
this build's orchestration produces: `escalate`, `advise` (F7's composer is
now wired — see app/core/routers/diagnose.py), and `clarify` when no
matching DistinguishingCue exists (the only reachable path while that table
is empty). A populated `clarification` (a cue WAS found, F4's Doubt Doctor
*question rendering*) is still not modelled here — that is a different
feature from F4's *answer resolution*, which POST /problems/{id}/clarify
(routers/clarify.py) now serves; see diagnose.py's module docstring.
"""

from __future__ import annotations

import uuid

from pydantic import BaseModel, Field

from app.contracts.enums import ProblemSeverity, ProblemType, TargetLabel
from app.contracts.vision import Prediction
from app.core.schemas.problems import AdvisoryOut, CitationOut


class DiagnoseIn(BaseModel):
    """docs/API_CONTRACT.md §6. `description_asset_id` / `description_text`
    are optional supplementary context (a voice note or typed note alongside
    the photo) — unused by this build's orchestration, which does not touch
    NLU or retrieval, but accepted so a client sending them is not refused."""

    image_asset_id: uuid.UUID
    description_asset_id: uuid.UUID | None = None
    description_text: str | None = None
    lang: str


class GateOut(BaseModel):
    """Mirrors contract C3's GateDecision. Not GateDecision itself: this is
    the HTTP-facing shape, and outcome/reason_code here can differ from what
    decide() returned — see EscalationOut's docstring for the one case where
    that happens (clarify, no cue found)."""

    outcome: str
    confidence: float = Field(ge=0.0, le=1.0)
    threshold_applied: float
    reason_code: str
    alternatives: list[Prediction]
    is_stub: bool


class EscalationOut(BaseModel):
    """docs/API_CONTRACT.md §6's escalation block.

    `assigned_to` is rendered "agronomist:<slug>" from the assigned User's
    email domain (no dedicated column for this exists on User — see
    app/core/routers/diagnose.py's _agronomist_slug()). `None` when the
    queue has no agronomist to assign, honestly, not a placeholder.
    """

    case_id: uuid.UUID
    assigned_to: str | None
    queue_position: int | None
    eta_minutes: int | None


class DiagnosisOut(BaseModel):
    """docs/API_CONTRACT.md §6's `diagnosis` block, `advise` branch only.

    `severity` is None -- no severity classifier exists in this build (an
    honest gap, not a placeholder; see app/intelligence/bundle.py's IMAGE
    URLS note for the same convention). `resolved_by` is fixed to "model"
    here, distinct from clarify.py's ResolvedDiagnosisOut, which is always
    "field_observation" -- the two routes reach a label by different means
    and the wire value says which.
    """

    label: TargetLabel
    severity: ProblemSeverity | None = None
    resolved_by: str = "model"


class DiagnoseOut(BaseModel):
    """docs/API_CONTRACT.md §6. `problem_type` is included on every branch —
    the frozen doc's clarify/escalate examples omit it, read as abbreviation
    rather than exclusion: Problem always has a type, and the field is
    genuinely meaningful on every branch, not conditional on gate outcome.

    `diagnosis`/`advisory`/`citations` are populated on the `advise` branch
    only (`None`/`[]` on every other branch — omitted from the wire response
    via `response_model_exclude_none`, same convention as `escalation`).
    `spoken_summary` is Shruthi's (F9) and stays null until she wires it."""

    gate: GateOut
    problem_id: uuid.UUID
    problem_type: ProblemType
    diagnosis: DiagnosisOut | None = None
    advisory: AdvisoryOut | None = None
    citations: list[CitationOut] | None = None
    escalation: EscalationOut | None = None
    spoken_summary: None = Field(
        default=None, description="F9, owner Shruthi. Null until wired."
    )
