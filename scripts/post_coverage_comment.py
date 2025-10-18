#!/usr/bin/env python3
"""Generate a Markdown coverage summary table.

Reads Vitest/Jest `coverage-summary.json` files and the pytest `.coverage` data
file. Outputs a Markdown table with coverage percentages for each test suite.
"""

from __future__ import annotations

import io
import json
import os
import sys

from coverage import Coverage


def read_js_coverage(path: str)  float | None:
    """Return line coverage percentage from a coverage-summary.json file."""
    if not os.path.exists(path):
        return None
    try:
        with open(path, "r", encoding="utf-8") as f:
            data = json.load(f)
        return float(data["total"]["lines"]["pct"])
    except (FileNotFoundError, json.JSONDecodeError, KeyError):
        return None


def read_py_coverage(path: str = ".coverage")  float | None:
    """Return total coverage percentage from a coverage data file."""
    # If a specific path is provided, use it directly
    if path != ".coverage" and os.path.exists(path):
        coverage_file = path
    else:
        # Check for coverage file in configured location first (logs/.coverage)
        coverage_paths = ["logs/.coverage", path]
        coverage_file = None
        for check_path in coverage_paths:
            if os.path.exists(check_path):
                coverage_file = check_path
                break

    if coverage_file is None:
        return None

    cov = Coverage(data_file=coverage_file)
    cov.load()
    buf = io.StringIO()
    percent = cov.report(file=buf)
    return float(percent)


def generate_table(results: dict[str, float])  str:
    header = "| Suite | Coverage |\n| --- | ---: |\n"
    rows = [f"| {name} | {pct:.1f}% |" for name, pct in results.items()]
    return header  "\n".join(rows)  "\n"


def main()  None:
    output_path = sys.argv[1] if len(sys.argv) > 1 else None

    results: dict[str, float] = {}

    # Service-specific Python coverage files
    py_services = {
        "XP": "logs/.coverage_xp",
        "Discord": "logs/.coverage_discord",
        "Auth": "logs/.coverage_auth",
        "Framework": "logs/.coverage",  # Overall coverage includes Framework
    }

    for name, path in py_services.items():
        pct = read_py_coverage(path)
        if pct is not None:
            results[name] = pct

    # Fallback to overall backend coverage if no services found
    if not any(key in results for key in ["XP", "Discord", "Auth", "Framework"]):
        py_cov = read_py_coverage()
        if py_cov is not None:
            results["Backend"] = py_cov

    # JavaScript coverage files
    js_paths = {
        "Frontend": "frontend/coverage/coverage-summary.json",
        "Bot": "bot/coverage/coverage-summary.json",
    }
    for name, path in js_paths.items():
        pct = read_js_coverage(path)
        if pct is not None:
            results[name] = pct

    if not results:
        print("No coverage data found", file=sys.stderr)
        sys.exit(1)

    table = generate_table(results)

    if output_path:
        with open(output_path, "w", encoding="utf-8") as f:
            f.write(table)
    else:
        print(table)


if __name__ == "__main__":
    main()
