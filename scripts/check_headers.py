"""Smoke test that verifies CORS and security headers are present."""

import os

import requests


SERVICE_URL = os.getenv("CHECK_HEADERS_URL", "http://localhost:8002/api/user")


def main() -> None:
    """Verify basic CORS and security headers."""
    resp = requests.get(SERVICE_URL, timeout=5)
    assert "Access-Control-Allow-Origin" in resp.headers, "CORS header missing"
    assert resp.headers.get("X-Content-Type-Options") == "nosniff"
    print("CORS and security headers OK")


if __name__ == "__main__":
    main()
