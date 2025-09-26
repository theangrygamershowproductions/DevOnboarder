#!/usr/bin/env python3
"""Verify local tool versions against a versions.yaml spec.

This script uses only the Python standard library and supports a tiny
subset of YAML (top-level key: value pairs). Exit codes:

  0 - all versions match
  1 - version mismatches found
  2 - spec file missing or unreadable

The implementation deliberately keeps lines under 88 cols to satisfy
the project's linters.
"""
from __future__ import annotations

import subprocess
import sys
from pathlib import Path
from typing import Dict, Tuple


def run(cmd: list[str]) -> str:
    """Run a command and return its stdout (or stderr on failure).

    Returns an empty string if the command did not run or produced no
    output.
    """
    try:
        out = subprocess.check_output(cmd, stderr=subprocess.STDOUT)
        return out.decode().strip()
    except subprocess.CalledProcessError as exc:
        return exc.output.decode().strip()
    except FileNotFoundError:
        return ""


def parse_versions(path: Path) -> Dict[str, str]:
    """Parse a simple key: value file into a dict.

    Only supports top-level scalar values. Comments and document
    markers are ignored.
    """
    data: Dict[str, str] = {}
    with path.open("r", encoding="utf-8") as fh:
        for raw in fh:
            line = raw.strip()
            if not line or line.startswith("#") or line in ("---", "..."):
                continue
            if ":" not in line:
                continue
            key, val = line.split(":", 1)
            key = key.strip()
            val = val.strip()
            if (val.startswith('"') and val.endswith('"')) or (
                val.startswith("'") and val.endswith("'")
            ):
                val = val[1:-1]
            data[key] = val
    return data


def normalize_observed(key: str, observed: str) -> str:
    """Normalize common tool version output strings.

    Keep normalization conservative: prefer prefix match afterwards.
    """
    if not observed:
        return ""
    if key == "python":
        # e.g. "Python 3.12.11"
        parts = observed.split()
        return parts[-1] if parts else ""
    if key in ("node", "npm"):
        return observed.lstrip("vV ")
    if key == "docker":
        parts = observed.split()
        if len(parts) >= 3:
            return parts[2].strip(",")
        return observed
    if key == "compose":
        parts = observed.split()
        return parts[-1].lstrip("vV") if parts else observed
    return observed


def run_checks(spec: Dict[str, str]) -> Tuple[bool, list[str]]:
    checks = [
        ("python", [sys.executable, "--version"]),
        ("node", ["node", "--version"]),
        ("npm", ["npm", "--version"]),
        ("docker", ["docker", "-v"]),
        ("compose", ["docker", "compose", "version"]),
    ]

    failures: list[str] = []
    for key, cmd in checks:
        expected = str(spec.get(key, ""))
        observed_raw = run(cmd)
        observed = normalize_observed(key, observed_raw)

        if not observed:
            failures.append(
                f"{key}: not installed or not on PATH (observed: '{observed_raw}')"
            )
            continue

        # Exact match or observed startswith expected (prefix allowlist)
        if expected and expected != observed and not observed.startswith(expected):
            failures.append(f"{key}: expected {expected}, observed {observed}")

    return (len(failures) == 0, failures)


def main() -> int:
    spec_path = Path("versions.yaml")
    if not spec_path.exists():
        print("ERROR: versions.yaml not found at repo root", file=sys.stderr)
        return 2

    try:
        spec = parse_versions(spec_path)
    except Exception as exc:  # pragma: no cover - defensive
        print(f"ERROR: unable to parse versions.yaml: {exc}", file=sys.stderr)
        return 2

    ok, failures = run_checks(spec)
    if not ok:
        print("VERSION MISMATCHES:")
        for f in failures:
            print(" -", f)
        return 1

    print("All versions match versions.yaml")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
