import importlib
import httpx
from fastapi.testclient import TestClient

import llama2_agile_helper.api as agile_api


def _stub_response(text: str):
    class StubResponse:
        def __init__(self) -> None:
            self.status_code = 200

        def json(self) -> dict[str, str]:
            return {"text": text}

        def raise_for_status(self) -> None:
            pass

    return StubResponse()


def _reload(monkeypatch):
    importlib.reload(agile_api)
    return agile_api.create_app()


def test_sprint_summary(monkeypatch):
    monkeypatch.setenv("LLAMA2_API_KEY", "key")
    app = _reload(monkeypatch)
    client = TestClient(app)

    def fake_post(url: str, json: dict, headers: dict, *, timeout=None):
        assert headers["Authorization"] == "Bearer key"
        assert "prompt" in json
        return _stub_response("summary")

    monkeypatch.setattr(httpx, "post", fake_post)

    resp = client.post("/sprint-summary", json={"notes": "done"})
    assert resp.status_code == 200
    assert resp.json() == {"summary": "summary"}


def test_groom_backlog(monkeypatch):
    monkeypatch.setenv("LLAMA2_API_KEY", "key")
    app = _reload(monkeypatch)
    client = TestClient(app)

    monkeypatch.setattr(httpx, "post", lambda *a, **kw: _stub_response("tips"))

    resp = client.post("/groom-backlog", json={"tickets": ["bug", "feature"]})
    assert resp.status_code == 200
    assert resp.json() == {"suggestions": "tips"}


def test_timeout(monkeypatch):
    monkeypatch.setenv("LLAMA2_API_KEY", "key")
    app = _reload(monkeypatch)
    client = TestClient(app)

    def raise_timeout(*args, **kwargs):
        raise httpx.TimeoutException("timeout")

    monkeypatch.setattr(httpx, "post", raise_timeout)

    resp = client.post("/sprint-summary", json={"notes": "x"})
    assert resp.status_code == 504


def test_health_and_missing_key(monkeypatch):
    monkeypatch.delenv("LLAMA2_API_KEY", raising=False)
    app = _reload(monkeypatch)
    client = TestClient(app)

    resp = client.get("/health")
    assert resp.json() == {"status": "ok"}

    resp = client.post("/sprint-summary", json={"notes": "x"})
    assert resp.status_code == 503
