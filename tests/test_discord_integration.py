from fastapi.testclient import TestClient
import httpx

from discord_integration import create_app
from devonboarder import auth_service
import discord_integration.api as di_api


def setup_function(function):
    auth_service.Base.metadata.drop_all(bind=auth_service.engine)
    auth_service.init_db()


def _create_user(username: str, token: str) -> None:
    with auth_service.SessionLocal() as db:
        user = auth_service.User(
            username=username, password_hash="x", discord_token=token
        )
        db.add(user)
        db.commit()


class StubResponse:
    def __init__(self, data: dict[str, str]):
        self.data = data
        self.status_code = 200

    def json(self) -> dict[str, str]:
        return self.data

    def raise_for_status(self) -> None:
        pass


def test_oauth_links_account(monkeypatch):
    app = create_app()
    client = TestClient(app)

    def fake_post(url: str, data: dict, headers: dict, *, timeout=None):
        assert data["code"] == "abc"
        return StubResponse({"access_token": "tok"})

    monkeypatch.setattr(httpx, "post", fake_post)

    resp = client.post("/oauth", json={"username": "alice", "code": "abc"})
    assert resp.status_code == 200
    assert resp.json() == {"linked": "alice"}

    with auth_service.SessionLocal() as db:
        user = db.query(auth_service.User).filter_by(username="alice").first()
        assert user.discord_token == "tok"


def test_roles_returns_mapping(monkeypatch):
    _create_user("bob", "tok")
    app = create_app()
    client = TestClient(app)

    monkeypatch.setattr(di_api, "get_user_roles", lambda token: {"1": ["a", "b"]})

    resp = client.get("/roles", params={"username": "bob"})
    assert resp.status_code == 200
    assert resp.json() == {"roles": {"1": ["a", "b"]}}


def test_roles_user_not_found():
    app = create_app()
    client = TestClient(app)

    resp = client.get("/roles", params={"username": "none"})
    assert resp.status_code == 404


def test_timeout_handled(monkeypatch):
    _create_user("tim", "tok")
    app = create_app()
    client = TestClient(app)

    def raise_timeout(*args, **kwargs):
        raise httpx.TimeoutException("timeout")

    monkeypatch.setattr(di_api, "get_user_roles", raise_timeout)

    resp = client.get("/roles", params={"username": "tim"})
    assert resp.status_code == 504


def test_oauth_timeout(monkeypatch):
    app = create_app()
    client = TestClient(app)

    def raise_timeout(*args, **kwargs):
        raise httpx.TimeoutException("timeout")

    monkeypatch.setattr(httpx, "post", raise_timeout)

    resp = client.post("/oauth", json={"username": "eve", "code": "123"})
    assert resp.status_code == 504
