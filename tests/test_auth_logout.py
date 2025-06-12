# PATCHED v0.1.38 tests/test_auth_logout.py — use env fixture

"""Verify that logout revokes JWT tokens."""

from fastapi.testclient import TestClient
from pathlib import Path
import sys
import pytest

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))


@pytest.fixture()
def client(apply_common_env):
    from auth.service import app  # noqa: E402

    return TestClient(app)


def test_logout_invalidates_token(client: TestClient):
    """Tokens should be unusable after the logout endpoint is called."""
    login_resp = client.post(
        "/api/auth/login", data={"username": "demo", "password": "password"}
    )
    token = login_resp.json()["access_token"]

    user_resp = client.get(
        "/api/auth/user", headers={"Authorization": f"Bearer {token}"}
    )
    assert user_resp.status_code == 200

    logout_resp = client.post(
        "/api/auth/logout", headers={"Authorization": f"Bearer {token}"}
    )
    assert logout_resp.status_code == 200

    user_resp2 = client.get(
        "/api/auth/user", headers={"Authorization": f"Bearer {token}"}
    )
    assert user_resp2.status_code == 401
