import importlib
import subprocess

import diagnostics


class StubResp:
    def __init__(self, code: int):
        self.status_code = code
        self.reason = "OK"


def test_check_packages_success(monkeypatch, capsys):
    monkeypatch.setattr(importlib, "import_module", lambda name: None)
    assert diagnostics.check_packages() == []
    out = capsys.readouterr().out
    assert "fastapi imported" in out
    assert "pytest imported" in out


def test_check_packages_failure(monkeypatch, capsys):
    def fake_import(name: str):
        if name == "pytest":
            raise ImportError("boom")
        return None

    monkeypatch.setattr(importlib, "import_module", fake_import)
    failures = diagnostics.check_packages()
    assert failures == ["Failed to import pytest: boom"]
    assert "Failed to import pytest" in capsys.readouterr().out


def test_check_health(monkeypatch):
    monkeypatch.setenv("AUTH_URL", "http://auth")
    monkeypatch.setenv("API_BASE_URL", "http://xp")
    monkeypatch.setenv("VITE_FEEDBACK_URL", "http://feedback")

    def fake_get(url: str, timeout: int = 5):
        return StubResp(200)

    monkeypatch.setattr(diagnostics.requests, "get", fake_get)
    statuses = diagnostics.check_health()
    assert statuses == {"auth": "200 OK", "xp": "200 OK", "feedback": "200 OK"}


def test_audit_env(monkeypatch, tmp_path, capsys):
    tmp_json = tmp_path / "env_audit.json"

    def fake_run(cmd, env=None, capture_output=True, text=True, check=False):
        tmp_json.write_text('{"missing":["A"],"extra":["B"]}')
        stdout = (
            "Missing variables:\nA\n\nExtra variables:\nB\n\n"
            '{"missing":["A"],"extra":["B"]}'
        )
        return subprocess.CompletedProcess(cmd, 0, stdout=stdout, stderr="")

    monkeypatch.setattr(subprocess, "run", fake_run)
    monkeypatch.chdir(tmp_path)
    result = diagnostics.audit_env()
    assert result == {"missing": ["A"], "extra": ["B"]}
    out = capsys.readouterr().out
    assert "Missing variables" in out


def test_module_cli(monkeypatch, capsys):
    monkeypatch.setattr(diagnostics, "check_packages", lambda: None)
    monkeypatch.setattr(diagnostics, "check_health", lambda: None)
    monkeypatch.setattr(diagnostics, "audit_env", lambda: None)
    diagnostics.main()
    assert capsys.readouterr().out == ""
