from devonboarder.xp_api import create_app
from devonboarder import auth_service
from fastapi.testclient import TestClient


def setup_function(function):
    auth_service.Base.metadata.drop_all(bind=auth_service.engine)
    auth_service.init_db()


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
