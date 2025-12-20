#!/usr/bin/env python3
"""
CI Action Policy Enforcement

Scans workflow + composite-action YAML for `uses:` entries and enforces:
- Allowlist / trusted owners
- SHA pinning (40 hex) by default
- Denylist regex patterns (e.g., @main, docker://)
- Optional blocking of dynamic expressions in refs

Usage:
    python tools/ci_action_policy.py --policy tools/ci_action_policy.yaml \
        --mode report
    python tools/ci_action_policy.py --policy tools/ci_action_policy.yaml \
        --mode enforce
"""
from __future__ import annotations

import argparse
import re
import sys
from dataclasses import dataclass
from pathlib import Path
from typing import Any

SHA40_RE = re.compile(r"^[0-9a-fA-F]{40}$")
USES_LINE_RE = re.compile(r"^\s*uses:\s*(?P<val>.+?)\s*$")


@dataclass(frozen=True)
class UsesHit:
    file: Path
    line_no: int
    raw: str
    uses: str


@dataclass(frozen=True)
class Violation:
    file: Path
    line_no: int
    uses: str
    reasons: list[str]


def _strip_inline_comment(s: str) -> str:
    """Strip inline YAML comments conservatively, respecting simple quotes."""
    out = []
    in_single = False
    in_double = False
    for ch in s:
        if ch == "'" and not in_double:
            in_single = not in_single
        elif ch == '"' and not in_single:
            in_double = not in_double
        if ch == "#" and not in_single and not in_double:
            break
        out.append(ch)
    return "".join(out).strip()


def _unquote(s: str) -> str:
    s = s.strip()
    if (len(s) >= 2) and ((s[0] == s[-1] == "'") or (s[0] == s[-1] == '"')):
        return s[1:-1].strip()
    return s


def _load_yaml(path: Path) -> dict[str, Any]:
    try:
        import yaml  # type: ignore
    except Exception as exc:  # pragma: no cover
        raise RuntimeError(
            "PyYAML is required to run ci_action_policy.py.\n"
            "Install with: python -m pip install pyyaml"
        ) from exc

    data = yaml.safe_load(path.read_text(encoding="utf-8"))
    if not isinstance(data, dict):
        raise ValueError(f"Policy file must be a YAML mapping/object: {path}")
    return data


def _discover_yaml_files(scan_roots: list[Path]) -> list[Path]:
    out: list[Path] = []
    for root in scan_roots:
        if not root.exists():
            continue
        if root.is_file() and root.suffix in {".yml", ".yaml"}:
            out.append(root)
            continue
        # Directory: collect top-level YAML (workflows)
        # and nested YAML (composite actions)
        for ext in ("*.yml", "*.yaml"):
            out.extend(sorted(root.rglob(ext)))
    # De-dupe while preserving order
    seen: set[Path] = set()
    deduped: list[Path] = []
    for p in out:
        if p not in seen:
            deduped.append(p)
            seen.add(p)
    return deduped


def _extract_uses_hits(workflow_file: Path) -> list[UsesHit]:
    hits: list[UsesHit] = []
    lines = workflow_file.read_text(encoding="utf-8", errors="replace").splitlines()
    for i, line in enumerate(lines, start=1):
        if line.lstrip().startswith("#"):
            continue
        match = USES_LINE_RE.match(line)
        if not match:
            continue
        val = _unquote(_strip_inline_comment(match.group("val")))
        if not val:
            continue
        hits.append(UsesHit(file=workflow_file, line_no=i, raw=line, uses=val))
    return hits


def _parse_remote_action(uses: str) -> tuple[str, str, str]:
    """Return (owner_repo, path_part, ref) for a remote action."""
    if "@" not in uses:
        raise ValueError("Remote action missing '@ref' segment")

    action_part, ref = uses.split("@", 1)
    ref = ref.strip()

    parts = action_part.strip().split("/")
    if len(parts) < 2:
        raise ValueError("Remote action must look like owner/repo[@ref]")

    owner_repo = f"{parts[0]}/{parts[1]}"
    path_part = "/".join(parts[2:]) if len(parts) > 2 else ""
    return owner_repo, path_part, ref


def _policy_lookup_allow(
    allow_list: list[dict[str, Any]],
    owner_repo: str,
) -> dict[str, Any] | None:
    for entry in allow_list:
        if not isinstance(entry, dict):
            continue
        if entry.get("action") == owner_repo:
            return entry
    return None


def _format_violations(violations: list[Violation]) -> str:
    by_file: dict[Path, list[Violation]] = {}
    for violation in violations:
        by_file.setdefault(violation.file, []).append(violation)

    lines: list[str] = []
    for file_path in sorted(by_file.keys()):
        lines.append(f"\n== {file_path} ==")
        for violation in by_file[file_path]:
            reasons = "; ".join(violation.reasons)
            lines.append(f"  L{violation.line_no}: {violation.uses}")
            lines.append(f"    -> {reasons}")
    return "\n".join(lines).lstrip()


