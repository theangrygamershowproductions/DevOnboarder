import httpx
from utils.discord import get_user_roles, resolve_user_flags


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
    roles = get_user_roles("123", "token")
    assert roles == {"1": ["a"], "2": ["b", "c"]}


def test_resolve_user_flags(monkeypatch):
    monkeypatch.setenv("ADMIN_SERVER_GUILD_ID", "10")
    monkeypatch.setenv("OWNER_ROLE_ID", "owner")
    monkeypatch.setenv("ADMNISTRATOR_ROLE_ID", "admin")
    monkeypatch.setenv("MODERATOR_ROLE_ID", "mod")
    monkeypatch.setenv("VERIFIED_USER_ROLE_ID", "verified")
    monkeypatch.setenv("VERIFIED_MEMBER_ROLE_ID", "vmember")
    monkeypatch.setenv("GOVERNMENT_ROLE_ID", "gov")
    monkeypatch.setenv("MILITARY_ROLE_ID", "mil")
    monkeypatch.setenv("EDUCATION_ROLE_ID", "edu")

    roles = {"10": ["owner"], "20": ["gov"]}
    flags = resolve_user_flags(roles)
    assert flags == {
        "isAdmin": True,
        "isVerified": True,
        "verificationType": "government",
    }

