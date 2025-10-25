from __future__ import annotations

from fastapi import APIRouter, Depends

from devonboarder import auth_service

router = APIRouter()


@router.get("/api/user")
def user_info(
    current_user: auth_service.User = Depends(auth_service.get_current_user),
) -> dict[str, object]:
    """Return the current user's Discord profile and role flags."""
    roles = getattr(current_user, "roles", {})
    return {
        "id": getattr(current_user, "discord_id", None),
        "username": getattr(current_user, "discord_username", None),
        "avatar": getattr(current_user, "avatar", None),
        "isAdmin": getattr(current_user, "isAdmin", False),
        "isVerified": getattr(current_user, "isVerified", False),
        "verificationType": getattr(current_user, "verificationType", None),
        "roles": roles,
    }
