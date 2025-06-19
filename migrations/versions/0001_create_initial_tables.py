from __future__ import annotations

from alembic import op
import sqlalchemy as sa

revision = "0001"
down_revision = None
branch_labels = None
depends_on = None


def upgrade() -> None:
    op.create_table(
        "users",
        sa.Column("id", sa.Integer, primary_key=True),
        sa.Column("username", sa.String, nullable=False, unique=True),
        sa.Column("password_hash", sa.String, nullable=False),
        sa.Column(
            "is_admin",
            sa.Boolean,
            nullable=False,
            server_default=sa.text("false"),
        ),
    )
    op.create_table(
        "contributions",
        sa.Column("id", sa.Integer, primary_key=True),
        sa.Column("user_id", sa.Integer, sa.ForeignKey("users.id")),
        sa.Column("description", sa.String, nullable=False),
    )
    op.create_table(
        "xp_events",
        sa.Column("id", sa.Integer, primary_key=True),
        sa.Column("user_id", sa.Integer, sa.ForeignKey("users.id")),
        sa.Column("xp", sa.Integer, nullable=False, server_default="0"),
    )


def downgrade() -> None:
    op.drop_table("xp_events")
    op.drop_table("contributions")
    op.drop_table("users")
