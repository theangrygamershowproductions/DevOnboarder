import importlib
import os
import sys
from pathlib import Path

from fastapi.testclient import TestClient
import requests

# Ensure the repository root is on the import path
sys.path.insert(0, str(Path(__file__).resolve().parents[1]))

# Ensure required environment variables exist before importing the service
os.environ.setdefault("APP_ENV", "development")
os.environ.setdefault("JWT_SECRET_KEY", "devsecret")

from devonboarder.auth_service import create_app


def test_check_headers(monkeypatch):
    """Verify check_headers.main succeeds against the auth service."""
    app = create_app()
    client = TestClient(app)

    # Patch requests.get to route through the TestClient
    monkeypatch.setattr(requests, "get", lambda url, timeout=5: client.get(url))

    # Point the script to the TestClient's URL
    monkeypatch.setenv("CHECK_HEADERS_URL", f"{client.base_url}/api/user")
    module = importlib.import_module("scripts.check_headers")
    importlib.reload(module)

    assert module.main() is None
