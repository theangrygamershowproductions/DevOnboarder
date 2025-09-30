#!/usr/bin/env python3
"""
Tests for src/discord_integration/api.py module.

This module provides Discord OAuth integration and role lookup endpoints.
"""

from fastapi.testclient import TestClient
from fastapi import APIRouter
import httpx

from src.discord_integration.api import router, create_app
from devonboarder import auth_service


def setup_function(function):
    """Reset database before each test for isolation."""
    auth_service.Base.metadata.drop_all(bind=auth_service.engine)
    auth_service.init_db()


class StubResponse:
    """Mock HTTP response for testing."""

    def __init__(self, status_code: int, json_data: dict):
        self.status_code = status_code
        self._json = json_data

    def json(self):
        return self._json

    def raise_for_status(self):
        if self.status_code >= 400:
            raise httpx.HTTPStatusError("error", request=None, response=None)


def test_exchange_oauth_success(monkeypatch):
    """Test successful OAuth token exchange."""
    app = create_app()
    client = TestClient(app)

    # Mock httpx.post for token exchange
    def mock_post(url, data, headers, timeout):
        assert url == "https://discord.com/api/oauth2/token"
        assert data["code"] == "test_code"
        return StubResponse(200, {"access_token": "discord_token_123"})

    monkeypatch.setattr(httpx, "post", mock_post)

    # Test with new user
    response = client.post("/oauth", json={"username": "testuser", "code": "test_code"})
    assert response.status_code == 200
    data = response.json()
    assert data == {"linked": "testuser"}


def test_exchange_oauth_existing_user(monkeypatch):
    """Test OAuth exchange for existing user."""
    app = create_app()
    client = TestClient(app)

    # Create user first
    from devonboarder import auth_service

    with auth_service.SessionLocal() as db:
        existing_user = auth_service.User(
            username="existing_oauth", password_hash="", discord_token="old_token"
        )
        db.add(existing_user)
        db.commit()

    def mock_post(url, data, headers, timeout):
        return StubResponse(200, {"access_token": "new_discord_token"})

    monkeypatch.setattr(httpx, "post", mock_post)

    response = client.post(
        "/oauth", json={"username": "existing_oauth", "code": "test_code"}
    )
    assert response.status_code == 200
    data = response.json()
    assert data == {"linked": "existing_oauth"}

    # Verify token was updated
    with auth_service.SessionLocal() as db:
        user = db.query(auth_service.User).filter_by(username="existing_oauth").first()
        assert user.discord_token == "new_discord_token"


def test_exchange_oauth_timeout(monkeypatch):
    """Test OAuth exchange timeout handling."""
    app = create_app()
    client = TestClient(app)

    def mock_post_timeout(*args, **kwargs):
        raise httpx.TimeoutException("timeout")

    monkeypatch.setattr(httpx, "post", mock_post_timeout)

    response = client.post("/oauth", json={"username": "testuser", "code": "test_code"})
    assert response.status_code == 504
    assert response.json()["detail"] == "Discord API timeout"


def test_get_roles_success(monkeypatch):
    """Test successful role retrieval."""
    app = create_app()
    client = TestClient(app)

    # Create user with Discord token
    from devonboarder import auth_service

    with auth_service.SessionLocal() as db:
        user = auth_service.User(
            username="roleuser_success",
            password_hash="",
            discord_token="discord_token_456",
        )
        db.add(user)
        db.commit()

    # Mock get_user_roles
    def mock_get_user_roles(token):
        assert token == "discord_token_456"
        return {"guild1": ["admin", "moderator"], "guild2": ["member"]}

    monkeypatch.setattr(
        "src.discord_integration.api.get_user_roles", mock_get_user_roles
    )

    response = client.get("/roles?username=roleuser_success")
    assert response.status_code == 200
    data = response.json()
    assert data == {"roles": {"guild1": ["admin", "moderator"], "guild2": ["member"]}}


def test_get_roles_user_not_found():
    """Test role retrieval for non-existent user."""
    app = create_app()
    client = TestClient(app)

    response = client.get("/roles?username=nonexistent")
    assert response.status_code == 404
    assert response.json()["detail"] == "User not found"


def test_get_roles_timeout(monkeypatch):
    """Test role retrieval timeout handling."""
    app = create_app()
    client = TestClient(app)

    # Create user
    from devonboarder import auth_service

    with auth_service.SessionLocal() as db:
        user = auth_service.User(
            username="timeoutuser_roles",
            password_hash="",
            discord_token="timeout_token",
        )
        db.add(user)
        db.commit()

    # Mock get_user_roles to raise timeout
    def mock_get_user_roles_timeout(token):
        raise httpx.TimeoutException("timeout")

    monkeypatch.setattr(
        "src.discord_integration.api.get_user_roles", mock_get_user_roles_timeout
    )

    response = client.get("/roles?username=timeoutuser_roles")
    assert response.status_code == 504
    assert response.json()["detail"] == "Discord API timeout"


def test_create_app():
    """Test that create_app returns a properly configured FastAPI app."""
    app = create_app()
    assert app is not None
    assert hasattr(app, "routes")

    # Check health endpoint
    client = TestClient(app)
    response = client.get("/health")
    assert response.status_code == 200
    assert response.json() == {"status": "ok"}

    # Check router is included
    routes = [route.path for route in app.routes]
    assert "/oauth" in routes
    assert "/roles" in routes


def test_router_creation():
    """Test that the router is created correctly."""
    assert router is not None
    assert isinstance(router, APIRouter)

    routes = [route for route in router.routes]
    assert len(routes) == 2  # oauth and roles endpoints

    # Check oauth route
    oauth_route = next(
        route for route in routes if hasattr(route, "path") and route.path == "/oauth"
    )
    assert hasattr(oauth_route, "methods") and oauth_route.methods == {"POST"}

    # Check roles route
    roles_route = next(
        route for route in routes if hasattr(route, "path") and route.path == "/roles"
    )
    assert hasattr(roles_route, "methods") and roles_route.methods == {"GET"}


def test_main_function():
    """Test the main function executes uvicorn properly."""
    import unittest.mock
    from src.discord_integration.api import main

    # Mock uvicorn.run to prevent actual server startup
    with unittest.mock.patch("uvicorn.run") as mock_uvicorn_run:
        main()

        # Verify uvicorn.run was called with correct parameters
        mock_uvicorn_run.assert_called_once()
        call_args = mock_uvicorn_run.call_args

        # Check the app parameter
        assert call_args[0][0] is not None  # App object should be passed
        # Check host and port parameters
        assert call_args[1]["host"] == "0.0.0.0"
        assert call_args[1]["port"] == 8081
