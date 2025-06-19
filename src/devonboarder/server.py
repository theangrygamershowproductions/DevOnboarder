from __future__ import annotations

from http.server import BaseHTTPRequestHandler, HTTPServer
import os

from .app import greet


def is_alpha_user() -> bool:
    """Return ``True`` if the alpha feature flag is enabled."""
    return os.getenv("IS_ALPHA_USER", "false").lower() == "true"


def is_founder() -> bool:
    """Return ``True`` if the founder feature flag is enabled."""
    return os.getenv("IS_FOUNDER", "false").lower() == "true"


class GreetingHandler(BaseHTTPRequestHandler):
    """HTTP request handler that greets the requested name."""

    def do_GET(self) -> None:  # type: ignore[override]
        path = self.path.lstrip("/") or "World"
        status = 200
        if path == "alpha":
            if is_alpha_user():
                message = "Welcome to the alpha program!"
            else:
                status = 403
                message = "Alpha access required."
        elif path == "founder":
            if is_founder():
                message = "Founder access granted."
            else:
                status = 403
                message = "Founders only."
        else:
            message = greet(path)

        self.send_response(status)
        self.send_header("Content-Type", "text/plain; charset=utf-8")
        self.end_headers()
        self.wfile.write(message.encode("utf-8"))

    def log_message(self, format: str, *args: object) -> None:  # noqa: D401
        """Silence default logging output for cleaner tests."""
        return


def create_server(host: str = "0.0.0.0", port: int = 8000) -> HTTPServer:
    """Create an HTTP server serving :class:`GreetingHandler`."""
    return HTTPServer((host, port), GreetingHandler)


def main() -> None:
    """Run the greeting HTTP server until interrupted."""
    server = create_server()
    host, port = server.server_address
    print(f"Serving on {host}:{port}")
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        pass


if __name__ == "__main__":
    main()
