# PATCHED v0.1.0 tests/cli/test_platform.py — CLI OS detection tests
"""Unit tests for the cli platform helpers."""

from types import SimpleNamespace
import importlib
import sys


def load_cli(tmp_path):
    """Reload the cli module with a temp journal directory."""
    import os

    os.environ["CODEX_JOURNAL_DIR"] = str(tmp_path)
    if "cli" in sys.modules:
        del sys.modules["cli"]
    return importlib.import_module("cli")


def test_detect_linux(monkeypatch, tmp_path):
    cli = load_cli(tmp_path)
    monkeypatch.setattr(cli.platform, "system", lambda: "Linux")
    monkeypatch.setattr(cli.platform, "uname", lambda: SimpleNamespace(release="5"))
    name = cli.show_platform_tip()
    assert name == "linux"
    assert (tmp_path / "journal.log").exists()


def test_detect_wsl(monkeypatch, tmp_path):
    cli = load_cli(tmp_path)
    monkeypatch.setattr(cli.platform, "system", lambda: "Linux")
    monkeypatch.setattr(
        cli.platform,
        "uname",
        lambda: SimpleNamespace(release="5-microsoft-standard"),
    )
    name = cli.show_platform_tip()
    assert name == "wsl"


def test_detect_macos(monkeypatch, tmp_path):
    cli = load_cli(tmp_path)
    monkeypatch.setattr(cli.platform, "system", lambda: "Darwin")
    monkeypatch.setattr(cli.platform, "uname", lambda: SimpleNamespace(release="20"))
    name = cli.show_platform_tip()
    assert name == "macos"
