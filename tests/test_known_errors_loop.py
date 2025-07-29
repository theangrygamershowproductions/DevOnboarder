import importlib.util
import subprocess
from pathlib import Path

import yaml


def load_module(tmp_path: Path):
    spec = importlib.util.spec_from_file_location(
        "known_errors_loop",
        Path(__file__).resolve().parents[1] / "scripts" / "known_errors_loop.py",
    )
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)  # type: ignore[attr-defined]
    return module


def setup_env(tmp_path: Path):
    (tmp_path / ".codex").mkdir()
    yaml.safe_dump(
        [
            {
                "error_code": "ERR001",
                "error_message": "ModuleNotFoundError: No module named 'foo'",
                "hits": 0,
            }
        ],
        (tmp_path / ".codex" / "known_errors.yaml").open("w", encoding="utf-8"),
        sort_keys=False,
    )


def test_known_error_increments_hits(tmp_path, monkeypatch):
    monkeypatch.chdir(tmp_path)
    setup_env(tmp_path)
    log = tmp_path / "log.txt"
    log.write_text("ModuleNotFoundError: No module named 'foo'\n")
    module = load_module(tmp_path)

    module.process_log(log)

    data = yaml.safe_load((tmp_path / ".codex" / "known_errors.yaml").read_text())
    assert data[0]["hits"] == 1


def test_unknown_error_triggers_notification(tmp_path, monkeypatch):
    monkeypatch.chdir(tmp_path)
    setup_env(tmp_path)
    log = tmp_path / "log.txt"
    log.write_text("something unexpected\n")

    calls = []

    def fake_run(cmd, *a, **kw):
        calls.append(cmd)
        return subprocess.CompletedProcess(cmd, 0, "", "")

    monkeypatch.setattr(subprocess, "run", fake_run)
    module = load_module(tmp_path)
    module.process_log(log)

    notify_calls = [c for c in calls if "notify.yml" in c]
    assert notify_calls, "notify workflow not triggered"
