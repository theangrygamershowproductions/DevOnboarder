# PATCHED v0.1.1 backend/models/verification.py — Verification model

"""SQLAlchemy model for tracking user verification requests."""

from datetime import datetime, UTC
from sqlalchemy import Column, Integer, String, DateTime

from .db import Base, engine


class VerificationRequest(Base):
    """Database table storing pending verification requests."""

    __tablename__ = "verification_requests"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(String, nullable=False)
    verification_type = Column(String, nullable=True)
    status = Column(String, default="pending")
    requested_at = Column(DateTime, default=lambda: datetime.now(UTC))
    updated_at = Column(DateTime, default=lambda: datetime.now(UTC))


# Called directly when imported to ensure table exists
Base.metadata.create_all(bind=engine)
