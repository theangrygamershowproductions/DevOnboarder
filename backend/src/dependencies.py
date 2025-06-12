# PATCHED v0.1.0 backend/src/dependencies.py — session dependency

"""Database session dependency helpers."""

from contextlib import asynccontextmanager

from backend.models.db import SessionLocal


@asynccontextmanager
async def get_db_session():
    """Yield a database session and ensure closure."""
    session = SessionLocal()
    try:
        yield session
    finally:
        session.close()
