#!/usr/bin/env python3
"""Verify local tool versions against a versions.yaml spec.

Stdlib only. Exits 0 on match, 1 on mismatch.
"""
import subprocess
import sys
from pathlib import Path
import yaml


def run(cmd: list[str]) -> str:
    try:
        out = subprocess.check_output(cmd, stderr=subprocess.STDOUT)
        return out.decode().strip()
    except subprocess.CalledProcessError as e:
        return e.output.decode().strip()


def parse_versions(path: Path) -> dict:
    with path.open("r", encoding="utf-8") as f:
        return yaml.safe_load(f)


def main() -> int:
    spec_path = Path("versions.yaml")
    if not spec_path.exists():
        print("ERROR: versions.yaml not found at repo root", file=sys.stderr)
        return 2

    spec = parse_versions(spec_path)
    checks = [
        ("python", [sys.executable, "--version"]),
        ("node", ["node", "--version"]),
        ("npm", ["npm", "--version"]),
        ("docker", ["docker", "-v"]),
        ("compose", ["docker", "compose", "version"]),
    ]

    failures = []

    for key, cmd in checks:
        expected = str(spec.get(key))
        observed = run(cmd)
        # Normalize common outputs
        if key == "python":
            # e.g. 'Python 3.12.6'
            observed_norm = observed.split()[-1] if observed else ""
        elif key in ("node", "npm"):
            observed_norm = observed.lstrip("vV ")
        elif key == "docker":
            # docker -v -> Docker version 27.2.0, build ...
            parts = observed.split()
            observed_norm = parts[2].strip(",") if len(parts) >= 3 else observed
        elif key == "compose":
            # docker compose version v2.28.1
            parts = observed.split()
            observed_norm = parts[-1].lstrip("vV") if parts else observed
        else:
            observed_norm = observed

        if not observed_norm:
            failures.append(
                f"{key}: not installed or not on PATH (observed: '{observed}')"
            )
            continue

        if expected != observed_norm and not observed_norm.startswith(expected):
            failures.append(f"{key}: expected {expected}, observed {observed_norm}")

    # DBs and redis are declaration-only (can't reliably run locally in CI job)

    if failures:
        print("VERSION MISMATCHES:")
        for f in failures:
            print(" -", f)
        return 1

    print("All versions match versions.yaml")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
