"""GET /cases/{id} response models. docs/API_CONTRACT.md §12.

OWNER: Thaariha. The bundle is the part of F12 with judgement in it (see
docs/API_CONTRACT.md §13's ownership note) — app/core/routers/cases.py's
confirm/queue endpoints are Shreekumar's and live in app/core/schemas/cases.py.
"""

from __future__ import annotations

import uuid
from datetime import datetime

from pydantic import BaseModel

from app.contracts.enums import CaseStatus, ProblemSeverity, ProblemStatus, ProblemType
from app.contracts.vision import Prediction


class BundleFarm(BaseModel):
    id: uuid.UUID
    crop: str
    variety: str | None
    growth_stage: str
    region: str


class BundleProblem(BaseModel):
    id: uuid.UUID
    type: ProblemType
    label: str | None
    severity: ProblemSeverity | None
    status: ProblemStatus
    opened_at: datetime


class BundleGate(BaseModel):
    outcome: str
    reason_code: str
    threshold_applied: float


class BundleObservation(BaseModel):
    question: str | None
    answer: str | None
    at: datetime


class BundleImage(BaseModel):
    asset_id: uuid.UUID
    url: str | None
    at: datetime


class BundleLabelCheck(BaseModel):
    ingredient: str | None
    verdict: str | None
    at: datetime


class CaseBundleOut(BaseModel):
    """docs/API_CONTRACT.md §12. Every field populated from live data — no
    placeholder strings, no empty array standing in for absent history."""

    case_id: uuid.UUID
    status: CaseStatus
    farm: BundleFarm
    problem: BundleProblem
    model_hypotheses: list[Prediction]
    gate: BundleGate | None
    field_observations: list[BundleObservation]
    images: list[BundleImage]
    treatments_tried: list[str]
    label_checks: list[BundleLabelCheck]
    followup_trend: str | None
    spoken_summary: str | None = None
