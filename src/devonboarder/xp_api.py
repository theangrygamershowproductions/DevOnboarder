from __future__ import annotations

from fastapi import APIRouter, FastAPI

router = APIRouter()


@router.get("/api/user/onboarding-status")
def onboarding_status() -> dict[str, str]:
    """Return a placeholder onboarding status."""
    return {"status": "pending"}


@router.get("/api/user/level")
def user_level() -> dict[str, int]:
    """Return a placeholder user level."""
    return {"level": 1}


def create_app() -> FastAPI:
    """Create a FastAPI application with the XP router."""
    app = FastAPI()
    app.include_router(router)
    return app


def main() -> None:
    """Run the FastAPI application."""
    import uvicorn

    uvicorn.run(create_app(), host="0.0.0.0", port=8001)

