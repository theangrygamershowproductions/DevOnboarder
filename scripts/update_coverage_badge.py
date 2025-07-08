#!/usr/bin/env python3
"""Update the coverage badge using the generated Markdown summary."""
from __future__ import annotations

import re
import sys
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
    color = badge_color(pct)
    url = f"https://img.shields.io/badge/coverage-{pct:.1f}%25-{color}.svg"
    resp = requests.get(url, timeout=10)
    resp.raise_for_status()
    return resp.content


def main() -> None:
    summary = Path(sys.argv[1] if len(sys.argv) > 1 else "coverage-summary.md")
    output = Path(sys.argv[2] if len(sys.argv) > 2 else "coverage.svg")
    pct = read_coverage(summary)
    svg = fetch_badge(pct)
    output.write_bytes(svg)
    print(f"Badge updated to {pct:.1f}%")


if __name__ == "__main__":
    main()
