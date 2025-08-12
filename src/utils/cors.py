"""Utility for loading allowed CORS origins from environment variables."""

from __future__ import annotations

from .environment import get_cors_origins as env_get_cors_origins


def get_cors_origins() -> list[str]:
    """Return allowed CORS origins from the environment.
    This function maintains backward compatibility while leveraging
    the new comprehensive environment system.
    """
    return env_get_cors_origins()
