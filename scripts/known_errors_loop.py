#!/usr/bin/env python
"""Process error logs against the known error database."""
from __future__ import annotations

import json
import shutil
import subprocess
import sys
from datetime import datetime
from pathlib import Path

import yaml

KNOWN_ERRORS = Path(".codex/known_errors.yaml")
ERROR_LOG = Path("error_log.txt")


def load_errors() -> list[dict]:
    if KNOWN_ERRORS.exists():
        return yaml.safe_load(KNOWN_ERRORS.read_text()) or []
    return []


def save_errors(data: list[dict]) -> None:
    with KNOWN_ERRORS.open("w", encoding="utf-8") as handle:
        yaml.safe_dump(data, handle, sort_keys=False)


def escalate(line: str) -> None:
    """Create an issue for an unknown error via the notify workflow."""
    gh = shutil.which("gh") or "gh"
    payload = json.dumps({"title": "Unknown error detected", "body": line})
    subprocess.run(
        [gh, "workflow", "run", "notify.yml", "-f", f"data={payload}"],
        check=False,
    )


def process_log(path: Path) -> None:
    lines = path.read_text().splitlines() if path.exists() else []
    if not lines:
        return

    entries = load_errors()
    updated = False
    now = datetime.utcnow().isoformat()

    for line in lines:
        matched = False
        for entry in entries:
            if entry.get("error_code") in line or entry.get("error_message") in line:
                entry["hits"] = int(entry.get("hits", 0)) + 1
                cmd = entry.get("solution", "")
                if cmd:
                    subprocess.run(cmd, shell=True, check=False)
                matched = True
                updated = True
                break
        if not matched:
            escalate(line)
        with ERROR_LOG.open("a", encoding="utf-8") as log:
            log.write(f"{now} {line}\n")

    if updated:
        save_errors(entries)


def main() -> None:
    log_path = Path(sys.argv[1]) if len(sys.argv) > 1 else ERROR_LOG
    process_log(log_path)


if __name__ == "__main__":
    main()
