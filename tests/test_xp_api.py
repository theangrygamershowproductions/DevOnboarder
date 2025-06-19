from devonboarder.xp_api import create_app
from fastapi.testclient import TestClient


def test_onboarding_status():
    app = create_app()
    client = TestClient(app)
    response = client.get("/api/user/onboarding-status")
    assert response.status_code == 200
    assert response.json() == {"status": "pending"}


def test_user_level():
    app = create_app()
    client = TestClient(app)
    response = client.get("/api/user/level")
    assert response.status_code == 200
    assert response.json() == {"level": 1}

