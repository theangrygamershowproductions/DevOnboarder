import importlib.util
import json
import subprocess
from pathlib import Path


def load_module(tmp_path: Path):
    spec = importlib.util.spec_from_file_location(
        "sync_issue_to_kekb",
        Path(__file__).resolve().parents[1] / "scripts" / "sync-issue-to-kekb.py",
    )
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)  # type: ignore[attr-defined]
    return module


def test_append_closed_issue(tmp_path, monkeypatch):
    monkeypatch.chdir(tmp_path)
    (tmp_path / "docs").mkdir()

    def fake_run(cmd, capture_output=False, text=False, check=True):
        return subprocess.CompletedProcess(
            cmd,
            0,
            stdout=json.dumps({"title": "Fix bug", "body": "details", "state": "closed"}),
            stderr="",
        )

    monkeypatch.setattr(subprocess, "run", fake_run)
    module = load_module(tmp_path)
    module.append_issue("123")

    content = (tmp_path / "docs" / "KEKB.md").read_text()
    assert "## 123: Fix bug" in content
    assert "details" in content

