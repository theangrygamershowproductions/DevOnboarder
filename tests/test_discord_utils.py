import httpx
import pytest
from utils.discord import get_user_roles, get_user_profile
from utils.roles import resolve_user_flags


class StubResponse:
    def __init__(self, status_code: int, json_data: object):
        self.status_code = status_code
        self._json = json_data

    def json(self):
        return self._json

    def raise_for_status(self) -> None:
        if self.status_code >= 400:
            # Create a proper HTTPStatusError with response attribute
            error = httpx.HTTPStatusError("error", request=None, response=None)
            error.response = self  # type: ignore
            raise error


def test_get_user_roles(monkeypatch):
    # Mock the guild IDs to match test data
    monkeypatch.setenv("DISCORD_DEV_GUILD_ID", "1")
    monkeypatch.setenv("DISCORD_PROD_GUILD_ID", "2")

    calls = []

    def fake_get(url: str, headers: dict[str, str], *, timeout=None):
        calls.append(url)
        if url.endswith("/users/@me/guilds"):
            return StubResponse(200, [{"id": "1"}, {"id": "2"}])
        if url.endswith("/users/@me/guilds/1/member"):
            return StubResponse(200, {"roles": ["a"]})
        if url.endswith("/users/@me/guilds/2/member"):
            return StubResponse(200, {"roles": ["b", "c"]})
        return StubResponse(404, {})

    monkeypatch.setattr(httpx, "get", fake_get)
    roles = get_user_roles("token")
    assert roles == {"1": ["a"], "2": ["b", "c"]}


def test_resolve_user_flags(monkeypatch):
    monkeypatch.setenv("ADMIN_SERVER_GUILD_ID", "10")
    monkeypatch.setenv("OWNER_ROLE_ID", "owner")
    monkeypatch.setenv("ADMINISTRATOR_ROLE_ID", "admin")
    monkeypatch.setenv("MODERATOR_ROLE_ID", "mod")
    monkeypatch.setenv("VERIFIED_USER_ROLE_ID", "verified")
    monkeypatch.setenv("VERIFIED_MEMBER_ROLE_ID", "vmember")
    monkeypatch.setenv("GOVERNMENT_ROLE_ID", "gov")
    monkeypatch.setenv("MILITARY_ROLE_ID", "mil")
    monkeypatch.setenv("EDUCATION_ROLE_ID", "edu")

    flags = resolve_user_flags({"owner", "gov"})
    assert flags == {
        "isAdmin": True,
        "isVerified": True,
        "verificationType": "government",
    }


def test_get_user_profile(monkeypatch):
    def fake_get(url: str, headers: dict[str, str], *, timeout=None):
        assert url.endswith("/users/@me")
        return StubResponse(200, {"id": "42", "username": "foo", "avatar": "img"})

    monkeypatch.setattr(httpx, "get", fake_get)
    profile = get_user_profile("token")
    assert profile == {"id": "42", "username": "foo", "avatar": "img"}


def test_get_user_roles_multiple_guilds(monkeypatch):
    """Collect roles across more than two guilds."""
    # Mock the guild IDs to match test data (first two will be included)
    monkeypatch.setenv("DISCORD_DEV_GUILD_ID", "1")
    monkeypatch.setenv("DISCORD_PROD_GUILD_ID", "2")

    def fake_get(url: str, headers: dict[str, str], *, timeout=None):
        if url.endswith("/users/@me/guilds"):
            return StubResponse(200, [{"id": "1"}, {"id": "2"}, {"id": "3"}])
        if url.endswith("/users/@me/guilds/1/member"):
            return StubResponse(200, {"roles": ["r1"]})
        if url.endswith("/users/@me/guilds/2/member"):
            return StubResponse(200, {"roles": ["r2"]})
        if url.endswith("/users/@me/guilds/3/member"):
            return StubResponse(200, {"roles": ["r3"]})
        return StubResponse(404, {})

    monkeypatch.setattr(httpx, "get", fake_get)
    roles = get_user_roles("token")
    # Only guilds 1 and 2 should be included since guild 3 is not in target_guild_ids
    assert roles == {"1": ["r1"], "2": ["r2"]}


