"""Referral request and response models. docs/API_CONTRACT.md §14.

OWNER: Tharun.
"""

from __future__ import annotations

from pydantic import BaseModel, Field


class ReferralOut(BaseModel):
    """Referral contact card item (KVK, diagnostic lab, or helpline). §14."""

    kind: str = Field(description="kvk | lab | helpline")
    name: str
    phone: str
    distance_km: float | None = None
    accepts_samples: bool = False
    address: str | None = None


class ReferralListOut(BaseModel):
    """docs/API_CONTRACT.md §14 — GET /farms/{id}/referrals response."""

    referrals: list[ReferralOut]
