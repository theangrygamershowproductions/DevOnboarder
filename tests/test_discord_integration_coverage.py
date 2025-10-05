"""Additional tests for Discord integration to achieve 95% coverage."""

import httpx
from fastapi.testclient import TestClient

from src.discord_integration.api import create_app
from src.devonboarder import auth_service


class StubResponse:
    """Stub response for mocking HTTP requests."""

    def __init__(self, status_code, data):
        self.status_code = status_code
        self._data = data

    def json(self):
        return self._data

    def raise_for_status(self):
        pass


def test_oauth_exchange_general_exception(monkeypatch):
    """Test OAuth exchange with general exception during Discord API call."""
    app = create_app()
    client = TestClient(app)

    def mock_discord_get_user_timeout(token):
        """Mock that raises timeout."""
        raise RuntimeError("General network error")

    def mock_post_exception(*args, **kwargs):
        """Mock post that raises exception."""
        raise httpx.HTTPError("Network error")

    monkeypatch.setattr(httpx, "post", mock_post_exception)

    response = client.post("/oauth", json={"username": "testuser", "code": "test_code"})
    assert response.status_code == 500  # noqa: B101
    assert "Discord API error" in response.json()["detail"]  # noqa: B101


def test_oauth_creates_new_user(monkeypatch):
    """Test OAuth exchange creates new user when user doesn't exist."""
    app = create_app()
    client = TestClient(app)

    def mock_post_success(*args, **kwargs):
        """Mock successful Discord API response."""
        response = httpx.Response(
            200, json={"access_token": "test_token", "token_type": "Bearer"}
        )
        # Mock the raise_for_status method to avoid the missing request issue
        response.raise_for_status = lambda: None
        return response

    monkeypatch.setattr(httpx, "post", mock_post_success)

    # Ensure clean database state
    with auth_service.SessionLocal() as db:
        existing_user = (
            db.query(auth_service.User).filter_by(username="newuser").first()
        )
        if existing_user:
            db.delete(existing_user)
            db.commit()

    response = client.post("/oauth", json={"username": "newuser", "code": "test_code"})
    assert response.status_code == 200  # noqa: B101
    assert response.json()["linked"] == "newuser"  # noqa: B101

    # Verify user was created
    with auth_service.SessionLocal() as db:
        user = db.query(auth_service.User).filter_by(username="newuser").first()
        assert user is not None  # noqa: B101
        assert user.discord_token == "test_token"  # noqa: B101
        # For Discord-only accounts, password hash is intentionally empty
        # as these users authenticate via Discord OAuth without local passwords
        assert user.password_hash == ""  # noqa: B106 B101

        # Clean up
        db.delete(user)
        db.commit()


def test_oauth_updates_existing_user(monkeypatch):
    """Test OAuth exchange updates existing user's token (lines 81-83)."""
    app = create_app()
    client = TestClient(app)

    def mock_post_success(*args, **kwargs):
        """Mock successful Discord API response."""
        response = httpx.Response(
            200, json={"access_token": "new_token", "token_type": "Bearer"}
        )
        # Mock the raise_for_status method to avoid the missing request issue
        response.raise_for_status = lambda: None
        return response

    monkeypatch.setattr(httpx, "post", mock_post_success)

    # Create existing user
    with auth_service.SessionLocal() as db:
        # Clean up first
        existing_user = (
            db.query(auth_service.User).filter_by(username="existinguser").first()
        )
        if existing_user:
            db.delete(existing_user)
            db.commit()

        user = auth_service.User(
            username="existinguser",
            password_hash="existing_hash",  # noqa: B106
            discord_token="old_token",
        )
        db.add(user)
        db.commit()

    response = client.post(
        "/oauth", json={"username": "existinguser", "code": "test_code"}
    )
    assert response.status_code == 200  # noqa: B101
    assert response.json()["linked"] == "existinguser"  # noqa: B101

    # Verify user token was updated
    with auth_service.SessionLocal() as db:
        user = db.query(auth_service.User).filter_by(username="existinguser").first()
        assert user is not None  # noqa: B101
        assert user.discord_token == "new_token"  # noqa: B101
        assert user.password_hash == "existing_hash"  # noqa: B101 B106

        # Clean up
        db.delete(user)
        db.commit()


