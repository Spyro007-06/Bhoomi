"""Case confirmation and queue models. docs/API_CONTRACT.md §13.

OWNER: Shreekumar.

`GET /cases/{id}` — the bundle — is NOT here. That is Thaariha's F12.

`RequestInfoIn`/`RequestInfoOut` are also F12 (Thaariha): §13 names
`POST /cases/{id}/request-info` but never specifies a shape for it (absent
from §16's endpoint index too) — see CaseNote's docstring in
app/core/models.py for the gap this documented, minimal shape fills.
"""

from __future__ import annotations

import uuid
from datetime import datetime

from pydantic import BaseModel, Field, model_validator

from app.contracts.enums import (
    AssetKind,
    CaseStatus,
    ConfirmationVerdict,
    ProblemStatus,
    TargetLabel,
)


class ConfirmIn(BaseModel):
    """Both §13 request shapes: confirming and correcting."""

    verdict: ConfirmationVerdict
    corrected_label: TargetLabel | None = None
    treatment: str | None = None
    notes: str | None = None

    @model_validator(mode="after")
    def _corrected_needs_a_label(self) -> ConfirmIn:
        """Mirrors the ck_confirmation_corrected_requires_label CHECK.

        The database is the enforcement; this exists so the caller gets a 422
        naming the field rather than a 500 from an IntegrityError.
        """
        if self.verdict == ConfirmationVerdict.CORRECTED and self.corrected_label is None:
            raise ValueError("corrected_label is required when verdict is 'corrected'")
        if self.verdict == ConfirmationVerdict.CONFIRMED and self.corrected_label is not None:
            raise ValueError("corrected_label must be omitted when verdict is 'confirmed'")
        return self


class ConfirmOut(BaseModel):
    case_id: uuid.UUID
    status: CaseStatus
    problem_status: ProblemStatus
    confirmation_id: uuid.UUID
    spread_alerts_issued: int = Field(
        description="Farms warned by the F6 fan-out: new alerts plus upgraded ones."
    )


class CaseQueueItem(BaseModel):
    case_id: uuid.UUID
    problem_id: uuid.UUID
    farm_id: uuid.UUID
    region: str
    label: TargetLabel | None = None
    status: CaseStatus
    queue_position: int | None = None
    eta_minutes: int | None = None
    created_at: datetime


class CaseQueueOut(BaseModel):
    cases: list[CaseQueueItem]


class RequestInfoIn(BaseModel):
    """`POST /cases/{id}/request-info` request. `message` is the free-text
    ask ("Can you send a photo of the underside of the leaf?");
    `requested_assets` optionally names what kind of evidence would answer
    it, so a client can prompt the farmer's camera/mic directly rather than
    making them re-read the message to figure out what to attach."""

    message: str = Field(min_length=1)
    requested_assets: list[AssetKind] | None = None


class RequestInfoOut(BaseModel):
    """Echoes the case's own status, unchanged — request-info does not
    resolve or reassign a case (CaseStatus has no "info requested" member;
    see CaseNote's docstring). `note_id` is what a client polls the bundle's
    observations against, or displays in a case's own note history."""

    case_id: uuid.UUID
    status: CaseStatus
    note_id: uuid.UUID
