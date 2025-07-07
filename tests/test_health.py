import os

# Environment variables must be set before importing modules from devonboarder.
os.environ.setdefault("APP_ENV", "development")
os.environ.setdefault("JWT_SECRET_KEY", "devsecret")

from fastapi.testclient import TestClient
from devonboarder.auth_service import create_app as create_auth_app
from xp.api import create_app as create_xp_app


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
