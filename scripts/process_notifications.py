#!/usr/bin/env python
"""Aggregate human notifications into a single issue."""
from __future__ import annotations

import json
import shutil
import subprocess
import sys
from typing import Any


def find_issue(gh: str) -> str:
    """Return the issue number for the aggregator issue, creating it if needed."""
    list_cmd = [
        gh,
        "issue",
        "list",
        "--label",
        "ops",
        "--state",
        "open",
        "--json",
        "number,title",
    ]
    result = subprocess.run(list_cmd, capture_output=True, text=True, check=True)
    for item in json.loads(result.stdout):
        if item.get("title") == "Operations Notifications":
            return str(item["number"])

    create_cmd = [
        gh,
        "issue",
        "create",
        "--title",
        "Operations Notifications",
        "--body",
        "Aggregated notifications",
        "--label",
        "ops",
    ]
    out = subprocess.run(create_cmd, capture_output=True, text=True, check=True)
    url = out.stdout.strip().splitlines()[-1]
    return url.rsplit("/", 1)[-1]


def main(path: str) -> None:
    with open(path, "r", encoding="utf-8") as handle:
        data: dict[str, Any] = json.load(handle)

    gh = shutil.which("gh") or "gh"
    issue = find_issue(gh)
    body = f"### {data.get('title', 'No title')}\n\n{data.get('body', '')}"
    subprocess.run([gh, "issue", "comment", issue, "--body", body], check=True)


if __name__ == "__main__":
    main(sys.argv[1] if len(sys.argv) > 1 else "notify.json")
