from fastapi.middleware.cors import CORSMiddleware
from fastapi.testclient import TestClient
from devonboarder import auth_service
from xp.api import create_app
import os

# Environment variables must be set before importing modules from devonboarder.
os.environ.setdefault("APP_ENV", "development")
os.environ.setdefault("JWT_SECRET_KEY", "devsecret")


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


def _seed_data():
    with auth_service.SessionLocal() as db:
        user = auth_service.User(username="alice", password_hash="x")
        db.add(user)
        db.commit()
        db.refresh(user)
        db.add(auth_service.Contribution(user_id=user.id, description="first"))
        db.add_all(
            [
                auth_service.XPEvent(user_id=user.id, xp=120),
                auth_service.XPEvent(user_id=user.id, xp=70),
            ]
        )
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


def test_health_and_security_headers(monkeypatch):
    monkeypatch.delenv("CORS_ALLOW_ORIGINS", raising=False)
    monkeypatch.setenv("APP_ENV", "development")
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


def test_main_function(monkeypatch):
    """Test that main function can be imported and called."""
    # Mock uvicorn.run to avoid actually starting the server
    run_called = []

    def mock_run(*args, **kwargs):
        run_called.append((args, kwargs))

    monkeypatch.setattr("uvicorn.run", mock_run)

    from xp.api import main

    # Call main function
    main()

    # Verify uvicorn.run was called
    assert len(run_called) == 1  # noqa: B101
    args, kwargs = run_called[0]
    assert kwargs["host"] == "0.0.0.0"  # noqa: B101
    assert kwargs["port"] == 8001  # noqa: B101


def test_onboarding_status_missing_user():
    """Test onboarding status for non-existent user."""
    app = create_app()
    client = TestClient(app)

    resp = client.get("/api/user/onboarding-status", params={"username": "nonexistent"})
    assert resp.status_code == 404  # noqa: B101
    assert resp.json()["detail"] == "User not found"  # noqa: B101


def test_level_missing_user():
    """Test level for non-existent user."""
    app = create_app()
    client = TestClient(app)

    resp = client.get("/api/user/level", params={"username": "nonexistent"})
    assert resp.status_code == 404  # noqa: B101
    assert resp.json()["detail"] == "User not found"  # noqa: B101


def test_contribute_endpoint_auth_required(monkeypatch):
    """Test contribute endpoint requires authentication."""
    app = create_app()
    client = TestClient(app)

    # Mock get_current_user to raise HTTPException for missing auth
    def mock_get_current_user():
        from fastapi import HTTPException

        raise HTTPException(status_code=401, detail="Not authenticated")

    monkeypatch.setattr("xp.api.auth_service.get_current_user", mock_get_current_user)

    resp = client.post("/api/user/contribute", json={"description": "test"})
    # This should fail due to auth requirement
    assert resp.status_code == 403  # noqa: B101


def test_contribute_endpoint_missing_description():
    """Test contribute endpoint with missing description field."""
    token = _create_token("testuser")
    app = create_app()
    client = TestClient(app)
    headers = {"Authorization": f"Bearer {token}"}

    # Missing description field should cause server error due to KeyError
    resp = client.post("/api/user/contribute", json={}, headers=headers)
    assert resp.status_code == 500  # noqa: B101 - Server error due to missing key


def test_user_with_no_contributions():
    """Test user with no contributions shows pending onboarding status."""
    app = create_app()
    client = TestClient(app)

    # Create user with no contributions
    with auth_service.SessionLocal() as db:
        user = auth_service.User(username="nocontribs", password_hash="x")
        db.add(user)
        db.commit()

    resp = client.get("/api/user/onboarding-status", params={"username": "nocontribs"})
    assert resp.status_code == 200  # noqa: B101
    assert resp.json() == {"status": "pending"}  # noqa: B101


def test_user_with_no_xp_events():
    """Test user level calculation with no XP events."""
    app = create_app()
    client = TestClient(app)

    # Create user with no XP events
    with auth_service.SessionLocal() as db:
        user = auth_service.User(username="noxp", password_hash="x")
        db.add(user)
        db.commit()

    resp = client.get("/api/user/level", params={"username": "noxp"})
    assert resp.status_code == 200  # noqa: B101
    assert resp.json() == {"level": 1}  # noqa: B101 - Default level is 1


def test_user_level_calculation_edge_cases():
    """Test user level calculation with various XP amounts."""
    app = create_app()
    client = TestClient(app)

    test_cases = [
        ("user_0xp", 0, 1),  # 0 XP = level 1
        ("user_50xp", 50, 1),  # 50 XP = level 1
        ("user_99xp", 99, 1),  # 99 XP = level 1
        ("user_100xp", 100, 2),  # 100 XP = level 2
        ("user_199xp", 199, 2),  # 199 XP = level 2
        ("user_200xp", 200, 3),  # 200 XP = level 3
        ("user_1000xp", 1000, 11),  # 1000 XP = level 11
    ]

    for username, total_xp, expected_level in test_cases:
        with auth_service.SessionLocal() as db:
            user = auth_service.User(username=username, password_hash="x")
            db.add(user)
            db.commit()
            db.refresh(user)

            # Add XP events that sum to total_xp
            if total_xp > 0:
                db.add(auth_service.XPEvent(user_id=user.id, xp=total_xp))
                db.commit()

        resp = client.get("/api/user/level", params={"username": username})
        assert resp.status_code == 200  # noqa: B101
        assert resp.json() == {"level": expected_level}  # noqa: B101


