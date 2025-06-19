from __future__ import annotations

import threading
import urllib.error
import urllib.request

from devonboarder.server import create_server


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


def _start_server():
    server = create_server("127.0.0.1", 0)
    host, port = server.server_address
    thread = threading.Thread(target=server.serve_forever, daemon=True)
    thread.start()
    return server, host, port, thread


def test_alpha_route_denied_without_flag():
    server, host, port, thread = _start_server()
    try:
        try:
            urllib.request.urlopen(f"http://{host}:{port}/alpha")
        except urllib.error.HTTPError as exc:
            body = exc.read().decode()
            assert exc.code == 403
            assert "Alpha access required." in body
        else:
            raise AssertionError("expected HTTPError")
    finally:
        server.shutdown()
        thread.join()


def test_alpha_route_allowed_with_flag(monkeypatch):
    monkeypatch.setenv("IS_ALPHA_USER", "true")
    server, host, port, thread = _start_server()
    try:
        with urllib.request.urlopen(f"http://{host}:{port}/alpha") as resp:
            body = resp.read().decode()
        assert body == "Welcome to the alpha program!"
    finally:
        server.shutdown()
        thread.join()


def test_founder_route_denied_without_flag():
    server, host, port, thread = _start_server()
    try:
        try:
            urllib.request.urlopen(f"http://{host}:{port}/founder")
        except urllib.error.HTTPError as exc:
            body = exc.read().decode()
            assert exc.code == 403
            assert "Founders only." in body
        else:
            raise AssertionError("expected HTTPError")
    finally:
        server.shutdown()
        thread.join()


def test_founder_route_allowed_with_flag(monkeypatch):
    monkeypatch.setenv("IS_FOUNDER", "true")
    server, host, port, thread = _start_server()
    try:
        with urllib.request.urlopen(f"http://{host}:{port}/founder") as resp:
            body = resp.read().decode()
        assert body == "Founder access granted."
    finally:
        server.shutdown()
        thread.join()


def test_alpha_route_allowed_with_mixed_case_flag(monkeypatch):
    monkeypatch.setenv("IS_ALPHA_USER", "True")
    server, host, port, thread = _start_server()
    try:
        with urllib.request.urlopen(f"http://{host}:{port}/alpha") as resp:
            body = resp.read().decode()
        assert body == "Welcome to the alpha program!"
    finally:
        server.shutdown()
        thread.join()


def test_founder_route_allowed_with_mixed_case_flag(monkeypatch):
    monkeypatch.setenv("IS_FOUNDER", "True")
    server, host, port, thread = _start_server()
    try:
        with urllib.request.urlopen(f"http://{host}:{port}/founder") as resp:
            body = resp.read().decode()
        assert body == "Founder access granted."
    finally:
        server.shutdown()
        thread.join()
