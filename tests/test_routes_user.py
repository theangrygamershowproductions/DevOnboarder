#!/usr/bin/env python3
"""
Tests for src/routes/user.py module.

This module provides user information endpoints for the DevOnboarder API.
"""

from devonboarder import auth_service
from src.routes.user import router
from fastapi import APIRouter
from fastapi import FastAPI
from fastapi.testclient import TestClient
import os

# Environment variables must be set before importing modules from devonboarder.
os.environ.setdefault("APP_ENV", "development")
os.environ.setdefault("JWT_SECRET_KEY", "devsecret")


def setup_function(function):
    """Reset database before each test for isolation."""
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


def _create_token(username: str)  str:
    """Create a JWT token for a test user."""
    with auth_service.SessionLocal() as db:
        user = auth_service.User(username=username, password_hash="x")
        db.add(user)
        db.commit()
        db.refresh(user)
        return auth_service.create_token(user)


def _create_user_with_attributes(username: str, **attributes)  str:
    """Create a user with specific attributes and return JWT token."""
    with auth_service.SessionLocal() as db:
        user = auth_service.User(username=username, password_hash="x", **attributes)
        db.add(user)
        db.commit()
        db.refresh(user)
        return auth_service.create_token(user)


def test_user_info_basic():
    """Test user_info endpoint with a basic user."""
    token = _create_token("testuser")

    app = FastAPI()
    app.include_router(router)
    client = TestClient(app)

    headers = {"Authorization": f"Bearer {token}"}
    response = client.get("/api/user", headers=headers)

    assert response.status_code == 200
    data = response.json()

    # With mocked Discord API, these should be the default values
    assert data["id"] == "0"
    assert data["username"] == ""
    assert data["avatar"] is None
    assert data["isAdmin"] is False
    assert data["isVerified"] is False
    assert data["verificationType"] is None
    assert data["roles"] == {}


def test_router_creation():
    """Test that the router is created correctly."""
    # Verify router exists and has the expected route
    assert router is not None
    assert isinstance(router, APIRouter)

    # Check that the route is registered
    routes = [route for route in router.routes]
    assert len(routes) == 1

    route = routes[0]
    assert hasattr(route, "path") and route.path == "/api/user"
    assert hasattr(route, "methods") and route.methods == {"GET"}
