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
            raise httpx.HTTPStatusError("error", request=None, response=None)


def test_get_user_roles(monkeypatch):
    calls = []

    def fake_get(url: str, headers: dict[str, str]):
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
    def fake_get(url: str, headers: dict[str, str]):
        assert url.endswith("/users/@me")
        return StubResponse(200, {"id": "42", "username": "foo", "avatar": "img"})

    monkeypatch.setattr(httpx, "get", fake_get)
    profile = get_user_profile("token")
    assert profile == {"id": "42", "username": "foo", "avatar": "img"}


def test_get_user_roles_multiple_guilds(monkeypatch):
    """Collect roles across more than two guilds."""
    def fake_get(url: str, headers: dict[str, str]):
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
    assert roles == {"1": ["r1"], "2": ["r2"], "3": ["r3"]}


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

