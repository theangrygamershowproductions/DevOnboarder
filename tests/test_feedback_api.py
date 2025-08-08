from fastapi.testclient import TestClient

from feedback_service import create_app
from devonboarder import auth_service


def setup_function(function):
    # Drop and recreate all tables including feedback
    auth_service.Base.metadata.drop_all(bind=auth_service.engine)
    auth_service.Base.metadata.create_all(bind=auth_service.engine)
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


def test_submit_and_analytics():
    app = create_app()
    client = TestClient(app)

    # First, check if there are any existing feedback items
    resp = client.get("/feedback")
    assert resp.status_code == 200
    initial_count = len(resp.json()["feedback"])

    resp = client.post(
        "/feedback",
        json={"type": "bug", "description": "broken"},
    )
    assert resp.status_code == 200
    item_id = resp.json()["id"]

    resp = client.get("/feedback")
    assert resp.status_code == 200
    data = resp.json()["feedback"]

    # There should be exactly one more item than before
    assert len(data) == initial_count + 1

    # Find our newly created item by ID
    created_item = next((item for item in data if item["id"] == item_id), None)
    assert created_item is not None
    assert created_item["status"] == "open"

    resp = client.patch(f"/feedback/{item_id}", json={"status": "closed"})
    assert resp.status_code == 200

    resp = client.get("/feedback/analytics")
    assert resp.status_code == 200
    assert resp.json()["total"] >= 1  # At least our item
    # At least our closed item
    assert resp.json()["breakdown"]["bug"]["closed"] >= 1


def test_update_nonexistent_feedback():
    """Test updating feedback item that doesn't exist."""
    app = create_app()
    client = TestClient(app)

    # Try to update a non-existent item
    resp = client.patch("/feedback/99999", json={"status": "closed"})
    assert resp.status_code == 404
    assert resp.json()["detail"] == "Item not found"


def test_health_endpoint():
    """Test the health endpoint."""
    app = create_app()
    client = TestClient(app)

    resp = client.get("/health")
    assert resp.status_code == 200
    assert resp.json() == {"status": "ok"}


def test_create_app_with_init_db(monkeypatch):
    """Test app creation with INIT_DB_ON_STARTUP enabled."""
    monkeypatch.setenv("INIT_DB_ON_STARTUP", "true")

    # Mock the init_db and create_all methods to track calls
    init_db_called = []
    create_all_called = []

    def mock_init_db():
        init_db_called.append(True)

    def mock_create_all(*args, **kwargs):
        create_all_called.append(True)

    monkeypatch.setattr(auth_service, "init_db", mock_init_db)
    monkeypatch.setattr(auth_service.Base.metadata, "create_all", mock_create_all)

    app = create_app()

    # Verify that init_db and create_all were called
    assert len(init_db_called) == 1
    assert len(create_all_called) == 1
    assert app is not None
