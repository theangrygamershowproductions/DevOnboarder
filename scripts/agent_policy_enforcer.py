#!/usr/bin/env python3
"""
Agent Policy Enforcer
Prevents emoji usage in terminal-facing scripts and workflows.
Enforces DevOnboarder's zero-tolerance terminal output policy.
"""

import sys
import re
import pathlib
import fnmatch

ROOT = pathlib.Path(__file__).resolve().parents[1]
EMOJI = re.compile(
    r"[\U0001F300-\U0001FAFF\u2600-\u27BF\u24C2-\U0001F251]|\uFE0F|"
    r"🤖|🟢|🟡|🥔|🧠|🟠|🤔|🥇|🧙|🪝|🧑"
)

SCOPES = [
    "scripts/**/*.sh",
    "**/*.sh",
    ".github/workflows/**/*.yml",
]


def match(path, patterns):
    """Check if path matches any pattern."""
    s = str(path).replace("\\", "/")
    return any(fnmatch.fnmatch(s, p) for p in patterns)


def main():
    """Main enforcement function."""
    violations = []
    for p in ROOT.rglob("*"):
        if p.is_dir():
            continue
        rel = p.relative_to(ROOT)
        if not match(rel, SCOPES):
            continue
        try:
            text = p.read_text(encoding="utf-8", errors="ignore")
        except (OSError, UnicodeDecodeError):
            continue
        for i, line in enumerate(text.splitlines(), 1):
            if EMOJI.search(line):
                violations.append(f"{rel}:{i}")

    if violations:
        print("Agent Policy Violations (emoji in terminal-facing assets):")
        for v in violations[:200]:
            print("  " + v)
        print(f"Total: {len(violations)}")
        sys.exit(1)

    print("Agent policy clean.")
    sys.exit(0)


if __name__ == "__main__":
    main()