def test_get_roles_none_token():
    """Test get_roles with None discord token (line 98)."""
    app = create_app()
    client = TestClient(app)

    # Create user with None discord token
    with auth_service.SessionLocal() as db:
        # Clean up existing user
        existing_user = (
            db.query(auth_service.User).filter_by(username="nonetoken").first()
        )
        if existing_user:
            db.delete(existing_user)
            db.commit()

        user = auth_service.User(
            username="nonetoken",
            password_hash="hash",  # noqa: B106
            discord_token=None,
        )
        db.add(user)
        db.commit()

    response = client.get("/roles?username=nonetoken")
    assert response.status_code == 404  # noqa: B101
    assert "Discord token not found" in response.json()["detail"]  # noqa: B101

    # Clean up
    with auth_service.SessionLocal() as db:
        user = db.query(auth_service.User).filter_by(username="nonetoken").first()
        if user:
            db.delete(user)
            db.commit()


def test_get_roles_empty_token():
    """Test get_roles with empty discord token."""
    app = create_app()
    client = TestClient(app)

    # Create user with empty discord token
    with auth_service.SessionLocal() as db:
        # Clean up existing user
        existing_user = (
            db.query(auth_service.User).filter_by(username="emptytoken").first()
        )
        if existing_user:
            db.delete(existing_user)
            db.commit()

        user = auth_service.User(
            username="emptytoken",
            password_hash="hash",  # noqa: B106
            discord_token="",
        )
        db.add(user)
        db.commit()

    response = client.get("/roles?username=emptytoken")
    assert response.status_code == 404  # noqa: B101
    assert "Invalid Discord token" in response.json()["detail"]  # noqa: B101

    # Clean up
    with auth_service.SessionLocal() as db:
        user = db.query(auth_service.User).filter_by(username="emptytoken").first()
        if user:
            db.delete(user)
            db.commit()


def test_get_roles_timeout_exception(monkeypatch):
    """Test get_roles with timeout exception from get_user_roles."""
    app = create_app()
    client = TestClient(app)

    # Create user with valid discord token
    with auth_service.SessionLocal() as db:
        # Clean up existing user
        existing_user = (
            db.query(auth_service.User).filter_by(username="timeoutuser").first()
        )
        if existing_user:
            db.delete(existing_user)
            db.commit()

        user = auth_service.User(
            username="timeoutuser",
            password_hash="hash",  # noqa: B106
            discord_token="valid_token",
        )
        db.add(user)
        db.commit()

    def mock_timeout(token):
        raise httpx.TimeoutException("Discord API timeout")

    monkeypatch.setattr("src.discord_integration.api.get_user_roles", mock_timeout)

    response = client.get("/roles?username=timeoutuser")
    assert response.status_code == 504  # noqa: B101
    assert "Discord API timeout" in response.json()["detail"]  # noqa: B101

    # Clean up
    with auth_service.SessionLocal() as db:
        user = db.query(auth_service.User).filter_by(username="timeoutuser").first()
        if user:
            db.delete(user)
            db.commit()


def test_get_roles_general_exception(monkeypatch):
    """Test get_roles with general exception from get_user_roles."""
    app = create_app()
    client = TestClient(app)

    # Create user with valid discord token
    with auth_service.SessionLocal() as db:
        # Clean up existing user
        existing_user = (
            db.query(auth_service.User).filter_by(username="erroruser").first()
        )
        if existing_user:
            db.delete(existing_user)
            db.commit()

        user = auth_service.User(
            username="erroruser",
            password_hash="hash",  # noqa: B106
            discord_token="valid_token",
        )
        db.add(user)
        db.commit()

    def mock_error(*args, **kwargs):
        raise RuntimeError("General error from Discord utils")

    monkeypatch.setattr("src.utils.discord.get_user_roles", mock_error)

    response = client.get("/roles?username=erroruser")
    assert response.status_code == 500  # noqa: B101
    assert "Database error" in response.json()["detail"]  # noqa: B101

    # Clean up
    with auth_service.SessionLocal() as db:
        user = db.query(auth_service.User).filter_by(username="erroruser").first()
        if user:
            db.delete(user)
            db.commit()
