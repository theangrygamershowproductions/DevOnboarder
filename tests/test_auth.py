# PATCHED v0.1.24 tests/test_auth.py — use env fixture

"""Integration tests for the authentication service."""

import os
import sys
from pathlib import Path
from fastapi.testclient import TestClient

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))

# ensure environment variables for JWT
os.environ.setdefault("JWT_SECRET", "testsecret")
os.environ.setdefault("JWT_ALGORITHM", "HS256")
os.environ.setdefault("JWT_EXPIRATION", "3600")
os.environ.setdefault("OPENAI_API_KEY", "test")
os.environ.setdefault("FASTAPI_SECRET_KEY", "secret")
os.environ.setdefault("REDIS_MOCK", "1")

import pytest


@pytest.fixture()
def client(apply_common_env):
    from auth.app import app  # noqa: E402

    return TestClient(app)


def test_login_and_get_user(client: TestClient):
    """Ensure login returns a token and user endpoint uses it."""
    resp = client.post(
        "/api/auth/login", data={"username": "demo", "password": "password"}
    )
    assert resp.status_code == 200
    token = resp.json()["access_token"]
    assert token

    user_resp = client.get(
        "/api/auth/user", headers={"Authorization": f"Bearer {token}"}
    )
    assert user_resp.status_code == 200
    data = user_resp.json()
    assert data["username"] == "demo"