def main(argv: list[str]) -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--policy", default="tools/ci_action_policy.yaml")
    parser.add_argument(
        "--scan-root",
        action="append",
        default=None,
        help="Directory (or file) to scan for YAML. Repeatable.",
    )
    parser.add_argument("--mode", choices=["enforce", "report"], default="enforce")
    args = parser.parse_args(argv)

    policy_path = Path(args.policy)
    scan_roots = [
        Path(p)
        for p in (
            args.scan_root
            or [
                ".github/workflows",
                ".github/actions",
            ]
        )
    ]

    policy = _load_yaml(policy_path)

    defaults = policy.get("defaults") or {}
    if not isinstance(defaults, dict):
        raise ValueError("policy.defaults must be a mapping")

    sha_only_default = bool(defaults.get("sha_only", True))
    allow_local = bool(defaults.get("allow_local_actions", True))
    allow_docker = bool(defaults.get("allow_docker_actions", False))
    allow_expressions = bool(defaults.get("allow_expressions", False))

    trusted_owners = policy.get("trusted_owners") or []
    if not isinstance(trusted_owners, list):
        raise ValueError("policy.trusted_owners must be a list")

    allow = policy.get("allow") or []
    if not isinstance(allow, list):
        raise ValueError("policy.allow must be a list")

    deny_actions_raw = policy.get("deny_actions") or []
    if not isinstance(deny_actions_raw, list):
        raise ValueError("policy.deny_actions must be a list")
    deny_actions = set(deny_actions_raw)

    deny_regex_list = policy.get("deny_uses_regex") or []
    if not isinstance(deny_regex_list, list):
        raise ValueError("policy.deny_uses_regex must be a list")
    deny_regex = [re.compile(pattern) for pattern in deny_regex_list]

    workflow_files = _discover_yaml_files(scan_roots)
    hits: list[UsesHit] = []
    for workflow_file in workflow_files:
        hits.extend(_extract_uses_hits(workflow_file))

    violations: list[Violation] = []

    for hit in hits:
        uses_value = hit.uses

        matched_denies = [pat.pattern for pat in deny_regex if pat.search(uses_value)]
        if matched_denies:
            msg = ", ".join(matched_denies)
            violations.append(
                Violation(
                    hit.file,
                    hit.line_no,
                    uses_value,
                    [f"Denied by pattern(s): {msg}"],
                )
            )
            continue

        if uses_value.startswith("./") or uses_value.startswith("../"):
            if not allow_local:
                violations.append(
                    Violation(
                        hit.file,
                        hit.line_no,
                        uses_value,
                        ["Local actions are disabled by policy"],
                    )
                )
            continue

        if uses_value.startswith("docker://"):
            if not allow_docker:
                violations.append(
                    Violation(
                        hit.file,
                        hit.line_no,
                        uses_value,
                        ["docker:// actions are disabled by policy"],
                    )
                )
            continue

        reasons: list[str] = []
        try:
            owner_repo, _path_part, ref = _parse_remote_action(uses_value)
        except ValueError as exc:
            violations.append(Violation(hit.file, hit.line_no, uses_value, [str(exc)]))
            continue

        if owner_repo in deny_actions:
            violations.append(
                Violation(
                    hit.file,
                    hit.line_no,
                    uses_value,
                    ["Action is explicitly denylisted"],
                )
            )
            continue

        allow_entry = _policy_lookup_allow(allow, owner_repo)
        owner = owner_repo.split("/", 1)[0]

        allowed = (owner in trusted_owners) or (allow_entry is not None)
        if not allowed:
            reasons.append("Action not allowlisted and owner is not trusted")

        if (not allow_expressions) and ("${{" in ref or "}}" in ref):
            reasons.append("Dynamic expressions in @ref are not allowed")

        sha_only = sha_only_default
        if allow_entry is not None and "sha_only" in allow_entry:
            sha_only = bool(allow_entry["sha_only"])

        if sha_only and not SHA40_RE.match(ref):
            reasons.append("Not pinned to a 40-character commit SHA")

        if reasons:
            violations.append(Violation(hit.file, hit.line_no, uses_value, reasons))

    if not violations:
        print("OK: action policy check passed (no violations).")
        return 0

    print(_format_violations(violations))

    if args.mode == "report":
        print(
            "\nREPORT: "
            f"{len(violations)} violation(s) found "
            "(not failing due to --mode report)."
        )
        return 0

    print(f"\nFAIL: {len(violations)} violation(s) found.")
    return 1


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))
