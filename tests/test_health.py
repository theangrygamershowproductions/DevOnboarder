from fastapi.testclient import TestClient
from devonboarder.auth_service import create_app as create_auth_app
from devonboarder.xp_api import create_app as create_xp_app


def test_auth_health():
    client = TestClient(create_auth_app())
    resp = client.get("/health")
    assert resp.status_code == 200
    assert resp.json() == {"status": "ok"}


def test_xp_health():
    client = TestClient(create_xp_app())
    resp = client.get("/health")
    assert resp.status_code == 200
    assert resp.json() == {"status": "ok"}
