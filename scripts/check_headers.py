import requests


def main():
    resp = requests.get("http://localhost:4000/api/user")
    assert "Access-Control-Allow-Origin" in resp.headers, "CORS header missing"
    assert resp.headers.get("X-Content-Type-Options") == "nosniff"
    print("CORS and security headers OK")


if __name__ == "__main__":
    main()
