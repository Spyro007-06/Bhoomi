"""`POST /advisory/query` request/response models. docs/API_CONTRACT.md §8.

OWNER: Thaariha. A standalone farmer question — not tied to a Problem, so
unlike the advisory nested in a diagnose/clarify response, this one is never
persisted to the `advisory` table (that FK is NOT NULL against `problem`,
and the contract's own request shape carries no `problem_id`). `id`/
`created_at` on the returned `AdvisoryOut` are generated fresh for the
response rather than read back from a row that was never written — an
honest ephemeral id, not a lie about persistence.
"""

from __future__ import annotations

import uuid

from pydantic import BaseModel

from app.core.schemas.problems import AdvisoryOut, CitationOut


class AdvisoryQueryIn(BaseModel):
    farm_id: uuid.UUID
    query_text: str
    lang: str


class AdvisoryRetrievedOut(BaseModel):
    retrieved: bool = True
    advisory: AdvisoryOut
    citations: list[CitationOut]
    spoken_summary: str | None = None


class AdvisoryNotRetrievedOut(BaseModel):
    retrieved: bool = False
    reason: str = "no_relevant_source"
    escalation_offered: bool = True
    spoken_summary: str | None = None
