#!/usr/bin/env python3
"""Print numbers of open ci-failure issues."""
from __future__ import annotations

import json
import subprocess
import sys


def main() -> int:
    result = subprocess.run(
        [
            "gh",
            "issue",
            "list",
            "--label",
            "ci-failure",
            "--state",
            "open",
            "--json",
            "number",
        ],
        check=True,
        capture_output=True,
        text=True,
    )
    issues = json.loads(result.stdout)
    for issue in issues:
        print(issue["number"])
    return 0


if __name__ == "__main__":
    sys.exit(main())
