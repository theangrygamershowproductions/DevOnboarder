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
    all_role_ids = {r for rs in roles.values() for r in rs}
    flags = auth_service.resolve_user_flags(all_role_ids)
    return {
        "id": getattr(current_user, "discord_id", None),
        "username": getattr(current_user, "discord_username", None),
        "avatar": getattr(current_user, "avatar", None),
        "isAdmin": flags["isAdmin"],
        "isVerified": flags["isVerified"],
        "verificationType": flags["verificationType"],
        "roles": roles,
    }
