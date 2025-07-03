"""Helpers for resolving Discord role flags and verification status."""

from __future__ import annotations

import os
from typing import Iterable, Optional


def resolve_verification_type(role_ids: Iterable[str]) -> Optional[str]:
    """Return the verification type for the given role IDs."""
    env = os.environ
    verified_member_role = env.get("VERIFIED_MEMBER_ROLE_ID")
    verified_user_role = env.get("VERIFIED_USER_ROLE_ID")
    government_role = env.get("GOVERNMENT_ROLE_ID")
    military_role = env.get("MILITARY_ROLE_ID")
    education_role = env.get("EDUCATION_ROLE_ID")

    roles = set(role_ids)

    if government_role in roles:
        return "government"
    if military_role in roles:
        return "military"
    if education_role in roles:
        return "education"
    if verified_member_role in roles or verified_user_role in roles:
        return "member"
    return None


def resolve_user_flags(role_ids: Iterable[str]) -> dict[str, object]:
    """Resolve admin and verification flags from role IDs."""
    env = os.environ
    owner_role = env.get("OWNER_ROLE_ID")
    admin_role = env.get("ADMINISTRATOR_ROLE_ID")
    mod_role = env.get("MODERATOR_ROLE_ID")

    roles = set(role_ids)

    admin_roles = {owner_role, admin_role, mod_role} - {None}
    is_admin = bool(roles & admin_roles)

    verification_type = resolve_verification_type(roles)

    return {
        "isAdmin": is_admin,
        "isVerified": verification_type is not None,
        "verificationType": verification_type,
    }
