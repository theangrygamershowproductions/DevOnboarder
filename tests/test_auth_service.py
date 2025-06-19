from fastapi.testclient import TestClient
from devonboarder import auth_service
from utils import discord as discord_utils


def setup_function(function):
    auth_service.init_db()
    auth_service.get_user_roles = lambda user_id, token: {}
    auth_service.resolve_user_flags = (
        lambda roles: {"isAdmin": False, "isVerified": False, "verificationType": None}
    )
    auth_service.get_user_profile = (
        lambda token: {"id": "0", "username": "", "avatar": None}
    )


def _get_token(client: TestClient, username: str, password: str) -> str:
    resp = client.post("/api/login", json={"username": username, "password": password})
    assert resp.status_code == 200
    return resp.json()["token"]


def test_register_login_and_user_info(monkeypatch):
    app = auth_service.create_app()
    client = TestClient(app)

    monkeypatch.setattr(
        auth_service,
        "get_user_roles",
        lambda user_id, token: {"guild": ["role1"]},
    )

    monkeypatch.setattr(
        auth_service,
        "resolve_user_flags",
        lambda roles: {"isAdmin": True, "isVerified": False, "verificationType": None},
    )

    monkeypatch.setattr(
        auth_service,
        "get_user_profile",
        lambda token: {"id": "99", "username": "discord", "avatar": "img"},
    )

    resp = client.post(
        "/api/register",
        json={"username": "alice", "password": "secret"},
    )
    assert resp.status_code == 200
    token = resp.json()["token"]

    resp = client.get(
        "/api/user",
        headers={"Authorization": f"Bearer {token}"},
    )
    assert resp.status_code == 200
    data = resp.json()
    assert data == {
        "id": "99",
        "username": "discord",
        "avatar": "img",
        "isAdmin": True,
        "isVerified": False,
        "verificationType": None,
        "roles": {"guild": ["role1"]},
    }

    # login works
    token2 = _get_token(client, "alice", "secret")
    assert token2


def test_user_levels_and_promote():
    app = auth_service.create_app()
    client = TestClient(app)

    # register two users
    client.post("/api/register", json={"username": "admin", "password": "adm"})
    client.post("/api/register", json={"username": "bob", "password": "pwd"})

    # make admin user an admin
    with auth_service.SessionLocal() as db:
        admin = db.query(auth_service.User).filter_by(username="admin").first()
        admin.is_admin = True
        bob = db.query(auth_service.User).filter_by(username="bob").first()
        db.add(auth_service.Contribution(user_id=bob.id, description="initial"))
        db.add(auth_service.XPEvent(user_id=bob.id, xp=150))
        db.commit()

    admin_token = _get_token(client, "admin", "adm")
    bob_token = _get_token(client, "bob", "pwd")

    resp = client.get(
        "/api/user/contributions",
        headers={"Authorization": f"Bearer {bob_token}"},
    )
    assert resp.json() == {"contributions": ["initial"]}

    resp = client.get(
        "/api/user/onboarding-status",
        headers={"Authorization": f"Bearer {bob_token}"},
    )
    assert resp.json() == {"status": "complete"}

    resp = client.get(
        "/api/user/level",
        headers={"Authorization": f"Bearer {bob_token}"},
    )
    assert resp.json() == {"level": 2}

    resp = client.post(
        "/api/user/promote",
        json={"username": "bob"},
        headers={"Authorization": f"Bearer {admin_token}"},
    )
    assert resp.status_code == 200
    assert resp.json() == {"promoted": "bob"}

    with auth_service.SessionLocal() as db:
        bob = db.query(auth_service.User).filter_by(username="bob").first()
        assert bob.is_admin

def test_register_duplicate_username():
    app = auth_service.create_app()
    client = TestClient(app)

    client.post("/api/register", json={"username": "bob", "password": "pwd"})
    resp = client.post("/api/register", json={"username": "bob", "password": "pwd"})
    assert resp.status_code == 400
    assert resp.json()["detail"] == "Username exists"


def test_login_invalid_credentials():
    app = auth_service.create_app()
    client = TestClient(app)

    client.post("/api/register", json={"username": "alice", "password": "secret"})
    resp = client.post("/api/login", json={"username": "alice", "password": "wrong"})
    assert resp.status_code == 400
    assert resp.json()["detail"] == "Invalid credentials"


def test_xp_accumulation_and_level_calculation():
    app = auth_service.create_app()
    client = TestClient(app)

    client.post("/api/register", json={"username": "eve", "password": "pw"})
    with auth_service.SessionLocal() as db:
        eve = db.query(auth_service.User).filter_by(username="eve").first()
        db.add_all([
            auth_service.XPEvent(user_id=eve.id, xp=120),
            auth_service.XPEvent(user_id=eve.id, xp=80),
            auth_service.XPEvent(user_id=eve.id, xp=60),
        ])
        db.commit()

    token = _get_token(client, "eve", "pw")
    resp = client.get("/api/user/level", headers={"Authorization": f"Bearer {token}"})
    assert resp.status_code == 200
    assert resp.json() == {"level": 3}


def test_user_endpoint_returns_flags(monkeypatch):
    app = auth_service.create_app()
    client = TestClient(app)

    monkeypatch.setattr(
        auth_service,
        "get_user_roles",
        lambda user_id, token: {"10": ["mod"], "30": ["edu"]},
    )

    monkeypatch.setattr(
        auth_service,
        "resolve_user_flags",
        discord_utils.resolve_user_flags,
    )

    monkeypatch.setattr(
        auth_service,
        "get_user_profile",
        lambda token: {"id": "5", "username": "d", "avatar": None},
    )

    monkeypatch.setenv("ADMIN_SERVER_GUILD_ID", "10")
    monkeypatch.setenv("OWNER_ROLE_ID", "owner")
    monkeypatch.setenv("ADMINISTRATOR_ROLE_ID", "admin")
    monkeypatch.setenv("MODERATOR_ROLE_ID", "mod")
    monkeypatch.setenv("VERIFIED_USER_ROLE_ID", "verified")
    monkeypatch.setenv("VERIFIED_MEMBER_ROLE_ID", "vmember")
    monkeypatch.setenv("GOVERNMENT_ROLE_ID", "gov")
    monkeypatch.setenv("MILITARY_ROLE_ID", "mil")
    monkeypatch.setenv("EDUCATION_ROLE_ID", "edu")

    client.post("/api/register", json={"username": "carl", "password": "pwd"})
    token = _get_token(client, "carl", "pwd")

    resp = client.get("/api/user", headers={"Authorization": f"Bearer {token}"})
    data = resp.json()
    assert data["isAdmin"] is True
    assert data["isVerified"] is True
    assert data["verificationType"] == "education"
