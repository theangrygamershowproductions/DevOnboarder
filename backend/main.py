# PATCHED v0.1.9 backend/main.py — Add admin routes and auth guard

"""FastAPI service providing verification request endpoints."""

from fastapi import FastAPI, HTTPException, Depends, Header
from pydantic import BaseModel
from utils.env import get_settings

from backend.src.dependencies import get_db_session
from backend.models.verification import VerificationRequest

get_settings()

app = FastAPI()


def require_admin(x_is_admin: str | None = Header(default=None)) -> None:
    """Raise an error if the caller lacks admin privileges."""
    if x_is_admin != "true":
        raise HTTPException(status_code=403, detail="admin only")


@app.get("/health")
def health_check():
    """Return service health indicator."""
    return {"status": "ok"}


class VerificationPayload(BaseModel):
    """Request body for creating a verification entry."""

    user_id: str
    verificationType: str | None = None


@app.post("/api/verification/request")
async def request_verification(
    payload: VerificationPayload, db_session=Depends(get_db_session)
):
    """Insert a new verification request and return its status."""
    async with db_session as db:
        record = VerificationRequest(
            user_id=payload.user_id,
            verification_type=payload.verificationType,
            status="pending",
        )
        db.add(record)
        db.commit()
        db.refresh(record)
        return {"id": record.id, "status": record.status}


@app.get("/api/verification/status")
async def get_status(user_id: str, db_session=Depends(get_db_session)):
    """Return the most recent verification request for a user."""
    async with db_session as db:
        record = (
            db.query(VerificationRequest)
            .filter(VerificationRequest.user_id == user_id)
            .order_by(VerificationRequest.requested_at.desc())
            .first()
        )
        if not record:
            raise HTTPException(status_code=404, detail="request not found")
        return {
            "verificationType": record.verification_type,
            "verificationStatus": record.status,
            "requestedAt": record.requested_at.isoformat(),
            "updatedAt": record.updated_at.isoformat(),
        }


@app.get("/api/admin/users", dependencies=[Depends(require_admin)])
def list_users():
    """Return placeholder user list for admin dashboard."""
    return []


@app.get("/api/admin/verification", dependencies=[Depends(require_admin)])
async def list_verifications(db_session=Depends(get_db_session)):
    """List all verification requests in the system."""
    async with db_session as db:
        records = db.query(VerificationRequest).all()
        return [
            {
                "id": r.id,
                "user_id": r.user_id,
                "type": r.verification_type,
                "status": r.status,
            }
            for r in records
        ]


if __name__ == "__main__":
    import uvicorn

    uvicorn.run(app, host="0.0.0.0", port=8000)
