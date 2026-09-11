"""case_note table — F12's POST /cases/{id}/request-info

docs/API_CONTRACT.md §13 names this endpoint in its ownership-note prose but
never gives it a request/response shape, and §16's endpoint index omits it
entirely — a genuine gap in the frozen doc, not a disagreement to resolve by
picking a side. This migration adds the minimal table an agronomist's
"I need more information before I can confirm this" needs: one row per
request, attached to the case, carrying a free-text message and an optional
list of asset kinds requested from the farmer.

Deliberately does NOT touch case_status or the CaseStatus enum — both are
frozen (docs/API_CONTRACT.md §1), and asking for more information neither
resolves nor reassigns a case.

Revision ID: 0012_case_note
Revises: 0011_registered_use_dates
Create Date: 2026-09-11
"""

from __future__ import annotations

from collections.abc import Sequence

import sqlalchemy as sa

from alembic import op

revision: str = "0012_case_note"
down_revision: str | None = "0011_registered_use_dates"
branch_labels: str | Sequence[str] | None = None
depends_on: str | Sequence[str] | None = None


def upgrade() -> None:
    op.create_table(
        "case_note",
        sa.Column(
            "id", sa.Uuid(), server_default=sa.text("gen_random_uuid()"),
            primary_key=True, nullable=False,
        ),
        sa.Column("case_id", sa.Uuid(), nullable=False),
        sa.Column("author_id", sa.Uuid(), nullable=False),
        sa.Column("message", sa.Text(), nullable=False),
        sa.Column("requested_assets", sa.ARRAY(sa.Text()), nullable=True),
        sa.Column(
            "created_at",
            sa.TIMESTAMP(timezone=True),
            nullable=False,
            server_default=sa.text("now()"),
        ),
        sa.ForeignKeyConstraint(["case_id"], ["case.id"], ondelete="CASCADE"),
        sa.ForeignKeyConstraint(["author_id"], ["app_user.id"], ondelete="RESTRICT"),
    )
    op.create_index("ix_case_note_case_id", "case_note", ["case_id"])


def downgrade() -> None:
    op.drop_index("ix_case_note_case_id", table_name="case_note")
    op.drop_table("case_note")
