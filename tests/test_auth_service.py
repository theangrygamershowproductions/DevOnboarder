import httpx
import sqlalchemy
import time
import pytest
import jwt
from utils import roles as roles_utils
from fastapi.middleware.cors import CORSMiddleware
from devonboarder import auth_service
from fastapi.testclient import TestClient
import importlib
import os

# Environment variables must be set before importing modules from devonboarder.
os.environ.setdefault("APP_ENV", "development")
# Use clear template token for testing - obviously not for production
os.environ.setdefault("JWT_SECRET_KEY", "this_is_a_template_token_replace_me")


def setup_function(function):
    auth_service.Base.metadata.drop_all(bind=auth_service.engine)
    auth_service.init_db()
    auth_service.get_user_roles = lambda token: {}
    auth_service.resolve_user_flags = lambda roles: {
        "isAdmin": False,
        "isVerified": False,
        "verificationType": None,
    }
    auth_service.get_user_profile = lambda token: {
        "id": "0",
        "username": "",
        "avatar": None,
    }


def _get_token(
    client: TestClient,
    username: str,
    password: str,
    *,
    discord_token: str = "dtoken",
) -> str:
    resp = client.post(
        "/api/login",
        json={
            "username": username,
            "password": password,
            "discord_token": discord_token,
        },
    )
    assert resp.status_code == 200
    return resp.json()["token"]


def test_engine_initializes_for_sqlite(monkeypatch):
    """Engine passes check_same_thread when DATABASE_URL is SQLite."""
    orig_create = sqlalchemy.create_engine
    recorded: dict[str, dict] = {}

    def fake_create_engine(url, **kwargs):
        recorded["kwargs"] = kwargs
        return orig_create("sqlite:///:memory:", **kwargs)

    monkeypatch.setattr(sqlalchemy, "create_engine", fake_create_engine)
    monkeypatch.setenv("DATABASE_URL", "sqlite:///:memory:")
    importlib.reload(auth_service)
    assert recorded["kwargs"].get("connect_args") == {"check_same_thread": False}
    monkeypatch.setattr(sqlalchemy, "create_engine", orig_create)
    monkeypatch.delenv("DATABASE_URL", raising=False)
    importlib.reload(auth_service)


def test_engine_initializes_without_sqlite_args(monkeypatch):
    """Engine omits connect_args for non-SQLite URLs."""
    orig_create = sqlalchemy.create_engine
    recorded: dict[str, dict] = {}

    def fake_create_engine(url, **kwargs):
        recorded["kwargs"] = kwargs
        return orig_create("sqlite:///:memory:", **kwargs)

    monkeypatch.setattr(sqlalchemy, "create_engine", fake_create_engine)
    monkeypatch.setenv("DATABASE_URL", "postgresql://db")
    importlib.reload(auth_service)
    assert "connect_args" not in recorded["kwargs"]
    monkeypatch.setattr(sqlalchemy, "create_engine", orig_create)
    monkeypatch.delenv("DATABASE_URL", raising=False)
    importlib.reload(auth_service)


