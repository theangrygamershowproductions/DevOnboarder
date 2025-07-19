#!/usr/bin/env python3
"""List codex agents defined in workflows and index entries."""
from __future__ import annotations

import json
import re
import sys
from pathlib import Path
from typing import Optional

import yaml


def to_snake(name: str) -> str:
    """Convert CamelCase to snake_case."""
    s = re.sub(r"(.)([A-Z][a-z]+)", r"\1_\2", name)
    s = re.sub(r"([a-z0-9])([A-Z])", r"\1_\2", s)
    return s.lower()


def parse_header(path: Path) -> Optional[str]:
    """Return the codex-agent name from ``path`` if present."""
    try:
        with path.open() as fh:
            lines: list[str] = []
            reading = False
            for _ in range(20):
                line = fh.readline()
                if not line:
                    break
                if re.match(r"#?\s*---", line):
                    if not reading:
                        reading = True
                        continue
                    else:
                        break
                if reading:
                    cleaned = re.sub(r"^#\s?", "", line.rstrip("\n"))
                    lines.append(cleaned)
            if not lines:
                return None
            data = yaml.safe_load("\n".join(lines)) or {}
            agent = data.get("codex-agent", {})
            if isinstance(agent, dict):
                return agent.get("name")
    except Exception:
        return None
    return None


def scan_workflows() -> dict[str, str]:
    bots: dict[str, str] = {}
    for path in Path(".github/workflows").glob("*.yml"):
        name = parse_header(path)
        if name:
            bots[name] = str(path)
    return bots


def scan_index() -> dict[str, str]:
    bots: dict[str, str] = {}
    index_path = Path(".codex/agents/index.json")
    if not index_path.exists():
        return bots
    data = json.loads(index_path.read_text())
    for agent in data.get("agents", []):
        f = Path(agent.get("path", ""))
        if not f.exists():
            continue
        name = parse_header(f)
        if name:
            bots.setdefault(name, str(f))
    return bots


def load_permissions() -> set[str]:
    file = Path(".codex/bot-permissions.yaml")
    if not file.exists():
        return set()
    data = yaml.safe_load(file.read_text()) or {}
    return set(data.keys())


def main() -> None:
    bots = scan_workflows()
    bots.update(scan_index())
    permissions = load_permissions()
    summary = []
    missing = []
    for name, path in sorted(bots.items()):
        key = to_snake(name.split(".")[-1])
        has_perm = key in permissions
        summary.append({"name": name, "file": path, "permissions": has_perm})
        if not has_perm:
            missing.append(name)
    json.dump({"bots": summary, "missing_permissions": missing}, sys.stdout, indent=2)


if __name__ == "__main__":
    main()
