"""Discord Integration API with OAuth linking and role lookups."""

from __future__ import annotations

import os
from typing import Any

import httpx
from fastapi import APIRouter, Depends, FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from starlette.middleware.base import BaseHTTPMiddleware
from sqlalchemy.orm import Session

from utils.cors import get_cors_origins
from utils.discord import get_user_roles
from devonboarder import auth_service

API_TIMEOUT = int(os.getenv("DISCORD_API_TIMEOUT", "10"))

router = APIRouter()


@router.post("/oauth")
def exchange_oauth(
    data: dict[str, Any], db: Session = Depends(auth_service.get_db)
) -> dict[str, str]:
    """Exchange a Discord OAuth code for a token and store it."""
    username = data["username"]
    code = data["code"]
    try:
        resp = httpx.post(
            "https://discord.com/api/oauth2/token",
            data={
                "client_id": os.getenv("DISCORD_CLIENT_ID"),
                "client_secret": os.getenv("DISCORD_CLIENT_SECRET"),
                "grant_type": "authorization_code",
                "code": code,
                "redirect_uri": os.getenv(
                    "DISCORD_REDIRECT_URI", "http://localhost:8081/oauth"
                ),
            },
            headers={"Content-Type": "application/x-www-form-urlencoded"},
            timeout=API_TIMEOUT,
        )
    except httpx.TimeoutException as exc:
        raise HTTPException(status_code=504, detail="Discord API timeout") from exc

    resp.raise_for_status()
    token = resp.json()["access_token"]
    user = db.query(auth_service.User).filter_by(username=username).first()
    if user is None:
        user = auth_service.User(
            username=username,
            password_hash=auth_service.pwd_context.hash(""),
            discord_token=token,
        )
        db.add(user)
    else:
        user.discord_token = token
    db.commit()
    return {"linked": username}


@router.get("/roles")
def get_roles(
    username: str, db: Session = Depends(auth_service.get_db)
) -> dict[str, Any]:
    """Return guild role mappings for the specified user."""
    user = db.query(auth_service.User).filter_by(username=username).first()
    if user is None:
        raise HTTPException(status_code=404, detail="User not found")

    try:
        roles = get_user_roles(user.discord_token)
    except httpx.TimeoutException as exc:
        raise HTTPException(status_code=504, detail="Discord API timeout") from exc

    return {"roles": roles}


def create_app() -> FastAPI:
    """Build the Discord Integration FastAPI application."""

    app = FastAPI()
    cors_origins = get_cors_origins()

    class _SecurityHeadersMiddleware(BaseHTTPMiddleware):
        async def dispatch(self, request, call_next):  # type: ignore[override]
            resp = await call_next(request)
            resp.headers.setdefault("X-Content-Type-Options", "nosniff")
            resp.headers.setdefault(
                "Access-Control-Allow-Origin", cors_origins[0] if cors_origins else "*"
            )
            return resp

    app.add_middleware(
        CORSMiddleware,
        allow_origins=cors_origins,
        allow_methods=["*"],
        allow_headers=["*"],
    )
    app.add_middleware(_SecurityHeadersMiddleware)

    @app.get("/health")
    def health() -> dict[str, str]:
        return {"status": "ok"}

    app.include_router(router)
    return app


def main() -> None:
    """Run the Discord Integration service."""
    import uvicorn

    uvicorn.run(create_app(), host="0.0.0.0", port=8081)


if __name__ == "__main__":  # pragma: no cover
    main()
