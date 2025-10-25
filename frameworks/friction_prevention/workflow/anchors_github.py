#!/usr/bin/env python3

import re
import sys
import json

# GitHub-style anchor generation with duplicate handling
slug_counts: dict[str, int] = {}
anchors: list[str] = []
heading_re = re.compile(r"^(#{1,6})\s(.*)$")


def slugify(s: str) -> str:
    """Convert heading text to GitHub-style anchor"""
    # Lower, remove emojis/punct except hyphen/space, collapse spaceshyphen
    s = s.lower()
    # Remove all non-word characters except hyphens and spaces
    s = re.sub(r"[^\w\- ]", "", s, flags=re.UNICODE)
    # Replace spaces with hyphens
    s = re.sub(r"\s", "-", s.strip())
    # Collapse multiple hyphens and strip leading/trailing hyphens
    s = re.sub(r"-", "-", s).strip("-")
    return s


# Process markdown from stdin
for line in sys.stdin:
    m = heading_re.match(line.rstrip())
    if not m:
        continue

    base = slugify(m.group(2))
    if not base:  # Skip empty slugs
        continue

    n = slug_counts.get(base, 0)
    slug_counts[base] = n + 1

    # GitHub behavior: first occurrence no suffix, subsequent get -1, -2, etc.
    final_anchor = base if n == 0 else f"{base}-{n}"
    anchors.append(final_anchor)

# Output JSON with anchors and counts
result = {"anchors": anchors, "counts": slug_counts}

print(json.dumps(result, ensure_ascii=False))
