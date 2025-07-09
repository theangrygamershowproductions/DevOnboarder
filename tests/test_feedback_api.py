from fastapi.testclient import TestClient

from feedback_service import create_app
from devonboarder import auth_service


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


def test_submit_and_analytics():
    app = create_app()
    client = TestClient(app)

    resp = client.post(
        "/feedback",
        json={"type": "bug", "description": "broken"},
    )
    assert resp.status_code == 200
    item_id = resp.json()["id"]

    resp = client.get("/feedback")
    assert resp.status_code == 200
    data = resp.json()["feedback"]
    assert data[0]["id"] == item_id
    assert data[0]["status"] == "open"

    resp = client.patch(f"/feedback/{item_id}", json={"status": "closed"})
    assert resp.status_code == 200

    resp = client.get("/feedback/analytics")
    assert resp.status_code == 200
    assert resp.json()["total"] == 1
    assert resp.json()["breakdown"]["bug"]["closed"] == 1
