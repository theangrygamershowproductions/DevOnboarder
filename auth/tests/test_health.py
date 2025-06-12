# PATCHED v0.1.2 auth/tests/test_health.py — set required env

"""Check that the auth service health endpoint responds properly."""

from fastapi.testclient import TestClient
from pathlib import Path
import sys

sys.path.insert(0, str(Path(__file__).resolve().parents[2]))
import os  # noqa: E402

os.environ.setdefault("OPENAI_API_KEY", "test")
os.environ.setdefault("FASTAPI_SECRET_KEY", "secret")
os.environ.setdefault("REDIS_MOCK", "1")
from auth.app.main import app  # noqa: E402

client = TestClient(app)


def test_health_endpoint():
    """Health endpoint should return a 200 status."""
    response = client.get("/health")
    assert response.status_code == 200
    assert response.json() == {"status": "ok"}
