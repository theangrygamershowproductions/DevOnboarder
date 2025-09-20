#!/usr/bin/env python3
"""Regenerate env variable docs from `.env.example` files."""

from __future__ import annotations

import re
from pathlib import Path

DOC_PATH = Path("agents/index.md")
ENV_FILES = [
    Path(".env.example"),
    Path("frontend/src/.env.example"),
    Path("bot/.env.example"),
    Path("auth/.env.example"),
]


def read_env_vars(paths: list[Path]) -> set[str]:
    pattern = re.compile(r"^([A-Za-z_][A-Za-z0-9_]*)=")
    vars: set[str] = set()
    for p in paths:
        if not p.exists():
            continue
        with p.open("r", encoding="utf-8") as f:
            for line in f:
                m = pattern.match(line)
                if m:
                    vars.add(m.group(1))
    return vars


def read_doc_table(path: Path) -> dict[str, str]:
    pattern = re.compile(r"^\|\s*([A-Za-z0-9_]+)\s*\|\s*(.*?)\s*\|$")
    table: dict[str, str] = {}
    lines = path.read_text().splitlines()
    i = 0
    while i < len(lines):
        line = lines[i]
        if line.startswith("|") and not line.rstrip().endswith("|"):
            j = i
            parts = [line.rstrip()]
            while j + 1 < len(lines) and not lines[j + 1].rstrip().endswith("|"):
                j += 1
                parts.append(lines[j].rstrip())
            if j + 1 < len(lines):
                j += 1
                parts.append(lines[j].rstrip())
            line = " ".join(parts)
            i = j
        m = pattern.match(line)
        if m and m.group(1) != "Variable":
            table[m.group(1)] = m.group(2)
        i += 1
    return table


def build_table(vars: set[str], existing: dict[str, str]) -> list[str]:
    width = max(len("Variable"), *(len(v) for v in vars))
    header = f"| {'Variable'.ljust(width)} | Description |"
    separator = f"| {'-' * width} | ----------- |"
    lines = [header, separator]
    for var in sorted(vars):
        desc = existing.get(var, "")
        lines.append(f"| {var.ljust(width)} | {desc} |")
    return lines


def replace_table(doc_lines: list[str], table_lines: list[str]) -> list[str]:
    start = None
    for i, line in enumerate(doc_lines):
        if line.strip() == "## Required Environment Variables":
            start = i
            break
    if start is None:
        raise RuntimeError("Section header not found")

    # copy lines up to end of header and any explanatory text
    result = doc_lines[: start + 1]
    i = start + 1
    while i < len(doc_lines) and not doc_lines[i].startswith("|"):
        result.append(doc_lines[i])
        i += 1

    # find end of current table
    end = i
    while end < len(doc_lines) and doc_lines[end].startswith("|"):
        end += 1
    # skip to next section header
    while end < len(doc_lines) and not doc_lines[end].startswith("## "):
        end += 1

    result.extend(table_lines)
    result.extend(doc_lines[end:])
    return result


def main() -> None:
    env_vars = read_env_vars(ENV_FILES)
    doc_lines = DOC_PATH.read_text().splitlines()
    existing = read_doc_table(DOC_PATH)
    table_lines = build_table(env_vars, existing)
    new_content = replace_table(doc_lines, table_lines)
    DOC_PATH.write_text("\n".join(new_content) + "\n")
    print(f"Updated {DOC_PATH} with {len(env_vars)} variables")


if __name__ == "__main__":
    main()
