from __future__ import annotations

from fastapi import APIRouter, FastAPI, Depends, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from starlette.middleware.base import BaseHTTPMiddleware
from sqlalchemy.orm import Session
import os

from devonboarder import auth_service


def _get_cors_origins() -> list[str]:
    """Return allowed CORS origins from the environment."""
    origins = os.getenv("CORS_ALLOW_ORIGINS")
    if origins:
        return [o.strip() for o in origins.split(",") if o.strip()]
    if os.getenv("APP_ENV") == "development":
        return ["*"]
    return []

router = APIRouter()


@router.get("/api/user/onboarding-status")
def onboarding_status(
    username: str, db: Session = Depends(auth_service.get_db)
) -> dict[str, str]:
    """Return the user's onboarding status."""
    user = db.query(auth_service.User).filter_by(username=username).first()
    if user is None:
        raise HTTPException(status_code=404, detail="User not found")
    status_str = "complete" if user.contributions else "pending"
    return {"status": status_str}


@router.get("/api/user/level")
def user_level(
    username: str, db: Session = Depends(auth_service.get_db)
) -> dict[str, int]:
    """Return the user's current level."""
    user = db.query(auth_service.User).filter_by(username=username).first()
    if user is None:
        raise HTTPException(status_code=404, detail="User not found")
    xp_total = sum(evt.xp for evt in user.events)
    level = xp_total // 100 + 1
    return {"level": level}


@router.post("/api/user/contribute")
def contribute(
    data: dict,
    current_user: auth_service.User = Depends(auth_service.get_current_user),
    db: Session = Depends(auth_service.get_db),
) -> dict[str, str]:
    """Record a contribution and award XP."""
    description = data["description"]
    db.add(
        auth_service.Contribution(user_id=current_user.id, description=description)
    )
    db.add(
        auth_service.XPEvent(user_id=current_user.id, xp=auth_service.CONTRIBUTION_XP)
    )
    db.commit()
    return {"recorded": description}


def create_app() -> FastAPI:
    """Create a FastAPI application with the XP router."""
    app = FastAPI()
    cors_origins = _get_cors_origins()

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
        """Return service health status."""
        return {"status": "ok"}

    app.include_router(router)
    return app


def main() -> None:
    """Run the FastAPI application."""
    import uvicorn

    uvicorn.run(create_app(), host="0.0.0.0", port=8001)

