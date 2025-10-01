#!/usr/bin/env python3
"""Smoke test that verifies CORS and security headers are present."""

import os

import requests


def _fetch_headers(url: str) -> requests.Response:
    """Return the response from the given service URL."""
    try:
        return requests.get(url, timeout=5)
    except requests.RequestException as exc:
        print(f"Request failed: {exc}")
        raise SystemExit(1)


SERVICE_URL = os.getenv("CHECK_HEADERS_URL", "http://localhost:8002/api/user")


def main() -> None:
    """Verify basic CORS and security headers."""
    resp = _fetch_headers(SERVICE_URL)
    assert "Access-Control-Allow-Origin" in resp.headers, "CORS header missing"
    assert resp.headers.get("X-Content-Type-Options") == "nosniff"
    print("CORS and security headers OK")


if __name__ == "__main__":
    main()
