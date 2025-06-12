# PATCHED v0.1.12 tests/test_env.py — Ensure env variables exist

"""Test environment variable validation for the backend."""
from utils.env import Settings
from pydantic import ValidationError
import pytest

REQUIRED_VARS = [
    "DISCORD_CLIENT_ID",
    "DISCORD_CLIENT_SECRET",
    "DATABASE_URL",
    "REDIS_URL",
    "JWT_SECRET",
    "JWT_ALGORITHM",
    "JWT_EXPIRATION",
    "OWNER_ROLE_ID",
    "ADMINISTRATOR_ROLE_ID",
    "VERIFIED_USER_ROLE_ID",
    "VERIFIED_MEMBER_ROLE_ID",
    "ALLOWED_ORIGINS",
    "OPENAI_API_KEY",
    "FASTAPI_SECRET_KEY",
]


def test_env_validation(monkeypatch):
    """Validate that Settings loads when all env vars are present."""
    for var in REQUIRED_VARS:
        if var == "JWT_EXPIRATION":
            value = "3600"
        elif var == "ALLOWED_ORIGINS":
            value = "http://localhost"
        else:
            value = "test"
        monkeypatch.setenv(var, value)
    settings = Settings(_env_file=None)
    assert settings.JWT_SECRET == "test"


def test_missing_variable_raises(monkeypatch):
    """Missing required env variables should trigger a ValidationError."""
    for var in REQUIRED_VARS:
        if var == "JWT_EXPIRATION":
            value = "3600"
        elif var == "ALLOWED_ORIGINS":
            value = "http://localhost"
        else:
            value = "test"
        monkeypatch.setenv(var, value)
    monkeypatch.delenv("JWT_SECRET")
    with pytest.raises(ValidationError):
        Settings(_env_file=None)