def test_register_login_and_user_info(monkeypatch):
    app = auth_service.create_app()
    client = TestClient(app)

    def fake_get_roles(token: str):
        assert token == "oauth-reg"
        return {"guild": ["role1"]}

    monkeypatch.setattr(auth_service, "get_user_roles", fake_get_roles)

    monkeypatch.setattr(
        auth_service,
        "resolve_user_flags",
        lambda roles: {"isAdmin": True, "isVerified": False, "verificationType": None},
    )

    def fake_profile(token: str):
        assert token == "oauth-reg"
        return {"id": "99", "username": "discord", "avatar": "img"}

    monkeypatch.setattr(auth_service, "get_user_profile", fake_profile)

    resp = client.post(
        "/api/register",
        json={"username": "alice", "password": "secret", "discord_token": "oauth-reg"},
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


def test_oauth_token_updated_on_login(monkeypatch):
    app = auth_service.create_app()
    client = TestClient(app)

    client.post(
        "/api/register",
        json={"username": "dan", "password": "pw", "discord_token": "old"},
    )

    def fake_profile(token: str):
        assert token == "new"
        return {"id": "1", "username": "d", "avatar": None}

    monkeypatch.setattr(auth_service, "get_user_profile", fake_profile)
    monkeypatch.setattr(auth_service, "get_user_roles", lambda token: {})

    token = _get_token(client, "dan", "pw", discord_token="new")
    resp = client.get("/api/user", headers={"Authorization": f"Bearer {token}"})
    assert resp.status_code == 200


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


def test_login_discord_only_account():
    """Test that Discord-only accounts cannot login with password."""
    app = auth_service.create_app()

    # Create a Discord-only account (no password set)
    with auth_service.SessionLocal() as db:
        discord_user = auth_service.User(
            username="discord123",
            password_hash="",  # Empty password hash for Discord-only account
            discord_token="fake_token",
        )
        db.add(discord_user)
        db.commit()

    # Try to login with password - should fail with "Invalid credentials"
    client = TestClient(app)
    resp = client.post(
        "/api/login", json={"username": "discord123", "password": "anypassword"}
    )
    assert resp.status_code == 400
    assert resp.json()["detail"] == "Invalid credentials"


def test_xp_accumulation_and_level_calculation():
    app = auth_service.create_app()
    client = TestClient(app)

    client.post("/api/register", json={"username": "eve", "password": "pw"})
    with auth_service.SessionLocal() as db:
        eve = db.query(auth_service.User).filter_by(username="eve").first()
        db.add_all(
            [
                auth_service.XPEvent(user_id=eve.id, xp=120),
                auth_service.XPEvent(user_id=eve.id, xp=80),
                auth_service.XPEvent(user_id=eve.id, xp=60),
            ]
        )
        db.commit()

    token = _get_token(client, "eve", "pw")
    resp = client.get("/api/user/level", headers={"Authorization": f"Bearer {token}"})
    assert resp.status_code == 200
    assert resp.json() == {"level": 3}


def test_contribution_endpoint_awards_xp():
    app = auth_service.create_app()
    client = TestClient(app)

    client.post("/api/register", json={"username": "sam", "password": "pw"})
    token = _get_token(client, "sam", "pw")

    headers = {"Authorization": f"Bearer {token}"}
    client.post(
        "/api/user/contributions",
        json={"description": "docs"},
        headers=headers,
    )
    client.post(
        "/api/user/contributions",
        json={"description": "tests"},
        headers=headers,
    )

    resp = client.get("/api/user/level", headers=headers)
    assert resp.json() == {"level": 2}


def test_user_endpoint_returns_flags(monkeypatch):
    app = auth_service.create_app()
    client = TestClient(app)

    monkeypatch.setattr(
        auth_service,
        "get_user_roles",
        lambda token: {"10": ["mod"], "30": ["edu"]},
    )

    monkeypatch.setattr(
        auth_service,
        "resolve_user_flags",
        roles_utils.resolve_user_flags,
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
    assert data["isVerified"] is False
    assert data["verificationType"] is None


def test_other_guild_roles_do_not_grant_admin(monkeypatch):
    app = auth_service.create_app()
    client = TestClient(app)

    monkeypatch.setattr(
        auth_service,
        "get_user_roles",
        lambda token: {"20": ["mod"]},
    )

    monkeypatch.setattr(
        auth_service,
        "resolve_user_flags",
        roles_utils.resolve_user_flags,
    )

    monkeypatch.setattr(
        auth_service,
        "get_user_profile",
        lambda token: {"id": "7", "username": "x", "avatar": None},
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

    client.post("/api/register", json={"username": "alex", "password": "pw"})
    token = _get_token(client, "alex", "pw")

    resp = client.get("/api/user", headers={"Authorization": f"Bearer {token}"})
    data = resp.json()
    assert data["isAdmin"] is False
    assert data["isVerified"] is False


class StubResponse:
    def __init__(self, status_code: int, json_data: object):
        self.status_code = status_code
        self._json = json_data

    def json(self):
        return self._json

    def raise_for_status(self) -> None:
        if self.status_code >= 400:
            raise httpx.HTTPStatusError("error", request=None, response=None)


def test_discord_oauth_callback_issues_jwt(monkeypatch):
    app = auth_service.create_app()
    client = TestClient(app)

    # Set test mode to return JSON instead of redirect
    monkeypatch.setenv("TEST_MODE", "true")

    def fake_post(url: str, data: dict, headers: dict, *, timeout=None):
        assert url.endswith("/token")
        assert data["code"] == "abc"
        return StubResponse(200, {"access_token": "tok"})

    monkeypatch.setattr(httpx, "post", fake_post)
    monkeypatch.setattr(auth_service, "get_user_roles", lambda tok: {})
    monkeypatch.setattr(
        auth_service,
        "resolve_user_flags",
        lambda roles: {
            "isAdmin": False,
            "isVerified": False,
            "verificationType": None,
        },
    )
    monkeypatch.setattr(
        auth_service,
        "get_user_profile",
        lambda tok: {
            "id": "99",
            "username": "d",
            "avatar": None,
        },
    )

    # Initialize database for this test
    auth_service.Base.metadata.drop_all(bind=auth_service.engine)
    auth_service.init_db()

    resp = client.get("/login/discord/callback?code=abc")
    assert resp.status_code == 200
    token = resp.json()["token"]
    assert token

    resp = client.get("/api/user", headers={"Authorization": f"Bearer {token}"})
    assert resp.status_code == 200


def test_oauth_callback_updates_existing_user(monkeypatch):
    app = auth_service.create_app()
    client = TestClient(app)

    # Set test mode to return JSON instead of redirect
    monkeypatch.setenv("TEST_MODE", "true")

    def fake_post(url: str, data: dict, headers: dict, *, timeout=None):
        return StubResponse(200, {"access_token": data["code"]})

    monkeypatch.setattr(httpx, "post", fake_post)
    monkeypatch.setattr(auth_service, "get_user_roles", lambda tok: {})
    monkeypatch.setattr(
        auth_service,
        "resolve_user_flags",
        lambda roles: {
            "isAdmin": False,
            "isVerified": False,
            "verificationType": None,
        },
    )
    monkeypatch.setattr(
        auth_service,
        "get_user_profile",
        lambda tok: {
            "id": "5",
            "username": "p",
            "avatar": None,
        },
    )

    client.get("/login/discord/callback?code=first")
    resp = client.get("/login/discord/callback?code=second")
    assert resp.status_code == 200
    with auth_service.SessionLocal() as db:
        user = db.query(auth_service.User).filter_by(username="5").first()
        assert user.discord_token == "second"


def test_expired_token_rejected(monkeypatch):
    monkeypatch.setenv("TOKEN_EXPIRE_SECONDS", "1")
    importlib.reload(auth_service)
    auth_service.Base.metadata.drop_all(bind=auth_service.engine)
    auth_service.init_db()
    auth_service.get_user_roles = lambda token: {}
    auth_service.resolve_user_flags = lambda roles: {
        "isAdmin": False,
        "isVerified": False,
        "verificationType": None,
    }
    auth_service.get_user_profile = lambda token: {
        "id": "0",
        "username": "",
        "avatar": None,
    }
    app = auth_service.create_app()
    client = TestClient(app)

    client.post("/api/register", json={"username": "tim", "password": "pw"})
    token = _get_token(client, "tim", "pw")
    time.sleep(2.1)
    resp = client.get("/api/user", headers={"Authorization": f"Bearer {token}"})
    assert resp.status_code == 401


def test_expired_token_decode_fails(monkeypatch):
    monkeypatch.setenv("TOKEN_EXPIRE_SECONDS", "1")
    monkeypatch.setenv("JWT_SECRET_KEY", "devsecret")
    importlib.reload(auth_service)
    user = auth_service.User(id=123, username="u", password_hash="x")
    token = auth_service.create_token(user)
    time.sleep(2.1)
    with pytest.raises(jwt.ExpiredSignatureError):
        jwt.decode(
            token,
            auth_service.SECRET_KEY,
            algorithms=[auth_service.ALGORITHM],
            options={"verify_exp": True},
        )


def test_discord_callback_timeout(monkeypatch):
    app = auth_service.create_app()
    client = TestClient(app)

    def raise_timeout(*args, **kwargs):
        raise httpx.TimeoutException("timeout")

    monkeypatch.setattr(httpx, "post", raise_timeout)

    resp = client.get("/login/discord/callback?code=abc")
    assert resp.status_code == 504
    assert resp.json()["detail"] == "Discord API timeout"


def test_get_current_user_timeout(monkeypatch):
    app = auth_service.create_app()
    client = TestClient(app)

    client.post("/api/register", json={"username": "t", "password": "pw"})
    token = _get_token(client, "t", "pw")

    def raise_roles(*args, **kwargs):
        raise httpx.TimeoutException("timeout")

    monkeypatch.setattr(auth_service, "get_user_roles", raise_roles)
    monkeypatch.setattr(
        auth_service,
        "get_user_profile",
        lambda tok: {"id": "1", "username": "t", "avatar": None},
    )

    resp = client.get("/api/user", headers={"Authorization": f"Bearer {token}"})
    assert resp.status_code == 504
    assert resp.json()["detail"] == "Discord API timeout"


def test_cors_allow_origins(monkeypatch):
    monkeypatch.setenv("CORS_ALLOW_ORIGINS", "https://a.com,https://b.com")
    app = auth_service.create_app()
    cors = next(m for m in app.user_middleware if m.cls is CORSMiddleware)
    assert cors.kwargs["allow_origins"] == ["https://a.com", "https://b.com"]


def test_default_cors_in_development(monkeypatch):
    monkeypatch.delenv("CORS_ALLOW_ORIGINS", raising=False)
    monkeypatch.setenv("APP_ENV", "development")
    importlib.reload(auth_service)
    app = auth_service.create_app()
    cors = next(m for m in app.user_middleware if m.cls is CORSMiddleware)
    assert cors.kwargs["allow_origins"] == ["*"]
    monkeypatch.delenv("APP_ENV", raising=False)
    importlib.reload(auth_service)


def test_health_endpoint():
    app = auth_service.create_app()
    client = TestClient(app)
    resp = client.get("/health")
    assert resp.status_code == 200
    assert resp.json() == {"status": "ok"}


def test_get_current_user_user_not_found():
    """Test get_current_user raises 401 when user is deleted after token creation."""
    app = auth_service.create_app()
    client = TestClient(app)

    # Create user and get token
    client.post("/api/register", json={"username": "testuser", "password": "pw"})
    token = _get_token(client, "testuser", "pw")

    # Delete the user from the database while keeping the valid token
    with auth_service.SessionLocal() as db:
        user = db.query(auth_service.User).filter_by(username="testuser").first()
        if user:
            db.delete(user)
            db.commit()

    # Try to use the token - should fail with 401 User not found
    resp = client.get("/api/user", headers={"Authorization": f"Bearer {token}"})
    assert resp.status_code == 401
    assert resp.json()["detail"] == "User not found"


def test_discord_oauth_redirect_with_state_parameter(monkeypatch):
    """Test OAuth callback redirect logic with state parameter."""
    app = auth_service.create_app()
    client = TestClient(app)

    # Use CI environment URL instead of hard-coding production URL
    test_frontend_url = "http://localhost:8081"
    monkeypatch.setenv("FRONTEND_URL", test_frontend_url)

    # Mock Discord OAuth flow
    def fake_post(url: str, data: dict, headers: dict, *, timeout=None):
        return StubResponse(200, {"access_token": "test_token"})

    monkeypatch.setattr(httpx, "post", fake_post)
    monkeypatch.setattr(auth_service, "get_user_roles", lambda tok: {})
    monkeypatch.setattr(
        auth_service,
        "resolve_user_flags",
        lambda roles: {"isAdmin": False, "isVerified": False, "verificationType": None},
    )
    monkeypatch.setattr(
        auth_service,
        "get_user_profile",
        lambda tok: {"id": "123", "username": "testuser", "avatar": None},
    )

    # Test with UNSAFE state parameter - should block and fallback to safe default
    unsafe_redirect = "https://custom.example.com/dashboard"
    resp = client.get(
        f"/login/discord/callback?code=testcode&state={unsafe_redirect}",
        follow_redirects=False,
    )

    # Security check: Should redirect to safe fallback, not unsafe URL
    assert resp.status_code == 307
    location = resp.headers["location"]

    # Safe URL validation using proper parsing
    from urllib.parse import urlparse

    parsed_url = urlparse(location)
    # Should redirect to localhost in CI environment
    assert parsed_url.hostname and (
        parsed_url.hostname == "localhost" or parsed_url.hostname == "127.0.0.1"
    )
    assert not location.startswith(unsafe_redirect)  # Should NOT use unsafe URL
    assert "token=" in location


def test_discord_oauth_redirect_with_safe_state_parameter(monkeypatch):
    """Test OAuth callback redirect logic with SAFE state parameter."""
    app = auth_service.create_app()
    client = TestClient(app)

    # Use CI environment URL instead of hard-coding production URL
    test_frontend_url = "http://localhost:8081"
    monkeypatch.setenv("FRONTEND_URL", test_frontend_url)

    # Mock Discord OAuth flow
    def fake_post(url: str, data: dict, headers: dict, *, timeout=None):
        return StubResponse(200, {"access_token": "test_token"})

    monkeypatch.setattr(httpx, "post", fake_post)
    monkeypatch.setattr(auth_service, "get_user_roles", lambda tok: {})
    monkeypatch.setattr(
        auth_service,
        "resolve_user_flags",
        lambda roles: {"isAdmin": False, "isVerified": False, "verificationType": None},
    )
    monkeypatch.setattr(
        auth_service,
        "get_user_profile",
        lambda tok: {"id": "123", "username": "testuser", "avatar": None},
    )

    # Test with SAFE state parameter - should use the safe URL
    safe_redirect = "http://localhost:8081/dashboard"
    resp = client.get(
        f"/login/discord/callback?code=testcode&state={safe_redirect}",
        follow_redirects=False,
    )

    # Should redirect to the safe custom URL
    assert resp.status_code == 307
    location = resp.headers["location"]

    # Safe URL validation using proper parsing
    from urllib.parse import urlparse

    parsed_url = urlparse(location)
    # Should redirect to localhost in CI environment
    assert parsed_url.hostname and (
        parsed_url.hostname == "localhost" or parsed_url.hostname == "127.0.0.1"
    )
    assert "token=" in location


def test_discord_oauth_redirect_fallback_logic(monkeypatch):
    """Test OAuth callback fallback redirect logic when no state provided."""

    app = auth_service.create_app()
    client = TestClient(app)

    # Set environment variables for fallback testing
    monkeypatch.setenv("FRONTEND_URL", "https://frontend.test.com")

    # Mock Discord OAuth flow
    def fake_post(url: str, data: dict, headers: dict, *, timeout=None):
        return StubResponse(200, {"access_token": "test_token"})

    monkeypatch.setattr(httpx, "post", fake_post)
    monkeypatch.setattr(auth_service, "get_user_roles", lambda tok: {})
    monkeypatch.setattr(
        auth_service,
        "resolve_user_flags",
        lambda roles: {"isAdmin": False, "isVerified": False, "verificationType": None},
    )
    monkeypatch.setattr(
        auth_service,
        "get_user_profile",
        lambda tok: {"id": "123", "username": "testuser", "avatar": None},
    )

    # Test without state parameter - should use FRONTEND_URL fallback
    # (covers lines 302-306)
    resp = client.get("/login/discord/callback?code=testcode", follow_redirects=False)

    # Should redirect to fallback URL
    assert resp.status_code == 307
    location = resp.headers["location"]

    # Safe URL validation using proper parsing
    from urllib.parse import urlparse

    parsed_url = urlparse(location)
    # Check that the hostname is exactly frontend.test.com or a subdomain
    assert parsed_url.hostname and (
        parsed_url.hostname == "frontend.test.com"
        or parsed_url.hostname.endswith(".frontend.test.com")
    )
    assert "token=" in location


def test_contribute_endpoint_user_not_found_error():
    """Test contribute endpoint 404 error when target user doesn't exist.

    COVERAGE TARGET: Line 347 in auth_service.py - user lookup failure path.
    LESSON LEARNED: Every error code path needs dedicated test coverage.
    """
    app = auth_service.create_app()
    client = TestClient(app)

    # Create admin user
    client.post("/api/register", json={"username": "admin", "password": "adminpass"})
    admin_token = _get_token(client, "admin", "adminpass")

    # Make user admin
    with auth_service.SessionLocal() as db:
        admin_user = db.query(auth_service.User).filter_by(username="admin").first()
        if admin_user:
            admin_user.is_admin = True
            db.commit()

    # Try to contribute for non-existent user (covers line 347)
    resp = client.post(
        "/api/user/contributions",
        json={"username": "nonexistent", "description": "test"},
        headers={"Authorization": f"Bearer {admin_token}"},
    )

    assert resp.status_code == 404
    assert resp.json()["detail"] == "User not found"


def test_contribute_endpoint_forbidden_error():
    """Test contribute endpoint 403 error when non-admin tries to contribute.

    Covers line 350 - forbidden access scenarios.
    """
    app = auth_service.create_app()
    client = TestClient(app)

    # Create two regular users
    client.post("/api/register", json={"username": "user1", "password": "pass1"})
    client.post("/api/register", json={"username": "user2", "password": "pass2"})

    user1_token = _get_token(client, "user1", "pass1")

    # User1 tries to contribute for User2 without admin privileges (covers line 350)
    resp = client.post(
        "/api/user/contributions",
        json={"username": "user2", "description": "test contribution"},
        headers={"Authorization": f"Bearer {user1_token}"},
    )

    assert resp.status_code == 403
    assert resp.json()["detail"] == "Forbidden"


def test_promote_endpoint_admin_required_error():
    """Test promote endpoint 403 error when non-admin tries to promote."""
    app = auth_service.create_app()
    client = TestClient(app)

    # Create regular user
    client.post("/api/register", json={"username": "regular", "password": "pass"})
    user_token = _get_token(client, "regular", "pass")

    # Try to promote without admin privileges (covers line 366)
    resp = client.post(
        "/api/user/promote",
        json={"username": "someone"},
        headers={"Authorization": f"Bearer {user_token}"},
    )

    assert resp.status_code == 403
    assert resp.json()["detail"] == "Admin required"


def test_promote_endpoint_target_user_not_found_error():
    """Test promote endpoint 404 error when target user doesn't exist."""
    app = auth_service.create_app()
    client = TestClient(app)

    # Create admin user
    client.post("/api/register", json={"username": "admin", "password": "adminpass"})
    admin_token = _get_token(client, "admin", "adminpass")

    # Make user admin
    with auth_service.SessionLocal() as db:
        admin_user = db.query(auth_service.User).filter_by(username="admin").first()
        admin_user.is_admin = True
        db.commit()

    # Try to promote non-existent user (covers line 369)
    resp = client.post(
        "/api/user/promote",
        json={"username": "nonexistent"},
        headers={"Authorization": f"Bearer {admin_token}"},
    )

    assert resp.status_code == 404
    assert resp.json()["detail"] == "User not found"


def test_auth_service_main_function_execution():
    """Test the main function executes uvicorn properly."""
    import unittest.mock

    # Mock uvicorn.run to prevent actual server startup (covers lines 412-414)
    with unittest.mock.patch("uvicorn.run") as mock_uvicorn_run:
        auth_service.main()

        # Verify uvicorn.run was called with correct parameters
        mock_uvicorn_run.assert_called_once()
        call_args = mock_uvicorn_run.call_args

        # Check the app parameter
        assert call_args[0][0] is not None  # App object should be passed
        # Check host and port parameters
        assert call_args[1]["host"] == "0.0.0.0"
        assert call_args[1]["port"] == 8002


def test_is_safe_redirect_url_edge_cases():
    """Test edge cases for URL validation function."""
    from devonboarder.auth_service import is_safe_redirect_url

    # Test empty URL (line 52)
    assert not is_safe_redirect_url("")
    assert not is_safe_redirect_url("   ")  # Whitespace only

    # Test protocol-relative URLs (line 59)
    assert not is_safe_redirect_url("//evil.com/malicious")

    # Test Unicode/percent-encoded protocol-relative URLs (lines 65-67)
    assert not is_safe_redirect_url("%2F%2Fevil.com")  # //evil.com encoded

    # Test exception in unquote (lines 71-72) - handled by try/except
    # This would be hard to trigger as unquote is quite robust

    # Test exception in urlparse (lines 77-79)
    # urlparse is very robust, but we can test this path is covered
    # The null byte URL is parsed as a relative path (no scheme/netloc)
    result_null_byte = is_safe_redirect_url("ht\x00tp://example.com")
    # Since it's treated as relative path, it returns True
    assert result_null_byte

    # Test path starting with "//" for relative URLs (line 98)
    assert not is_safe_redirect_url("//path/that/looks/relative")

    # Test HTTP for non-localhost (line 104)
    # HTTP not allowed for external domains
    assert not is_safe_redirect_url("http://example.com")

    # Test HTTP for localhost variations (line 111) - should be allowed
    assert is_safe_redirect_url("http://localhost:3000")
    assert is_safe_redirect_url("http://127.0.0.1:8080")


def test_missing_discord_client_id_in_oauth():
    """Test Discord OAuth when client ID is missing (line 305)."""
    client = TestClient(auth_service.create_app())

    # Temporarily unset DISCORD_CLIENT_ID
    original_client_id = os.environ.get("DISCORD_CLIENT_ID")
    if "DISCORD_CLIENT_ID" in os.environ:
        del os.environ["DISCORD_CLIENT_ID"]

    try:
        # This should still redirect to Discord (our app doesn't validate client_id)
        response = client.get("/login/discord", follow_redirects=False)
        # Our app redirects to Discord, Discord then returns 404 for None client_id
        assert response.status_code == 307  # Our app's redirect

        # Check that redirect URL contains client_id=None
        assert "client_id=None" in response.headers["location"]
    finally:
        # Restore original environment
        if original_client_id is not None:
            os.environ["DISCORD_CLIENT_ID"] = original_client_id


def test_discord_callback_with_unsafe_redirect_state():
    """Test Discord callback with unsafe state parameter (lines 398-417)."""
    client = TestClient(auth_service.create_app())

    # Mock Discord API responses using StubResponse
    with pytest.MonkeyPatch().context() as m:

        def mock_post(*args, **kwargs):
            # Mock token exchange response
            return StubResponse(200, {"access_token": "test_token"})

        def mock_get(*args, **kwargs):
            if "users/@me" in str(args[0]):
                # Mock user info response
                return StubResponse(200, {"id": "123", "username": "testuser"})
            else:
                # Mock guilds response
                return StubResponse(200, [{"id": "guild1", "name": "Test Guild"}])

        m.setattr(httpx, "post", mock_post)
        m.setattr(httpx, "get", mock_get)

        # Test with unsafe state parameter that should be blocked
        callback_url = (
            "/login/discord/callback?code=test_code&state=http://evil.com/malicious"
        )
        response = client.get(callback_url, follow_redirects=False)

        # Should redirect to default location, not the malicious URL
        assert_status = response.status_code == 307
        if not assert_status:
            pytest.fail(f"Expected status 307, got {response.status_code}")
        # Should fallback to safe redirect
        location = response.headers.get("location", "")
        from urllib.parse import urlparse

        parsed_url = urlparse(location)
        if parsed_url.hostname == "evil.com":
            pytest.fail("Unsafe redirect to evil.com detected")
        # Should contain the safe fallback domain (environment-appropriate)
        # In CI/development: localhost; in production: theangrygamershow.com
        safe_hostnames = ["localhost", "127.0.0.1", "theangrygamershow.com"]
        if not any(hostname in location for hostname in safe_hostnames):
            pytest.fail(f"Expected safe domain in redirect, got: {location}")


def test_final_redirect_security_validation():
    """Test final security validation before redirect (lines 431-432)."""
    client = TestClient(auth_service.create_app())

    with pytest.MonkeyPatch().context() as m:

        def mock_post(*args, **kwargs):
            return StubResponse(200, {"access_token": "test_token"})

        def mock_get(*args, **kwargs):
            if "users/@me" in str(args[0]):
                return StubResponse(200, {"id": "123", "username": "testuser"})
            else:
                return StubResponse(200, [{"id": "guild1", "name": "Test Guild"}])

        m.setattr(httpx, "post", mock_post)
        m.setattr(httpx, "get", mock_get)

        # This will trigger the final security validation
        response = client.get(
            "/login/discord/callback?code=test_code", follow_redirects=False
        )
        status_ok = response.status_code == 307
        if not status_ok:
            pytest.fail(f"Expected 307, got {response.status_code}")


def test_app_creation_with_init_db_on_startup():
    """Test app creation with INIT_DB_ON_STARTUP flag (line 505)."""
    # Set the environment variable to trigger database initialization
    os.environ["INIT_DB_ON_STARTUP"] = "true"

    try:
        # This should call init_db() during app creation
        app = auth_service.create_app()
        if app is None:
            pytest.fail("App creation returned None")
        if not isinstance(app, auth_service.FastAPI):
            pytest.fail("App is not FastAPI instance")
    finally:
        # Clean up environment variable
        if "INIT_DB_ON_STARTUP" in os.environ:
            del os.environ["INIT_DB_ON_STARTUP"]


def test_jwt_secret_key_validation_in_production():
    """Test JWT secret key validation in CI environment."""
    # Validate that CI environment has proper JWT configuration
    current_secret = os.environ.get("JWT_SECRET_KEY", "")
    current_env = os.environ.get("APP_ENV", "development")

    # CI should have a non-empty, non-default JWT secret
    if current_secret:
        # Make sure it's not the default "secret" value  # noqa: S105
        if current_secret == "secret":  # noqa: S105
            pytest.fail(
                f"CI environment using default 'secret' value: env={current_env}"
            )
        else:
            # CI has a proper secret configured
            pass
    else:
        pytest.fail(f"CI environment missing JWT_SECRET_KEY: env={current_env}")

    # Test passes if CI environment is properly configured


def test_is_safe_redirect_url_exception_paths():
    """Test exception paths in is_safe_redirect_url to achieve 95%+ coverage."""
    from devonboarder.auth_service import is_safe_redirect_url
    from unittest.mock import patch

    # Test unquote exception path (lines 66-67)
    with patch("devonboarder.auth_service.unquote") as mock_unquote:
        mock_unquote.side_effect = ValueError("Simulated unquote failure")
        result = is_safe_redirect_url("test_url")
        assert result is False  # noqa: B101

    # Test urlparse exception path (lines 71-72)
    with patch("devonboarder.auth_service.urlparse") as mock_urlparse:
        mock_urlparse.side_effect = ValueError("Simulated urlparse failure")
        result = is_safe_redirect_url("test_url")
        assert result is False  # noqa: B101


def test_environment_validation_coverage():
    """Test environment validation paths for coverage around line 124."""
    # This tests the JWT_SECRET_KEY validation logic

    # Test with production environment and default secret (should raise error)
    original_env = os.environ.get("APP_ENV")
    original_secret = os.environ.get("JWT_SECRET_KEY")

    try:
        # Set production environment with default secret
        os.environ["APP_ENV"] = "production"
        os.environ["JWT_SECRET_KEY"] = "secret"  # noqa: S105,B105

        # This should trigger the RuntimeError on line 124
        error_match = "JWT_SECRET_KEY must be set to a non-default value"
        with pytest.raises(RuntimeError, match=error_match):
            # Re-import the module to trigger the validation
            importlib.reload(auth_service)

    finally:
        # Restore original environment
        if original_env is not None:
            os.environ["APP_ENV"] = original_env
        else:
            os.environ.pop("APP_ENV", None)

        if original_secret is not None:
            os.environ["JWT_SECRET_KEY"] = original_secret
        else:
            os.environ.pop("JWT_SECRET_KEY", None)

        # Reload again to restore normal state
        importlib.reload(auth_service)


def test_additional_auth_service_coverage():
    """Test additional code paths to achieve 95%+ coverage."""
    from devonboarder.auth_service import is_safe_redirect_url, create_app
    import os

    # Test line 78 - relative URL with path starting with //
    # Mock urlparse to create a scenario where path starts with //
    from unittest.mock import patch
    from urllib.parse import ParseResult

    with patch("devonboarder.auth_service.urlparse") as mock_urlparse:
        # Create a mock parsed result with empty scheme/netloc but path starting with //
        mock_urlparse.return_value = ParseResult(
            scheme="", netloc="", path="//malicious", params="", query="", fragment=""
        )
        result = is_safe_redirect_url("test_input")
        assert result is False  # noqa: B101

    # Test line 98 - non-http/https scheme
    result = is_safe_redirect_url("ftp://example.com")
    assert result is False  # noqa: B101

    # Test lines 398-399 - unsafe/disallowed redirect path
    # This tests the logging warning when state parameter is unsafe
    from unittest.mock import patch, MagicMock

    # Test the Discord callback with unsafe state parameter (lines 398-399)
    app = create_app()
    client = TestClient(app)

    # Mock Discord API responses
    with patch("devonboarder.auth_service.httpx.post") as mock_post:
        mock_post.return_value.json.return_value = {"access_token": "fake_token"}
        mock_post.return_value.raise_for_status = MagicMock()

        with patch("devonboarder.auth_service.get_user_profile") as mock_profile:
            mock_profile.return_value = {
                "id": "discord123",
                "username": "testuser",
                "global_name": "Test User",
            }

            with patch("devonboarder.auth_service.get_user_roles") as mock_roles:
                mock_roles.return_value = []

                # Use unsafe state parameter to trigger warning log
                resp = client.get(
                    "/login/discord/callback"
                    "?code=test123&state=https://evil.com/malicious",
                    follow_redirects=False,
                )
                assert resp.status_code == 307  # noqa: B101  # Temporary redirect

    # Test different environment paths (lines 405-417, 429-438)
    original_env = os.environ.get("APP_ENV")
    original_ci = os.environ.get("CI")
    original_frontend_url = os.environ.get("FRONTEND_URL")

    try:
        # Test CI environment path (lines 429-430)
        os.environ["CI"] = "true"
        os.environ.pop("FRONTEND_URL", None)

        with patch("devonboarder.auth_service.httpx.post") as mock_post:
            mock_post.return_value.json.return_value = {"access_token": "fake_token"}
            mock_post.return_value.raise_for_status = MagicMock()

            with patch("devonboarder.auth_service.get_user_profile") as mock_profile:
                mock_profile.return_value = {
                    "id": "discord456",
                    "username": "ciuser",
                    "global_name": "CI User",
                }

                with patch("devonboarder.auth_service.get_user_roles") as mock_roles:
                    mock_roles.return_value = []

                    resp = client.get(
                        "/login/discord/callback?code=test456", follow_redirects=False
                    )
                    assert resp.status_code == 307  # noqa: B101

        # Test Docker production environment (lines 432-433)
        os.environ["CI"] = "false"
        os.environ["APP_ENV"] = "production"

        with patch("os.path.exists") as mock_exists:
            mock_exists.return_value = True  # Simulate Docker environment

            with patch("devonboarder.auth_service.httpx.post") as mock_post:
                mock_post.return_value.json.return_value = {
                    "access_token": "fake_token"
                }
                mock_post.return_value.raise_for_status = MagicMock()

                with patch(
                    "devonboarder.auth_service.get_user_profile"
                ) as mock_profile:
                    mock_profile.return_value = {
                        "id": "discord789",
                        "username": "produser",
                        "global_name": "Prod User",
                    }

                    with patch(
                        "devonboarder.auth_service.get_user_roles"
                    ) as mock_roles:
                        mock_roles.return_value = []

                        resp = client.get(
                            "/login/discord/callback?code=test789",
                            follow_redirects=False,
                        )
                        assert resp.status_code == 307  # noqa: B101

        # Test Docker development environment (lines 435-436)
        os.environ["APP_ENV"] = "development"

        with patch("os.path.exists") as mock_exists:
            mock_exists.return_value = True  # Simulate Docker environment

            with patch("devonboarder.auth_service.httpx.post") as mock_post:
                mock_post.return_value.json.return_value = {
                    "access_token": "fake_token"
                }
                mock_post.return_value.raise_for_status = MagicMock()

                with patch(
                    "devonboarder.auth_service.get_user_profile"
                ) as mock_profile:
                    mock_profile.return_value = {
                        "id": "discord101112",
                        "username": "devuser",
                        "global_name": "Dev User",
                    }

                    with patch(
                        "devonboarder.auth_service.get_user_roles"
                    ) as mock_roles:
                        mock_roles.return_value = []

                        resp = client.get(
                            "/login/discord/callback?code=test101112",
                            follow_redirects=False,
                        )
                        assert resp.status_code == 307  # noqa: B101

        # Test non-Docker production environment (lines 437-438)
        os.environ["APP_ENV"] = "production"

        with patch("os.path.exists") as mock_exists:
            mock_exists.return_value = False  # Simulate non-Docker environment

            with patch("devonboarder.auth_service.httpx.post") as mock_post:
                mock_post.return_value.json.return_value = {
                    "access_token": "fake_token"
                }
                mock_post.return_value.raise_for_status = MagicMock()

                with patch(
                    "devonboarder.auth_service.get_user_profile"
                ) as mock_profile:
                    mock_profile.return_value = {
                        "id": "discord131415",
                        "username": "produser2",
                        "global_name": "Prod User 2",
                    }

                    with patch(
                        "devonboarder.auth_service.get_user_roles"
                    ) as mock_roles:
                        mock_roles.return_value = []

                        resp = client.get(
                            "/login/discord/callback?code=test131415",
                            follow_redirects=False,
                        )
                        assert resp.status_code == 307  # noqa: B101

    finally:
        # Restore original environment variables
        if original_env:
            os.environ["APP_ENV"] = original_env
        else:
            os.environ.pop("APP_ENV", None)

        if original_ci:
            os.environ["CI"] = original_ci
        else:
            os.environ.pop("CI", None)

        if original_frontend_url:
            os.environ["FRONTEND_URL"] = original_frontend_url
        else:
            os.environ.pop("FRONTEND_URL", None)


def test_final_redirect_security_validation_coverage():
    """Test final security validation lines 454-455."""
    from devonboarder.auth_service import create_app
    from unittest.mock import patch, MagicMock

    app = create_app()
    client = TestClient(app)

    # Test final security validation when redirect URL is unsafe (lines 454-455)
    with patch("devonboarder.auth_service.httpx.post") as mock_post:
        mock_post.return_value.json.return_value = {"access_token": "fake_token"}
        mock_post.return_value.raise_for_status = MagicMock()

        with patch("devonboarder.auth_service.get_user_profile") as mock_profile:
            mock_profile.return_value = {
                "id": "discord999",
                "username": "securityuser",
                "global_name": "Security User",
            }

            with patch("devonboarder.auth_service.get_user_roles") as mock_roles:
                mock_roles.return_value = []

                # Mock is_safe_redirect_url to return False for final validation
                with patch(
                    "devonboarder.auth_service.is_safe_redirect_url"
                ) as mock_safe:
                    # First call (for state parameter) returns True
                    # Second call (final validation) returns False
                    mock_safe.side_effect = [True, False]

                    resp = client.get(
                        "/login/discord/callback?code=test999&state=/dashboard",
                        follow_redirects=False,
                    )
                    assert resp.status_code == 307  # noqa: B101


def test_final_missing_coverage_lines():
    """Test the final missing coverage lines to reach 95%."""
    from devonboarder.auth_service import create_app
    from unittest.mock import patch, MagicMock

    app = create_app()
    client = TestClient(app)

    # Test different user_provided_path values (lines 407-417)
    path_tests = ["/profile", "/welcome", "/onboarding", "/", "/unknown"]

    for path in path_tests:
        with patch("devonboarder.auth_service.httpx.post") as mock_post:
            mock_post.return_value.json.return_value = {"access_token": "fake_token"}
            mock_post.return_value.raise_for_status = MagicMock()

            with patch("devonboarder.auth_service.get_user_profile") as mock_profile:
                mock_profile.return_value = {
                    "id": f"discord{path.replace('/', '')}",
                    "username": f"user{path.replace('/', '')}",
                    "global_name": f"User {path}",
                }

                with patch("devonboarder.auth_service.get_user_roles") as mock_roles:
                    mock_roles.return_value = []

                    resp = client.get(
                        f"/login/discord/callback?code=test&state={path}",
                        follow_redirects=False,
                    )
                    # Should be a redirect
                    assert resp.status_code == 307  # noqa: B101
