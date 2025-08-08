"""Test CORS utility functions."""

from utils.cors import get_cors_origins


def test_get_cors_origins_with_env_var(monkeypatch):
    """Test CORS origins from environment variable."""
    env_value = "http://localhost:3000,https://example.com,  https://another.com  "
    monkeypatch.setenv("CORS_ALLOW_ORIGINS", env_value)

    origins = get_cors_origins()

    expected = ["http://localhost:3000", "https://example.com", "https://another.com"]
    assert origins == expected


def test_get_cors_origins_development_mode(monkeypatch):
    """Test CORS origins in development mode."""
    monkeypatch.delenv("CORS_ALLOW_ORIGINS", raising=False)
    monkeypatch.setenv("APP_ENV", "development")

    origins = get_cors_origins()

    assert origins == ["*"]


def test_get_cors_origins_production_mode(monkeypatch):
    """Test CORS origins in production mode (no env vars)."""
    monkeypatch.delenv("CORS_ALLOW_ORIGINS", raising=False)
    monkeypatch.delenv("APP_ENV", raising=False)

    origins = get_cors_origins()

    assert origins == []


def test_get_cors_origins_empty_string(monkeypatch):
    """Test CORS origins with empty string."""
    monkeypatch.setenv("CORS_ALLOW_ORIGINS", "")
    monkeypatch.delenv("APP_ENV", raising=False)  # Ensure not in development mode

    origins = get_cors_origins()

    assert origins == []


def test_get_cors_origins_whitespace_only(monkeypatch):
    """Test CORS origins with whitespace only."""
    monkeypatch.setenv("CORS_ALLOW_ORIGINS", "  ,  ,  ")

    origins = get_cors_origins()

    assert origins == []
