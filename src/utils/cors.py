from __future__ import annotations

import os


def _get_cors_origins() -> list[str]:
    """Return allowed CORS origins from the environment."""
    origins = os.getenv("CORS_ALLOW_ORIGINS")
    if origins:
        return [o.strip() for o in origins.split(",") if o.strip()]
    if os.getenv("APP_ENV") == "development":
        return ["*"]
    return []
