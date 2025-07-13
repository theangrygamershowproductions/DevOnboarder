"""Basic diagnostics for the DevOnboarder stack."""

from __future__ import annotations

import importlib
import json
import os
import subprocess
from pathlib import Path

import requests


REQUIRED_PACKAGES = ["fastapi", "pytest"]
SERVICE_VARS = {
    "auth": ("AUTH_URL", "http://localhost:8002"),
    "xp": ("API_BASE_URL", "http://localhost:8001"),
    "feedback": ("VITE_FEEDBACK_URL", "http://localhost:8090"),
}


def check_packages() -> list[str]:
    """Import required packages and return any failures."""
    failures: list[str] = []
    for pkg in REQUIRED_PACKAGES:
        try:
            importlib.import_module(pkg)
            print(f"{pkg} imported")
        except Exception as exc:  # pragma: no cover - fails printed
            msg = f"Failed to import {pkg}: {exc}"
            print(msg)
            failures.append(msg)
    return failures


def check_health() -> dict[str, str]:
    """Call each service's `/health` endpoint and return statuses."""
    statuses: dict[str, str] = {}
    for name, (env_var, default) in SERVICE_VARS.items():
        base = os.getenv(env_var, default).rstrip("/")
        url = f"{base}/health"
        try:
            resp = requests.get(url, timeout=5)
            statuses[name] = f"{resp.status_code} {resp.reason}"
        except requests.RequestException as exc:  # pragma: no cover - network fail
            statuses[name] = f"error: {exc}"
        print(f"{name}: {statuses[name]}")
    return statuses


def audit_env() -> dict[str, list[str]]:
    """Run `scripts/audit_env_vars.sh` and return its summary."""
    tmp = Path("env_audit.json")
    env = os.environ.copy()
    env["JSON_OUTPUT"] = str(tmp)
    result = subprocess.run(
        ["bash", "scripts/audit_env_vars.sh"],
        env=env,
        capture_output=True,
        text=True,
        check=False,
    )
    print(result.stdout)
    if tmp.exists():
        data = json.loads(tmp.read_text())
        tmp.unlink()
    else:  # pragma: no cover - script failure
        data = {"missing": [], "extra": []}
    print(f"Missing: {data.get('missing', [])}")
    print(f"Extra: {data.get('extra', [])}")
    return data


def main() -> None:
    """Run all diagnostic checks."""
    check_packages()
    check_health()
    audit_env()


if __name__ == "__main__":
    main()
