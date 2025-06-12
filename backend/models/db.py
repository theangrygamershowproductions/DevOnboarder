# PATCHED v0.1.2 backend/models/db.py — read DB url from env

"""SQLAlchemy engine and session setup for the verification database."""

import os
from sqlalchemy import create_engine
from sqlalchemy.orm import declarative_base, sessionmaker

DATABASE_URL = os.getenv("VERIFICATION_DB_URL", "sqlite:///verification.db")
engine = create_engine(DATABASE_URL, connect_args={"check_same_thread": False})
SessionLocal = sessionmaker(bind=engine, autocommit=False, autoflush=False)

Base = declarative_base()
