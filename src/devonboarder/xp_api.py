from __future__ import annotations

from fastapi import APIRouter, FastAPI, Depends, HTTPException
from sqlalchemy.orm import Session

from devonboarder import auth_service

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


def create_app() -> FastAPI:
    """Create a FastAPI application with the XP router."""
    app = FastAPI()
    app.include_router(router)
    return app


def main() -> None:
    """Run the FastAPI application."""
    import uvicorn

    uvicorn.run(create_app(), host="0.0.0.0", port=8001)

