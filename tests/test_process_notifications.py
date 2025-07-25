import importlib.util
import json
import subprocess
import shutil
from pathlib import Path


def load_module():
    spec = importlib.util.spec_from_file_location(
        "process_notifications",
        Path(__file__).resolve().parents[1] / "scripts" / "process_notifications.py",
    )
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)  # type: ignore[attr-defined]
    return module


def test_process_notifications_adds_comment(tmp_path, monkeypatch):
    data = {"title": "Alert", "body": "something happened"}
    notify_file = tmp_path / "notify.json"
    notify_file.write_text(json.dumps(data))

    monkeypatch.chdir(tmp_path)
    monkeypatch.setattr(shutil, "which", lambda x: "gh")

    calls = []

    def fake_run(cmd, capture_output=False, text=False, check=True):
        if "list" in cmd:
            return subprocess.CompletedProcess(
                cmd,
                0,
                stdout=json.dumps(
                    [{"number": 42, "title": "Operations Notifications"}]
                ),
                stderr="",
            )
        if "comment" in cmd:
            calls.append(cmd)
            return subprocess.CompletedProcess(cmd, 0, stdout="", stderr="")
        raise AssertionError(f"Unexpected command: {cmd}")

    monkeypatch.setattr(subprocess, "run", fake_run)
    module = load_module()
    module.main(str(notify_file))

    assert calls
    assert calls[0][3] == "42"
