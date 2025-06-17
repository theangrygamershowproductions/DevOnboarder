from __future__ import annotations

from http.server import BaseHTTPRequestHandler, HTTPServer

from .app import greet


class GreetingHandler(BaseHTTPRequestHandler):
    """HTTP request handler that greets the requested name."""

    def do_GET(self) -> None:  # type: ignore[override]
        name = self.path.lstrip("/") or "World"
        message = greet(name)
        self.send_response(200)
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
