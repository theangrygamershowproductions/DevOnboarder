#!/usr/bin/env python3
"""
Pin GitHub Actions `uses:` refs from tags (e.g., @v4) to immutable commit SHAs.

- Scans:
    - .github/workflows/**/*.y*ml
    - .github/actions/**/*.y*ml
- Rewrites only `uses:` lines (best-effort, preserves quoting + inline comments)
- Resolves refs via `gh api` (no --jq/--json), including annotated tags.

Examples:
    # Dry-run (no file changes)
    ./venv/bin/python tools/pin_action_uses.py

    # Apply changes
    ./venv/bin/python tools/pin_action_uses.py --apply

    # Only pin actions/* and github/* first (lower risk)
    ./venv/bin/python tools/pin_action_uses.py --apply \
        --include-owner actions --include-owner github
"""
from __future__ import annotations

import argparse
import json
import re
import subprocess
import sys
from dataclasses import dataclass
from pathlib import Path

SHA40_RE = re.compile(r"^[0-9a-fA-F]{40}$")
USES_RE = re.compile(r"^(\s*uses:\s*)(.+?)\s*$")


@dataclass(frozen=True)
class Replacement:
    file: Path
    line_no: int
    old: str
    new: str


def split_inline_comment(line: str) -> tuple[str, str]:
    """Split YAML inline comment starting at first # outside quotes."""
    in_single = False
    in_double = False
    for i, ch in enumerate(line):
        if ch == "'" and not in_double:
            in_single = not in_single
        elif ch == '"' and not in_single:
            in_double = not in_double
        elif ch == "#" and not in_single and not in_double:
            return line[:i].rstrip(), line[i:]  # keep comment including '#'
    return line.rstrip(), ""


def unquote(s: str) -> tuple[str, str]:
    s = s.strip()
    if len(s) >= 2 and s[0] in ("'", '"') and s[-1] == s[0]:
        return s[1:-1].strip(), s[0]
    return s, ""


def is_local_or_docker(uses: str) -> bool:
    return (
        uses.startswith("./") or uses.startswith("../") or uses.startswith("docker://")
    )


def parse_remote_uses(uses: str) -> tuple[str, str, str]:
    """
    Returns (owner_repo, path_part, ref)
    Examples:
      actions/checkout@v4
      owner/repo/path/to/action@v3
    """
    if "@" not in uses:
        raise ValueError("Remote uses missing @ref")
    action_part, ref = uses.split("@", 1)
    ref = ref.strip()
    parts = action_part.strip().split("/")
    if len(parts) < 2:
        raise ValueError("Remote uses must be owner/repo[@ref]")
    owner_repo = f"{parts[0]}/{parts[1]}"
    path_part = "/".join(parts[2:]) if len(parts) > 2 else ""
    return owner_repo, path_part, ref


def gh_api_json(endpoint: str) -> dict:
    proc = subprocess.run(
        ["gh", "api", endpoint],
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        text=True,
    )
    if proc.returncode != 0:
        raise RuntimeError(proc.stderr.strip() or f"gh api failed for {endpoint}")
    try:
        return json.loads(proc.stdout)
    except json.JSONDecodeError as exc:
        raise RuntimeError(f"Failed to parse JSON from gh api {endpoint}") from exc


class Resolver:
    def __init__(self) -> None:
        self._cache: dict[tuple[str, str, str], str] = {}

    def resolve_to_commit_sha(self, owner: str, repo: str, ref: str) -> str:
        """
        Resolve a ref (tag or branch) to a commit SHA.
        - Tries tags first: git/ref/tags/<ref>
        - Falls back to heads: git/ref/heads/<ref>
        - Dereferences annotated tags via git/tags/<sha>
        """
        key = (owner, repo, ref)
        if key in self._cache:
            return self._cache[key]

        if SHA40_RE.match(ref):
            self._cache[key] = ref.lower()
            return self._cache[key]

        # Bail on dynamic refs. Those must be manually handled (or refactored).
        if "${{" in ref or "}}" in ref:
            raise RuntimeError("Ref contains expression; cannot auto-pin")

        # Some people write refs like refs/tags/v4 or refs/heads/main.
        # Normalize lightly.
        normalized = ref
        normalized = normalized.removeprefix("refs/tags/").removeprefix("refs/heads/")

        # 1) Try tag ref
        try:
            data = gh_api_json(f"repos/{owner}/{repo}/git/ref/tags/{normalized}")
            obj = data.get("object") or {}
            sha = obj.get("sha")
            otype = obj.get("type")
            if not sha or not otype:
                raise RuntimeError("Unexpected tag ref payload")
            if otype == "commit":
                commit_sha = sha
            elif otype == "tag":
                tag_obj = gh_api_json(f"repos/{owner}/{repo}/git/tags/{sha}")
                inner = tag_obj.get("object") or {}
                commit_sha = inner.get("sha")
                if not commit_sha:
                    raise RuntimeError("Annotated tag did not contain inner object sha")
            else:
                raise RuntimeError(f"Unsupported tag object type: {otype}")
            self._cache[key] = commit_sha.lower()
            return self._cache[key]
        except Exception:
            pass  # fall through

        # 2) Try branch head ref
        data = gh_api_json(f"repos/{owner}/{repo}/git/ref/heads/{normalized}")
        obj = data.get("object") or {}
        sha = obj.get("sha")
        otype = obj.get("type")
        if not sha or otype != "commit":
            raise RuntimeError("Unexpected heads ref payload")
        self._cache[key] = sha.lower()
        return self._cache[key]


