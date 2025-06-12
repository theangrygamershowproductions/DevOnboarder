# PATCHED v0.1.1 backend/models/init_db.py — DB initialization script

"""Create required tables for verification flow."""
from .verification import Base, engine


def init_db() -> None:
    """Create tables defined in the verification models."""
    Base.metadata.create_all(bind=engine)


if __name__ == "__main__":
    init_db()
