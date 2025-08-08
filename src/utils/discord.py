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

    # Get user's guilds
    guilds_resp = httpx.get(
        f"{BASE_URL}/users/@me/guilds", headers=headers, timeout=API_TIMEOUT
    )
    guilds_resp.raise_for_status()
    guilds = guilds_resp.json()

    # Filter to only our configured guilds to avoid unnecessary API calls
    target_guild_ids = {
        os.getenv("DISCORD_DEV_GUILD_ID", "1386935663139749998"),
        os.getenv("DISCORD_PROD_GUILD_ID", "1065367728992571444"),
    }

    roles: dict[str, list[str]] = {}
    for guild in guilds:
        guild_id = guild["id"]

        # Only query roles for our target guilds
        if guild_id not in target_guild_ids:
            continue

        try:
            member_resp = httpx.get(
                f"{BASE_URL}/users/@me/guilds/{guild_id}/member",
                headers=headers,
                timeout=API_TIMEOUT,
            )
            member_resp.raise_for_status()
            data = member_resp.json()
            roles[guild_id] = data.get("roles", [])
        except httpx.HTTPStatusError as e:
            if e.response.status_code == 429:  # Rate limited
                # Return empty roles for this guild and continue
                roles[guild_id] = []
                continue
            elif e.response.status_code == 403:  # Not a member of this guild
                # User is not in this guild, skip it
                continue
            else:
                # Re-raise other errors
                raise
        except httpx.TimeoutException:
            # Return empty roles for this guild on timeout
            roles[guild_id] = []
            continue

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
