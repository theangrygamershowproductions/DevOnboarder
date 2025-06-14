"""Smoke tests for the DevOnboarder project."""

from pathlib import Path
import sys

sys.path.append(str(Path(__file__).resolve().parents[1] / "src"))

from app import greet


def test_greet():
    """Ensure the greet function returns the expected message."""
    assert greet("Codex") == "Hello, Codex!"
