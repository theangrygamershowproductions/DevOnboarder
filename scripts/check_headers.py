from fastapi.testclient import TestClient
from devonboarder.auth_service import create_app


def main() -> None:
    """Verify basic CORS and security headers."""
    client = TestClient(create_app())
    resp = client.get("/api/user")
    assert "Access-Control-Allow-Origin" in resp.headers, "CORS header missing"
    assert resp.headers.get("X-Content-Type-Options") == "nosniff"
    print("CORS and security headers OK")


if __name__ == "__main__":
    main()
