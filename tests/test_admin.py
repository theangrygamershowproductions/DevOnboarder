# PATCHED v0.1.41 tests/test_admin.py — use env fixture

"""Integration tests for admin verification endpoints."""

import sys
from pathlib import Path
from fastapi.testclient import TestClient
import pytest

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))


@pytest.fixture()
def client(apply_common_env):
    from backend.main import app  # noqa: E402

    return TestClient(app)


def test_admin_endpoints(client: TestClient):
    """Verify admin endpoints return expected data."""
    create = client.post("/api/verification/request", json={"user_id": "u1"})
    assert create.status_code == 200

    ver_resp = client.get(
        "/api/admin/verification",
        headers={"X-Is-Admin": "true"},
    )
    assert ver_resp.status_code == 200
    ver_data = ver_resp.json()
    assert isinstance(ver_data, list)
    assert {"id", "user_id", "type", "status"} <= set(ver_data[0].keys())

    users_resp = client.get(
        "/api/admin/users",
        headers={"X-Is-Admin": "true"},
    )
    assert users_resp.status_code == 200
    assert isinstance(users_resp.json(), list)
