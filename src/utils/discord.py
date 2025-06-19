"""Discord API helper functions."""

from __future__ import annotations

import os

import httpx


BASE_URL = "https://discord.com/api/v10"


def get_user_roles(user_id: str, token: str) -> dict[str, list[str]]:
    """Return guild role IDs for the given user.

    Parameters
    ----------
    user_id:
        The Discord user ID. Currently unused but kept for future
        compatibility.
    token:
        OAuth or bot token used for the API call.

    Returns
    -------
    dict[str, list[str]]
        Mapping of guild IDs to role ID lists.
    """
    headers = {"Authorization": f"Bearer {token}"}
    guilds_resp = httpx.get(f"{BASE_URL}/users/@me/guilds", headers=headers)
    guilds_resp.raise_for_status()
    guilds = guilds_resp.json()

    roles: dict[str, list[str]] = {}
    for guild in guilds:
        guild_id = guild["id"]
        member_resp = httpx.get(
            f"{BASE_URL}/users/@me/guilds/{guild_id}/member", headers=headers
        )
        member_resp.raise_for_status()
        data = member_resp.json()
        roles[guild_id] = data.get("roles", [])
    return roles


def resolve_user_flags(user_roles: dict[str, list[str]]) -> dict[str, object]:
    """Resolve admin and verification flags based on role IDs."""
    env = os.environ
    admin_guild = env.get("ADMIN_SERVER_GUILD_ID")
    owner_role = env.get("OWNER_ROLE_ID")
    admin_role = env.get("ADMNISTRATOR_ROLE_ID")
    mod_role = env.get("MODERATOR_ROLE_ID")
    verified_user_role = env.get("VERIFIED_USER_ROLE_ID")
    verified_member_role = env.get("VERIFIED_MEMBER_ROLE_ID")
    government_role = env.get("GOVERNMENT_ROLE_ID")
    military_role = env.get("MILITARY_ROLE_ID")
    education_role = env.get("EDUCATION_ROLE_ID")

    all_roles = {r for roles in user_roles.values() for r in roles}

    admin_roles = {owner_role, admin_role, mod_role} - {None}
    is_admin = False
    if admin_guild and admin_guild in user_roles:
        is_admin = bool(set(user_roles[admin_guild]) & admin_roles)

    verification_roles = {
        verified_user_role,
        verified_member_role,
        government_role,
        military_role,
        education_role,
    } - {None}
    is_verified = bool(all_roles & verification_roles)

    verification_type = None
    if government_role in all_roles:
        verification_type = "government"
    elif military_role in all_roles:
        verification_type = "military"
    elif education_role in all_roles:
        verification_type = "education"
    elif verified_member_role in all_roles or verified_user_role in all_roles:
        verification_type = "member"

    return {
        "isAdmin": is_admin,
        "isVerified": is_verified,
        "verificationType": verification_type,
    }

