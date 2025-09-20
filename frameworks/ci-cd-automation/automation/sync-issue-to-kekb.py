#!/usr/bin/env python
"""Append resolved GitHub issues to the KEKB knowledge base."""
from __future__ import annotations

import json
import shutil
import subprocess
import sys
from pathlib import Path

KB_FILE = Path("docs/KEKB.md")


def append_issue(issue_number: str) -> None:
    gh = shutil.which("gh") or "gh"
    out = subprocess.run(
        [gh, "issue", "view", issue_number, "--json", "title,body,state"],
        capture_output=True,
        text=True,
        check=True,
    )
    data = json.loads(out.stdout)
    if data.get("state") != "closed":
        print(f"Issue {issue_number} is not closed; skipping")
        return

    KB_FILE.touch(exist_ok=True)
    with KB_FILE.open("a", encoding="utf-8") as handle:
        handle.write(f"## {issue_number}: {data['title']}\n\n{data['body']}\n\n")


if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: sync-issue-to-kekb.py <issue-number>", file=sys.stderr)
        sys.exit(1)
    append_issue(sys.argv[1])
