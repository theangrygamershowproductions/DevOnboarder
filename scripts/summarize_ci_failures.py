#!/usr/bin/env python
"""Generate a short CI failure summary for maintainers."""

from __future__ import annotations

import os
import xml.etree.ElementTree as ET
from pathlib import Path
from typing import List


def parse_pytest(path: Path) -> List[str]:
    """Return failing pytest testcase names."""
    if not path.exists():
        return []
    tree = ET.parse(path)
    fails: List[str] = []
    for case in tree.iter("testcase"):
        if case.find("failure") is not None:
            classname = case.get("classname", "")
            name = case.get("name", "")
            if classname:
                fails.append(f"{classname}::{name}")
            else:
                fails.append(name)
    return fails


def parse_log(path: Path) -> List[str]:
    """Return lines containing 'FAIL' from a test log."""
    if not path.exists():
        return []
    lines = []
    with path.open() as f:
        for line in f:
            if "FAIL" in line:
                lines.append(line.strip())
    return lines


def main() -> None:
    repo = os.getenv("GITHUB_REPOSITORY", "")
    run_id = os.getenv("GITHUB_RUN_ID", "")
    sha = os.getenv("GITHUB_SHA", "")[:7]

    lines: List[str] = [f"# CI Failure Summary for `{sha}`", ""]

    pyfails = parse_pytest(Path("test-results") / "pytest-results.xml")
    if pyfails:
        lines.append("## Pytest Failures")
        for name in pyfails[:5]:
            lines.append(f"- {name}")
        lines.append("")

    vitest_fails = parse_log(Path("frontend") / "vitest.log")
    if vitest_fails:
        lines.append("## Vitest Failures")
        for item in vitest_fails[:5]:
            lines.append(f"- {item}")
        lines.append("")

    playwright_fails = parse_log(Path("frontend") / "playwright.log")
    if playwright_fails:
        lines.append("## Playwright Failures")
        for item in playwright_fails[:5]:
            lines.append(f"- {item}")
        lines.append("")

    jest_fails = parse_log(Path("bot") / "jest.log")
    if jest_fails:
        lines.append("## Jest Failures")
        for item in jest_fails[:5]:
            lines.append(f"- {item}")
        lines.append("")

    lines.append(
        "[Download artifacts](https://github.com/"f"{repo}/actions/runs/{run_id}) "
        "for full logs."
    )

    Path("summary.md").write_text("\n".join(lines))


if __name__ == "__main__":
    main()
