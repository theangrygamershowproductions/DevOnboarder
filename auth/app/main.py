# PATCHED v0.2.6 auth/app/main.py — Re-export auth FastAPI instance

"""Start the auth service with environment defaults for tests."""
import os

env_defaults = {
    "DISCORD_CLIENT_ID": "test",
    "DISCORD_CLIENT_SECRET": "test",
    "DATABASE_URL": "sqlite:///:memory:",
    "REDIS_URL": "redis://localhost:6379/0",
    "JWT_SECRET": "secret",
    "JWT_ALGORITHM": "HS256",
    "JWT_EXPIRATION": "3600",
    "OWNER_ROLE_ID": "1",
    "ADMINISTRATOR_ROLE_ID": "2",
    "VERIFIED_USER_ROLE_ID": "3",
    "VERIFIED_MEMBER_ROLE_ID": "4",
    "ALLOWED_ORIGINS": "http://localhost",
}

for key, value in env_defaults.items():
    os.environ.setdefault(key, value)

from ..service import app  # noqa: E402


@app.get("/health")
def health_check():
    """Return service health indicator for tests."""
    return {"status": "ok"}