def iter_yaml_files(roots: list[Path]) -> list[Path]:
    out: list[Path] = []
    for root in roots:
        if not root.exists():
            continue
        if root.is_file() and root.suffix in {".yml", ".yaml"}:
            out.append(root)
        elif root.is_dir():
            for ext in ("*.yml", "*.yaml"):
                out.extend(sorted(root.rglob(ext)))
    # de-dupe
    seen: set[Path] = set()
    uniq: list[Path] = []
    for p in out:
        if p not in seen:
            uniq.append(p)
            seen.add(p)
    return uniq


def should_include(
    owner: str,
    owner_repo: str,
    include_owners: list[str],
    exclude_owners: list[str],
    include_actions: list[str],
    exclude_actions: list[str],
) -> bool:
    if owner in exclude_owners:
        return False
    if owner_repo in exclude_actions:
        return False
    if include_actions and owner_repo not in include_actions:
        return False
    if include_owners and owner not in include_owners:
        return False
    return True


def main(argv: list[str]) -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--apply",
        action="store_true",
        help="Write changes to files (default: dry-run)",
    )
    parser.add_argument(
        "--root",
        action="append",
        default=None,
        help="Scan root (repeatable). Default: .github/workflows + .github/actions",
    )
    parser.add_argument(
        "--include-owner",
        action="append",
        default=[],
        help="Only pin actions from these owners (repeatable)",
    )
    parser.add_argument(
        "--exclude-owner",
        action="append",
        default=[],
        help="Skip actions from these owners (repeatable)",
    )
    parser.add_argument(
        "--include-action",
        action="append",
        default=[],
        help="Only pin these owner/repo actions (repeatable)",
    )
    parser.add_argument(
        "--exclude-action",
        action="append",
        default=[],
        help="Skip these owner/repo actions (repeatable)",
    )
    args = parser.parse_args(argv)

    roots = [Path(p) for p in (args.root or [".github/workflows", ".github/actions"])]
    files = iter_yaml_files(roots)

    resolver = Resolver()
    replacements: list[Replacement] = []
    skipped_dynamic: list[tuple[Path, int, str]] = []
    unresolved: list[tuple[Path, int, str, str]] = []

    for f in files:
        lines = f.read_text(encoding="utf-8", errors="replace").splitlines()
        new_lines: list[str] = []
        changed = False

        for idx, line in enumerate(lines, start=1):
            # skip full-line comments quickly
            if line.lstrip().startswith("#"):
                new_lines.append(line)
                continue

            pre, comment = split_inline_comment(line)
            match = USES_RE.match(pre)
            if not match:
                new_lines.append(line)
                continue

            prefix = match.group(1)
            value_raw = match.group(2).strip()
            uses_val, quote = unquote(value_raw)

            # Don't touch local/docker uses
            if is_local_or_docker(uses_val):
                new_lines.append(line)
                continue

            try:
                owner_repo, path_part, ref = parse_remote_uses(uses_val)
                owner, repo = owner_repo.split("/", 1)

                if not should_include(
                    owner=owner,
                    owner_repo=owner_repo,
                    include_owners=args.include_owner,
                    exclude_owners=args.exclude_owner,
                    include_actions=args.include_action,
                    exclude_actions=args.exclude_action,
                ):
                    new_lines.append(line)
                    continue

                if SHA40_RE.match(ref):
                    new_lines.append(line)
                    continue

                commit_sha = resolver.resolve_to_commit_sha(owner, repo, ref)

                pinned_action = owner_repo
                if path_part:
                    pinned_action = f"{owner_repo}/{path_part}"
                new_uses = f"{pinned_action}@{commit_sha}"

                # Rebuild line, preserve quote + comment
                new_value = f"{quote}{new_uses}{quote}" if quote else new_uses
                rebuilt = f"{prefix}{new_value}"
                if comment:
                    rebuilt = f"{rebuilt} {comment}".rstrip()

                if rebuilt != line.rstrip():
                    replacements.append(Replacement(f, idx, line.rstrip(), rebuilt))
                    changed = True
                    new_lines.append(rebuilt)
                else:
                    new_lines.append(line)

            except Exception as exc:
                msg = str(exc)
                if "expression" in msg:
                    skipped_dynamic.append((f, idx, uses_val))
                    new_lines.append(line)
                else:
                    unresolved.append((f, idx, uses_val, msg))
                    new_lines.append(line)

        if changed and args.apply:
            f.write_text("\n".join(new_lines) + "\n", encoding="utf-8")

    # Summary
    print(f"Scanned files: {len(files)}")
    print(f"Planned replacements: {len(replacements)}")
    if not args.apply:
        print("Mode: DRY-RUN (no files modified). Use --apply to write changes.")
    else:
        print("Mode: APPLY (files modified).")

    # Print a compact diff-like summary (first 200 lines)
    max_show = 200
    shown = 0
    for r in replacements:
        if shown >= max_show:
            print(f"... (truncated; {len(replacements) - shown} more replacements)")
            break
        print(f"{r.file}:{r.line_no}")
        print(f"- {r.old}")
        print(f"+ {r.new}")
        shown += 1

    if skipped_dynamic:
        print(f"\nSkipped dynamic refs (needs manual fix): {len(skipped_dynamic)}")
        for f, ln, u in skipped_dynamic[:25]:
            print(f"  {f}:{ln} -> {u}")
        if len(skipped_dynamic) > 25:
            print("  ... (truncated)")

    if unresolved:
        print(f"\nUnresolved refs (needs investigation): {len(unresolved)}")
        for f, ln, u, err in unresolved[:25]:
            print(f"  {f}:{ln} -> {u} ({err})")
        if len(unresolved) > 25:
            print("  ... (truncated)")

    # Non-zero exit only if apply failed? Keep it 0 so it's usable during cleanup.
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))
