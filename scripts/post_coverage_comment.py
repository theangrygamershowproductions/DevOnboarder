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


def read_js_coverage(path: str) -> float | None:
    """Return line coverage percentage from a coverage-summary.json file."""
    if not os.path.exists(path):
        return None
    try:
        with open(path, "r", encoding="utf-8") as f:
            data = json.load(f)
        return float(data["total"]["lines"]["pct"])
    except Exception:
        return None


def read_py_coverage(path: str = ".coverage") -> float | None:
    """Return total coverage percentage from a coverage data file."""
    if not os.path.exists(path):
        return None
    cov = Coverage(data_file=path)
    cov.load()
    buf = io.StringIO()
    percent = cov.report(file=buf)
    return float(percent)


def generate_table(results: dict[str, float]) -> str:
    header = "| Suite | Coverage |\n| --- | ---: |\n"
    rows = [f"| {name} | {pct:.1f}% |" for name, pct in results.items()]
    return header + "\n".join(rows) + "\n"


def main() -> None:
    output_path = sys.argv[1] if len(sys.argv) > 1 else None

    results: dict[str, float] = {}

    py_cov = read_py_coverage()
    if py_cov is not None:
        results["Backend"] = py_cov

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
