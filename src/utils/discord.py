"""Discord API helper functions."""

from __future__ import annotations

import os
import httpx


BASE_URL = "https://discord.com/api/v10"
API_TIMEOUT = int(os.getenv("DISCORD_API_TIMEOUT", "10"))


def get_user_roles(token: str) -> dict[str, list[str]]:
    """Return guild role IDs for the authenticated user.

    Parameters
    ----------
    token:
        OAuth or bot token used for the API call.

    Returns
    -------
    dict[str, list[str]]
        Mapping of guild IDs to role ID lists.
    """
    headers = {"Authorization": f"Bearer {token}"}
    guilds_resp = httpx.get(
        f"{BASE_URL}/users/@me/guilds",
        headers=headers,
        timeout=API_TIMEOUT,
    )
    guilds_resp.raise_for_status()
    guilds = guilds_resp.json()

    roles: dict[str, list[str]] = {}
    for guild in guilds:
        guild_id = guild["id"]
        member_resp = httpx.get(
            f"{BASE_URL}/users/@me/guilds/{guild_id}/member",
            headers=headers,
            timeout=API_TIMEOUT,
        )
        member_resp.raise_for_status()
        data = member_resp.json()
        roles[guild_id] = data.get("roles", [])
    return roles


def get_user_profile(token: str) -> dict[str, str | None]:
    """Return the Discord user profile for the given OAuth token."""
    headers = {"Authorization": f"Bearer {token}"}
    resp = httpx.get(
        f"{BASE_URL}/users/@me",
        headers=headers,
        timeout=API_TIMEOUT,
    )
    resp.raise_for_status()
    data = resp.json()
    return {
        "id": data["id"],
        "username": data["username"],
        "avatar": data.get("avatar"),
    }




