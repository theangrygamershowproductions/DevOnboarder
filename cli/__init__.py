# PATCHED v0.1.0 cli/__init__.py — Platform tips utility
"""Simple CLI helpers for detecting the host OS and recording tips."""

from __future__ import annotations

import os
import platform
from pathlib import Path

# Allow tests to override the journal directory
JOURNAL_DIR = Path(os.environ.get("CODEX_JOURNAL_DIR", "codex/journal"))
JOURNAL_DIR.mkdir(parents=True, exist_ok=True)

PLATFORM_TIPS = {
    "linux": "Tip: you're running on Linux; apt packages are your friend.",
    "wsl": "Tip: WSL detected; ensure virtualization and Windows Terminal are up to date.",
    "macos": "Tip: macOS users can install packages with Homebrew.",
}


def detect_platform() -> str:
    """Return a simple platform identifier."""
    system = platform.system()
    release = platform.uname().release.lower()
    if "microsoft" in release:
        return "wsl"
    if system == "Darwin":
        return "macos"
    if system == "Linux":
        return "linux"
    return "unknown"


def record(message: str) -> None:
    """Append a message to the journal log."""
    JOURNAL_DIR.mkdir(parents=True, exist_ok=True)
    log_path = JOURNAL_DIR / "journal.log"
    with open(log_path, "a", encoding="utf-8") as fh:
        fh.write(message + "\n")


def show_platform_tip() -> str:
    """Detect the platform, print a tip, and record the message."""
    name = detect_platform()
    tip = PLATFORM_TIPS.get(name, "No specific tips for this platform.")
    print(tip)
    record(f"{name}: {tip}")
    return name


if __name__ == "__main__":  # pragma: no cover - manual entry point
    show_platform_tip()
