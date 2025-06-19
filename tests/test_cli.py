import sys

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
