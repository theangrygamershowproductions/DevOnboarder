#!/usr/bin/env python3
"""Update the coverage badge using the generated Markdown summary."""
from __future__ import annotations

import re
import sys
import os
from pathlib import Path

import requests


def read_coverage(path: Path) -> float:
    """Return the average coverage percentage from the summary file."""
    text = path.read_text(encoding="utf-8")
    numbers = [float(m.group(1)) for m in re.finditer(r"([0-9]+(?:\.[0-9]+)?)%", text)]
    if not numbers:
        raise ValueError("No coverage values found")
    return sum(numbers) / len(numbers)


def badge_color(pct: float) -> str:
    if pct >= 95:
        return "brightgreen"
    if pct >= 90:
        return "yellow"
    if pct >= 80:
        return "orange"
    return "red"


def fetch_badge(pct: float) -> bytes:
    """Return an SVG badge for the given coverage percentage."""
    if os.getenv("OFFLINE_BADGE") == "1":
        template = Path("scripts/offline_badge_template.svg")
        if template.exists():
            color_map = {
                "brightgreen": "#4c1",
                "yellow": "#dfb317",
                "orange": "#fe7d37",
                "red": "#e05d44",
            }
            color = color_map[badge_color(pct)]
            return (
                template.read_text(encoding="utf-8")
                .format(pct=f"{pct:.1f}%", color=color)
                .encode()
            )
        print("OFFLINE_BADGE=1 set; skipping badge generation")
        return b""

    color = badge_color(pct)
    url = f"https://img.shields.io/badge/coverage-{pct:.1f}%25-{color}.svg"
    try:
        resp = requests.get(url, timeout=10)
        resp.raise_for_status()
    except requests.RequestException as exc:
        print(f"Failed to download badge: {exc}")
        raise SystemExit(1)
    return resp.content


def main() -> None:
    summary = Path(sys.argv[1] if len(sys.argv) > 1 else "coverage-summary.md")
    output = Path(sys.argv[2] if len(sys.argv) > 2 else "coverage.svg")
    pct = read_coverage(summary)
    svg = fetch_badge(pct)
    if svg:
        output.write_bytes(svg)
        print(f"Badge updated to {pct:.1f}%")


if __name__ == "__main__":
    main()