def test_cors_configuration_with_specific_origins(monkeypatch):
    """Test CORS configuration with specific allowed origins."""
    test_origins = "https://example.com,https://api.example.com"
    monkeypatch.setenv("CORS_ALLOW_ORIGINS", test_origins)

    from xp.api import create_app
    from fastapi.middleware.cors import CORSMiddleware

    app = create_app()
    cors = next(m for m in app.user_middleware if m.cls is CORSMiddleware)
    assert cors.kwargs["allow_origins"] == [
        "https://example.com",
        "https://api.example.com",
    ]  # noqa: B101


def test_cors_default_in_non_development(monkeypatch):
    """Test CORS defaults in non-development environment."""
    monkeypatch.delenv("CORS_ALLOW_ORIGINS", raising=False)
    monkeypatch.setenv("APP_ENV", "production")

    from utils.cors import get_cors_origins

    origins = get_cors_origins()

    app = create_app()
    from fastapi.middleware.cors import CORSMiddleware

    cors = next(m for m in app.user_middleware if m.cls is CORSMiddleware)
    assert cors.kwargs["allow_origins"] == origins  # noqa: B101


def test_security_headers_middleware_coverage():
    """Test security headers middleware class."""
    from xp.api import create_app

    app = create_app()
    client = TestClient(app)

    # Test with different CORS origins to trigger different header paths
    resp = client.get("/health")
    assert resp.status_code == 200  # noqa: B101
    assert "X-Content-Type-Options" in resp.headers  # noqa: B101
    assert "Access-Control-Allow-Origin" in resp.headers  # noqa: B101


def test_security_headers_with_empty_cors_origins(monkeypatch):
    """Test security headers when no CORS origins are configured."""
    monkeypatch.setenv("CORS_ALLOW_ORIGINS", "")

    app = create_app()
    client = TestClient(app)

    resp = client.get("/health")
    assert resp.status_code == 200  # noqa: B101
    # Should default to "*" when no origins specified
    assert resp.headers["Access-Control-Allow-Origin"] == "*"  # noqa: B101


def test_router_inclusion():
    """Test that the router is properly included in the app."""
    from xp.api import create_app, router

    app = create_app()

    # Check that all router endpoints are available in the app
    app_paths = [route.path for route in app.routes if hasattr(route, "path")]
    router_paths = [route.path for route in router.routes if hasattr(route, "path")]

    for path in router_paths:
        assert path in app_paths  # noqa: B101


def test_app_middleware_configuration():
    """Test that app has correct middleware configuration."""
    from xp.api import create_app
    from fastapi.middleware.cors import CORSMiddleware

    app = create_app()

    # Should have at least CORS and Security headers middleware
    assert len(app.user_middleware) >= 2  # noqa: B101

    # Check CORS middleware configuration
    cors_middleware = next(m for m in app.user_middleware if m.cls is CORSMiddleware)
    assert cors_middleware is not None  # noqa: B101
    assert "allow_methods" in cors_middleware.kwargs  # noqa: B101
    assert "allow_headers" in cors_middleware.kwargs  # noqa: B101
    assert cors_middleware.kwargs["allow_methods"] == ["*"]  # noqa: B101
    assert cors_middleware.kwargs["allow_headers"] == ["*"]  # noqa: B101


def test_contribute_endpoint_database_transaction():
    """Test contribute endpoint creates both contribution and XP event."""
    token = _create_token("contributor")
    app = create_app()
    client = TestClient(app)
    headers = {"Authorization": f"Bearer {token}"}

    # Make contribution
    resp = client.post(
        "/api/user/contribute",
        json={"description": "test contribution"},
        headers=headers,
    )
    assert resp.status_code == 200  # noqa: B101
    assert resp.json() == {"recorded": "test contribution"}  # noqa: B101

    # Verify both contribution and XP event were created
    with auth_service.SessionLocal() as db:
        user = db.query(auth_service.User).filter_by(username="contributor").first()
        assert user is not None  # noqa: B101

        # Check contribution was recorded
        contributions = (
            db.query(auth_service.Contribution).filter_by(user_id=user.id).all()
        )
        assert len(contributions) == 1  # noqa: B101
        assert contributions[0].description == "test contribution"  # noqa: B101

        # Check XP event was recorded
        xp_events = db.query(auth_service.XPEvent).filter_by(user_id=user.id).all()
        assert len(xp_events) == 1  # noqa: B101
        assert xp_events[0].xp == auth_service.CONTRIBUTION_XP  # noqa: B101


def test_multiple_contributions_accumulate_xp():
    """Test that multiple contributions properly accumulate XP."""
    token = _create_token("multi_contributor")
    app = create_app()
    client = TestClient(app)
    headers = {"Authorization": f"Bearer {token}"}

    # Make multiple contributions
    contributions = ["first task", "second task", "third task"]
    for description in contributions:
        resp = client.post(
            "/api/user/contribute",
            json={"description": description},
            headers=headers,
        )
        assert resp.status_code == 200  # noqa: B101

    # Check level increased appropriately
    resp = client.get("/api/user/level", params={"username": "multi_contributor"})
    assert resp.status_code == 200  # noqa: B101

    # 3 contributions * CONTRIBUTION_XP(50) = 150 XP = level 2
    expected_level = (3 * auth_service.CONTRIBUTION_XP) // 100 + 1
    assert resp.json() == {"level": expected_level}  # noqa: B101
