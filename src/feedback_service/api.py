from __future__ import annotations

import os
from typing import Any

from fastapi import APIRouter, Depends, FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy import Column, Integer, String, func
from sqlalchemy.orm import Session
from starlette.middleware.base import BaseHTTPMiddleware

from utils.cors import get_cors_origins
from devonboarder import auth_service


class Feedback(auth_service.Base):
    __tablename__ = "feedback"

    id = Column(Integer, primary_key=True)
    type = Column(String, nullable=False)
    status = Column(String, default="open", nullable=False)
    description = Column(String, nullable=False)


router = APIRouter()


@router.post("/feedback")
def submit_feedback(
    data: dict[str, Any],
    db: Session = Depends(auth_service.get_db),
) -> dict[str, Any]:
    item = Feedback(
        type=data["type"],
        description=data["description"],
        status="open",
    )
    db.add(item)
    db.commit()
    db.refresh(item)
    return {"id": item.id, "status": item.status}


@router.patch("/feedback/{item_id}")
def update_status(
    item_id: int,
    data: dict[str, Any],
    db: Session = Depends(auth_service.get_db),
) -> dict[str, Any]:
    item = db.get(Feedback, item_id)
    if item is None:
        raise HTTPException(status_code=404, detail="Item not found")
    item.status = data.get("status", item.status)
    db.commit()
    return {"updated": item.id, "status": item.status}


@router.get("/feedback")
def list_feedback(db: Session = Depends(auth_service.get_db)) -> dict[str, Any]:
    items = db.query(Feedback).all()
    return {
        "feedback": [
            {
                "id": f.id,
                "type": f.type,
                "status": f.status,
                "description": f.description,
            }
            for f in items
        ]
    }


@router.get("/feedback/analytics")
def analytics(db: Session = Depends(auth_service.get_db)) -> dict[str, Any]:
    rows = (
        db.query(Feedback.type, Feedback.status, func.count(Feedback.id))
        .group_by(Feedback.type, Feedback.status)
        .all()
    )
    summary: dict[str, dict[str, int]] = {}
    for type_, status, count in rows:
        summary.setdefault(type_, {})[status] = count
    total = db.query(func.count(Feedback.id)).scalar() or 0
    return {"total": total, "breakdown": summary}


def create_app() -> FastAPI:
    if os.getenv("INIT_DB_ON_STARTUP"):
        auth_service.init_db()
        auth_service.Base.metadata.create_all(bind=auth_service.engine)

    app = FastAPI()
    cors_origins = get_cors_origins()

    class _SecurityHeadersMiddleware(BaseHTTPMiddleware):
        async def dispatch(self, request, call_next):
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


def main() -> None:  # pragma: no cover
    import uvicorn

    uvicorn.run(create_app(), host="0.0.0.0", port=8090)  # nosec B104


if __name__ == "__main__":  # pragma: no cover
    main()
