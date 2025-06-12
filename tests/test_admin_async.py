# PATCHED v0.1.42 tests/test_admin_async.py — Async admin endpoints
"""Async tests for admin endpoints using httpx.AsyncClient."""

import os
import sys
from pathlib import Path
from typing import List

import pytest
from httpx import AsyncClient, ASGITransport
from pydantic import BaseModel, parse_obj_as

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
from utils.env import get_settings  # noqa: E402
from backend.main import app  # noqa: E402

ENV_DEFAULTS = {
    "DISCORD_CLIENT_ID": "test",
    "DISCORD_CLIENT_SECRET": "test",
    "DATABASE_URL": "sqlite:///:memory:",
    "VERIFICATION_DB_URL": "sqlite:///:memory:",
    "REDIS_URL": "redis://localhost:6379/0",
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


class AdminUserOut(BaseModel):
    """Simple output model used for response validation."""

    id: int
    user_id: str | None = None
    type: str | None = None
    status: str | None = None


def _apply_env() -> None:
    for var, value in ENV_DEFAULTS.items():
        os.environ.setdefault(var, value)
    get_settings()


@pytest.fixture()
async def admin_client() -> AsyncClient:
    """Return an AsyncClient with admin header preset."""
    _apply_env()
    transport = ASGITransport(app=app)
    async with AsyncClient(
        base_url="http://test", headers={"X-Is-Admin": "true"}, transport=transport
    ) as client:
        yield client


@pytest.fixture()
async def anon_client() -> AsyncClient:
    """Return an AsyncClient without admin privileges."""
    _apply_env()
    transport = ASGITransport(app=app)
    async with AsyncClient(base_url="http://test", transport=transport) as client:
        yield client


@pytest.mark.anyio
async def test_admin_endpoints_async(admin_client: AsyncClient) -> None:
    """Endpoints should return lists matching AdminUserOut."""
    create = await admin_client.post(
        "/api/verification/request", json={"user_id": "u1"}
    )
    assert create.status_code == 200

    ver_resp = await admin_client.get("/api/admin/verification")
    assert ver_resp.status_code == 200
    parse_obj_as(List[AdminUserOut], ver_resp.json())

    users_resp = await admin_client.get("/api/admin/users")
    assert users_resp.status_code == 200
    parse_obj_as(List[AdminUserOut], users_resp.json())


@pytest.mark.anyio
async def test_admin_endpoints_require_admin(anon_client: AsyncClient) -> None:
    """Missing admin header should return 403 errors."""
    resp = await anon_client.get("/api/admin/verification")
    assert resp.status_code == 403

    users = await anon_client.get("/api/admin/users")
    assert users.status_code == 403
