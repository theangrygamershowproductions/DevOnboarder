from fastapi.testclient import TestClient
from devonboarder import auth_service


def setup_function(function):
    auth_service.init_db()


def _get_token(client: TestClient, username: str, password: str) -> str:
    resp = client.post("/api/login", json={"username": username, "password": password})
    assert resp.status_code == 200
    return resp.json()["token"]


def test_register_login_and_user_info():
    app = auth_service.create_app()
    client = TestClient(app)

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
    assert resp.json()["username"] == "alice"
    assert resp.json()["is_admin"] is False

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
