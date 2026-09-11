"""`POST /problems/{id}/clarify` request/response models. docs/API_CONTRACT.md §7.

OWNER: Thaariha.

Two response shapes (`resolved` discriminates which). The frozen doc's own
"Resolved" example always carries a populated `advisory` — this router adds
one case the doc doesn't spell out: the diagnosis resolves (a label was
picked) but composing an advisory for it fails (no relevant corpus source,
or compose() itself rejects). `resolved` stays `true` either way — the
Doubt Doctor's job (discriminate between two labels) succeeded independent
of whether F7 could then produce grounded advice — and `advisory`/
`escalation` are both optional so that case can carry an escalation instead
of a lie. See routers/clarify.py's own docstring for the reasoning.
"""

from __future__ import annotations

import uuid

from pydantic import BaseModel

from app.contracts.enums import CueAnswer, ProblemSeverity, TargetLabel
from app.core.schemas.diagnose import EscalationOut
from app.core.schemas.problems import AdvisoryOut, CitationOut


class ClarifyIn(BaseModel):
    cue_id: uuid.UUID
    answer: CueAnswer


class ResolvedDiagnosisOut(BaseModel):
    label: TargetLabel
    severity: ProblemSeverity | None = None
    resolved_by: str = "field_observation"


class ClarifyResolvedOut(BaseModel):
    resolved: bool = True
    diagnosis: ResolvedDiagnosisOut
    observation_id: uuid.UUID
    advisory: AdvisoryOut | None = None
    citations: list[CitationOut] = []
    escalation: EscalationOut | None = None
    spoken_summary: str | None = None


class ClarifyNotResolvedOut(BaseModel):
    resolved: bool = False
    reason: str = "answer_did_not_discriminate"
    observation_id: uuid.UUID
    escalation: EscalationOut
    spoken_summary: str | None = None
