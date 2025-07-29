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
