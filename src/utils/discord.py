"""Discord API helper functions."""

from __future__ import annotations

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


def get_user_profile(token: str) -> dict[str, str | None]:
    """Return the Discord user profile for the given OAuth token."""
    headers = {"Authorization": f"Bearer {token}"}
    resp = httpx.get(f"{BASE_URL}/users/@me", headers=headers)
    resp.raise_for_status()
    data = resp.json()
    return {
        "id": data["id"],
        "username": data["username"],
        "avatar": data.get("avatar"),
    }




