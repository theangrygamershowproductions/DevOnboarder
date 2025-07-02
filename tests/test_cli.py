import sys
import runpy

from devonboarder.cli import main


def test_cli_prints_greeting(capsys, monkeypatch):
    """devonboarder.cli.main prints greeting for given name."""
    monkeypatch.setattr(sys, "argv", ["devonboarder", "Codex"])
    main()
    captured = capsys.readouterr()
    assert captured.out.strip() == "Hello, Codex!"


def test_cli_prints_default_greeting(capsys, monkeypatch):
    """devonboarder.cli.main prints default greeting when no name given."""
    monkeypatch.setattr(sys, "argv", ["devonboarder"])
    main()
    captured = capsys.readouterr()
    assert captured.out.strip() == "Hello, World!"


def test_cli_invocation_via_module(monkeypatch, capsys):
    monkeypatch.setattr(sys, "argv", ["devonboarder", "Bot"])
    runpy.run_module("devonboarder.cli", run_name="__main__")
    captured = capsys.readouterr()
    assert captured.out.strip() == "Hello, Bot!"
