# PATCHED v0.1.59 tests/test_session_management.py — adapt SQLAlchemy check

import sys
from pathlib import Path
from fastapi.testclient import TestClient
from sqlalchemy.orm.session import _SessionCloseState
import pytest

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))


@pytest.fixture()
def session_tracker(monkeypatch):
    from backend.models.db import SessionLocal as Original

    sessions = []

    def factory():
        session = Original()
        sessions.append(session)
        return session

    monkeypatch.setattr("backend.src.dependencies.SessionLocal", factory)
    return sessions


def test_session_closed_after_request(apply_common_env, session_tracker):
    from backend.main import app

    client = TestClient(app)
    resp = client.post("/api/verification/request", json={"user_id": "u1"})
    assert resp.status_code == 200
    assert session_tracker[0]._close_state is not _SessionCloseState.ACTIVE
