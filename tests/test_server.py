from __future__ import annotations

import sys
import threading
import urllib.request
from pathlib import Path

sys.path.append(str(Path(__file__).resolve().parents[1] / "src"))

from server import create_server


def test_http_server_greets_name():
    server = create_server("127.0.0.1", 0)
    host, port = server.server_address
    thread = threading.Thread(target=server.serve_forever, daemon=True)
    thread.start()
    try:
        with urllib.request.urlopen(f"http://{host}:{port}/Codex") as resp:
            body = resp.read().decode()
        assert body == "Hello, Codex!"
    finally:
        server.shutdown()
        thread.join()
