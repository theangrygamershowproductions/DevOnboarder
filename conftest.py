# PATCHED v0.1.54 conftest.py — add Redis mock env

"""Ensure required test dependencies are installed before running pytest."""
import importlib.util as iu
import sys
import os

import pytest
from utils.env import get_settings

required = ["fastapi", "httpx"]
missing = [pkg for pkg in required if iu.find_spec(pkg) is None]
if missing:
    pkgs = ", ".join(missing)
    sys.exit(f"Missing deps: {pkgs}. Run ./scripts/setup-dev.sh first.")


ENV_DEFAULTS = {
    "DISCORD_CLIENT_ID": "test",
    "DISCORD_CLIENT_SECRET": "test",
    "DATABASE_URL": "sqlite:///:memory:",
    "VERIFICATION_DB_URL": "sqlite:///:memory:",
    "REDIS_URL": "redis://localhost:6379/0",
    "REDIS_MOCK": "1",
    "JWT_SECRET": "secret",
    "JWT_ALGORITHM": "HS256",
    "JWT_EXPIRATION": "3600",
    "OWNER_ROLE_ID": "1",
    "ADMINISTRATOR_ROLE_ID": "2",
    "VERIFIED_USER_ROLE_ID": "3",
    "VERIFIED_MEMBER_ROLE_ID": "4",
    "ALLOWED_ORIGINS": "http://localhost",
    "OPENAI_API_KEY": "test",
    "FASTAPI_SECRET_KEY": "secret",
}


@pytest.fixture()
def apply_common_env(monkeypatch):
    """Set default environment variables for tests."""
    for var, value in ENV_DEFAULTS.items():
        monkeypatch.setenv(var, value)
    get_settings()
    yield