@pytest.mark.parametrize(
    "roles,expected",
    [
        (
            {"10": ["owner"]},
            {"isAdmin": True, "isVerified": False, "verificationType": None},
        ),
        (
            {"10": ["mod"], "99": ["edu"]},
            {
                "isAdmin": True,
                "isVerified": True,
                "verificationType": "education",
            },
        ),
        (
            {"10": [], "50": ["gov"]},
            {
                "isAdmin": False,
                "isVerified": True,
                "verificationType": "government",
            },
        ),
    ],
)
def test_resolve_user_flags_combinations(monkeypatch, roles, expected):
    """Return correct flags for assorted role sets."""
    monkeypatch.setenv("ADMIN_SERVER_GUILD_ID", "10")
    monkeypatch.setenv("OWNER_ROLE_ID", "owner")
    monkeypatch.setenv("ADMINISTRATOR_ROLE_ID", "admin")
    monkeypatch.setenv("MODERATOR_ROLE_ID", "mod")
    monkeypatch.setenv("VERIFIED_USER_ROLE_ID", "verified")
    monkeypatch.setenv("VERIFIED_MEMBER_ROLE_ID", "vmember")
    monkeypatch.setenv("GOVERNMENT_ROLE_ID", "gov")
    monkeypatch.setenv("MILITARY_ROLE_ID", "mil")
    monkeypatch.setenv("EDUCATION_ROLE_ID", "edu")

    flags = resolve_user_flags({r for rs in roles.values() for r in rs})
    assert flags == expected


def test_get_user_roles_rate_limited(monkeypatch):
    """Test handling of rate limit responses."""
    monkeypatch.setenv("DISCORD_DEV_GUILD_ID", "1")
    monkeypatch.setenv("DISCORD_PROD_GUILD_ID", "2")

    calls = []

    def mock_get(url: str, headers: dict[str, str], *, timeout=None):
        calls.append(url)
        if url.endswith("/users/@me/guilds"):
            return StubResponse(200, [{"id": "1"}, {"id": "2"}])
        # Return 429 (rate limited) for first guild
        if url.endswith("/users/@me/guilds/1/member"):
            return StubResponse(429, {})
        # Normal response for second guild
        if url.endswith("/users/@me/guilds/2/member"):
            return StubResponse(200, {"roles": ["role2"]})
        return StubResponse(404, {})

    monkeypatch.setattr(httpx, "get", mock_get)

    roles = get_user_roles("token")

    # Should get empty roles for rate limited guild, normal roles for other
    assert roles == {"1": [], "2": ["role2"]}
    assert len(calls) == 3  # guilds call + 2 member calls


def test_get_user_roles_not_member(monkeypatch):
    """Test handling of 403 (not a member) responses."""
    monkeypatch.setenv("DISCORD_DEV_GUILD_ID", "1")
    monkeypatch.setenv("DISCORD_PROD_GUILD_ID", "2")

    calls = []

    def mock_get(url: str, headers: dict[str, str], *, timeout=None):
        calls.append(url)
        if url.endswith("/users/@me/guilds"):
            return StubResponse(200, [{"id": "1"}, {"id": "2"}])
        # Return 403 (not a member) for first guild
        if url.endswith("/users/@me/guilds/1/member"):
            return StubResponse(403, {})
        # Normal response for second guild
        if url.endswith("/users/@me/guilds/2/member"):
            return StubResponse(200, {"roles": ["role2"]})
        return StubResponse(404, {})

    monkeypatch.setattr(httpx, "get", mock_get)

    roles = get_user_roles("token")

    # Should skip first guild (not a member), get roles for second
    assert roles == {"2": ["role2"]}
    assert len(calls) == 3  # guilds call + 2 member calls


def test_get_user_roles_timeout(monkeypatch):
    """Test handling of timeout exceptions."""
    monkeypatch.setenv("DISCORD_DEV_GUILD_ID", "1")
    monkeypatch.setenv("DISCORD_PROD_GUILD_ID", "2")

    calls = []

    def mock_get(url: str, headers: dict[str, str], *, timeout=None):
        calls.append(url)
        if url.endswith("/users/@me/guilds"):
            return StubResponse(200, [{"id": "1"}, {"id": "2"}])
        # Timeout for first guild
        if url.endswith("/users/@me/guilds/1/member"):
            raise httpx.TimeoutException("Request timed out")
        # Normal response for second guild
        if url.endswith("/users/@me/guilds/2/member"):
            return StubResponse(200, {"roles": ["role2"]})
        return StubResponse(404, {})

    monkeypatch.setattr(httpx, "get", mock_get)

    roles = get_user_roles("token")

    # Should get empty roles for timeout guild, normal roles for other
    assert roles == {"1": [], "2": ["role2"]}
    assert len(calls) == 3  # guilds call + 2 member calls


def test_get_user_roles_other_http_error(monkeypatch):
    """Test handling of other HTTP errors (should re-raise)."""
    monkeypatch.setenv("DISCORD_DEV_GUILD_ID", "1")

    def mock_get(url: str, headers: dict[str, str], *, timeout=None):
        if url.endswith("/users/@me/guilds"):
            return StubResponse(200, [{"id": "1"}])
        # Return 500 for guild member call
        if url.endswith("/users/@me/guilds/1/member"):
            return StubResponse(500, {})
        return StubResponse(404, {})

    monkeypatch.setattr(httpx, "get", mock_get)

    # Should re-raise server errors
    with pytest.raises(httpx.HTTPStatusError):
        get_user_roles("token")
