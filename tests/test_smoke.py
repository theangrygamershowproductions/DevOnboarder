"""Smoke tests for the DevOnboarder project."""

from app import greet


def test_greet():
    """Ensure the greet function returns the expected message."""
    assert greet("Codex") == "Hello, Codex!"
