import os
# Environment variables must be set before importing modules from devonboarder.
os.environ.setdefault("APP_ENV", "development")
os.environ.setdefault("JWT_SECRET_KEY", "devsecret")

from xp.api import create_app
from devonboarder import auth_service
from fastapi.testclient import TestClient
from fastapi.middleware.cors import CORSMiddleware


def setup_function(function):
    auth_service.Base.metadata.drop_all(bind=auth_service.engine)
    auth_service.init_db()
    auth_service.get_user_roles = lambda token: {}
    auth_service.resolve_user_flags = (
        lambda roles: {"isAdmin": False, "isVerified": False, "verificationType": None}
    )
    auth_service.get_user_profile = (
        lambda token: {"id": "0", "username": "", "avatar": None}
    )


def _seed_data():
    with auth_service.SessionLocal() as db:
        user = auth_service.User(username="alice", password_hash="x")
        db.add(user)
        db.commit()
        db.refresh(user)
        db.add(auth_service.Contribution(user_id=user.id, description="first"))
        db.add_all([
            auth_service.XPEvent(user_id=user.id, xp=120),
            auth_service.XPEvent(user_id=user.id, xp=70),
        ])
        db.commit()


def _create_token(username: str) -> str:
    with auth_service.SessionLocal() as db:
        user = auth_service.User(username=username, password_hash="x")
        db.add(user)
        db.commit()
        db.refresh(user)
        return auth_service.create_token(user)


def test_onboarding_status_and_level():
    _seed_data()
    app = create_app()
    client = TestClient(app)

    resp = client.get("/api/user/onboarding-status", params={"username": "alice"})
    assert resp.status_code == 200
    assert resp.json() == {"status": "complete"}

    resp = client.get("/api/user/level", params={"username": "alice"})
    assert resp.status_code == 200
    assert resp.json() == {"level": 2}


def test_contribute_endpoint_awards_xp():
    token = _create_token("bob")
    app = create_app()
    client = TestClient(app)
    headers = {"Authorization": f"Bearer {token}"}

    resp = client.post(
        "/api/user/contribute",
        json={"description": "docs"},
        headers=headers,
    )
    assert resp.status_code == 200
    assert resp.json() == {"recorded": "docs"}

    resp = client.post(
        "/api/user/contribute",
        json={"description": "tests"},
        headers=headers,
    )
    assert resp.status_code == 200

    resp = client.get("/api/user/level", params={"username": "bob"})
    assert resp.json() == {"level": 2}


def test_cors_allow_origins(monkeypatch):
    monkeypatch.setenv("CORS_ALLOW_ORIGINS", "https://a.com,https://b.com")
    app = create_app()
    cors = next(m for m in app.user_middleware if m.cls is CORSMiddleware)
    assert cors.kwargs["allow_origins"] == ["https://a.com", "https://b.com"]


def test_default_cors_dev(monkeypatch):
    monkeypatch.delenv("CORS_ALLOW_ORIGINS", raising=False)
    monkeypatch.setenv("APP_ENV", "development")
    app = create_app()
    cors = next(m for m in app.user_middleware if m.cls is CORSMiddleware)
    assert cors.kwargs["allow_origins"] == ["*"]


def test_health_and_security_headers():
    app = create_app()
    client = TestClient(app)
    resp = client.get("/health")
    assert resp.json() == {"status": "ok"}
    assert resp.headers["X-Content-Type-Options"] == "nosniff"
    assert resp.headers["Access-Control-Allow-Origin"] == "*"


def test_status_and_level_user_not_found():
    app = create_app()
    client = TestClient(app)
    resp = client.get("/api/user/onboarding-status", params={"username": "x"})
    assert resp.status_code == 404
    resp = client.get("/api/user/level", params={"username": "x"})
    assert resp.status_code == 404
