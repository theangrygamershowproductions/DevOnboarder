#!/usr/bin/env python3
"""
DevOnboarder Priority Matrix Synthesis.

Auto-generates Priority Matrix fields for 100% accurate similarity detection
"""

import json
import pathlib
import re
import subprocess  # nosec B404 - Required for git and shell commands
import sys

from ruamel.yaml import YAML

yaml = YAML()
yaml.preserve_quotes = True

# Load tunable rules
RULES_PATH = pathlib.Path(".codex/rules/priority_matrix.yml")
if RULES_PATH.exists():
    RULES = yaml.load(RULES_PATH.read_text())
else:
    RULES = {"merge_threshold": 0.88, "group_overrides": []}

DOC_ROOT = pathlib.Path("docs")
AGENT_ROOT = pathlib.Path("agents")
CODEX_AGENTS_ROOT = pathlib.Path(".codex/agents")


def load_frontmatter(path):
    """Extract YAML frontmatter and body from markdown file."""
    try:
        txt = path.read_text(encoding="utf-8")
        if not txt.startswith("---"):
            # No frontmatter exists - create empty frontmatter
            return {}, txt
        parts = txt.split("---", 2)
        if len(parts) < 3:
            # Malformed frontmatter - treat as no frontmatter
            return {}, txt
        frontmatter = yaml.load(parts[1]) or {}
        body = parts[2].lstrip("\n")
        return frontmatter, body
    except (FileNotFoundError, UnicodeDecodeError):
        return {}, ""


def write_frontmatter(path, frontmatter, body):
    """Write YAML frontmatter and body back to markdown file."""
    try:
        import io

        lines = ["---\n"]
        stream = io.StringIO()
        yaml.dump(frontmatter, stream)
        lines.append(stream.getvalue())
        lines.append("---\n")
        lines.append(body)
        path.write_text("".join(lines), encoding="utf-8")
        return True
    except (FileNotFoundError, UnicodeDecodeError) as e:
        print(f"Error writing {path}: {e}", file=sys.stderr)
        return False


def git_churn(path):
    """Get git history metrics for the file."""
    try:
        # Get authors with full path to git
        out = subprocess.check_output(  # nosec B603 - controlled git command
            ["/usr/bin/git", "log", "--pretty=tformat:author:%an", "--", str(path)],
            text=True,
            stderr=subprocess.DEVNULL,
        )
        authors = set(
            [
                line.split("author:", 1)[1]
                for line in out.splitlines()
                if line.startswith("author:")
            ]
        )

        # Get commit count with full path to git
        cnt = int(
            subprocess.check_output(  # nosec B603 - controlled git cmd
                ["/usr/bin/git", "rev-list", "--count", "HEAD", "--", str(path)],
                text=True,
                stderr=subprocess.DEVNULL,
            ).strip()
            or "0"
        )

        return {"authors": len(authors), "commits": cnt}
    except (subprocess.CalledProcessError, ValueError):
        return {"authors": 0, "commits": 0}


def fingerprint_similarity(path1, path2):
    """Calculate similarity using DevOnboarder's enhanced fingerprinting."""
    try:
        # Use the existing enhanced fingerprinting
        cmd = f"""
        source scripts/detect_content_duplication.sh >/dev/null 2>&1
        fp1=$(generate_enhanced_fingerprint '{path1}' 2>/dev/null)
        fp2=$(generate_enhanced_fingerprint '{path2}' 2>/dev/null)
        calculate_enhanced_similarity "$fp1" "$fp2" 2>/dev/null
        """
        result = subprocess.check_output(  # nosec B603,B607 - controlled bash
            ["/bin/bash", "-c", cmd], text=True
        ).strip()
        return float(result) / 100.0 if result.isdigit() else 0.0
    except (subprocess.CalledProcessError, ValueError):
        return 0.0


def is_agent_file(path):
    """Check if this is an agent file that should use codex-agent frontmatter."""
    return (
        "agents" in path.parts
        or ".codex" in path.parts
        or "agent" in path.name.lower()
        or "bot" in path.name.lower()
    )


def choose_similarity_group(path, frontmatter):
    """Determine similarity group using rules and heuristics."""
    tags = [t.lower() for t in (frontmatter.get("tags") or [])]

    # Check override rules
    for rule in RULES.get("group_overrides", []):
        if any(t in tags for t in rule.get("tags", [])):
            return rule["group"]

    # Default: path-based  document_type
    parts = path.parts
    top = parts[1] if len(parts) > 1 else "docs"
    dtype = (frontmatter.get("document_type") or "").lower()

    if dtype:
        return f"{top}-{re.sub('[^a-z0-9]', '-', dtype)}"
    return f"{top}-{re.sub('[^a-z0-9]', '-', path.parent.name)}"


def find_similar_files(target_path, group):
    """Find files in the same similarity group."""
    similar = []
    for path in DOC_ROOT.rglob("*.md"):
        if path == target_path:
            continue
        frontmatter, _ = load_frontmatter(path)
        if frontmatter.get("similarity_group") == group:
            similar.append(path)
    return similar


def calculate_max_similarity(target_path, similar_files):
    """Calculate maximum similarity to files in the same group."""
    max_sim = 0.0
    for other_path in similar_files:
        sim = fingerprint_similarity(target_path, other_path)
        max_sim = max(max_sim, sim)
    return max_sim


def uniqueness_from_similarity(sim):
    """Map similarity score to uniqueness score (0-5)."""
    if sim >= 0.95:
        return 0
    if sim >= 0.90:
        return 1
    if sim >= 0.85:
        return 2
    if sim >= 0.75:
        return 3
    return 4  # Can be boosted to 5 with additional factors


def synthesize_priority_matrix(path):
    """Generate Priority Matrix fields for a single document."""
    frontmatter, body = load_frontmatter(path)
    changed = False
    confidence = 1.0

    # Special handling for agent files
    if is_agent_file(path):
        # Agent files may already have codex-agent frontmatter - preserve it
        if "codex-agent" in frontmatter:
            # Skip Priority Matrix synthesis for agent files with codex-agent metadata
            # These use a different metadata structure
            return False, frontmatter, body, 1.0, 0.0
        elif not frontmatter:
            # Empty agent file - might need codex-agent frontmatter
            # But don't auto-add it, just add Priority Matrix fields
            pass

    # Calculate confidence based on available signals
    if not frontmatter.get("tags"):
        confidence -= 0.2
    if not frontmatter.get("document_type"):
        confidence -= 0.2
    if "backup" in str(path) or "archive" in str(path):
        confidence -= 0.2  # 1. Similarity Group
    group = frontmatter.get("similarity_group") or choose_similarity_group(
        path, frontmatter
    )
    if "similarity_group" not in frontmatter:
        frontmatter["similarity_group"] = group
        changed = True

    # 2. Find similar files and calculate max similarity
    similar_files = find_similar_files(path, group)
    max_sim = calculate_max_similarity(path, similar_files) if similar_files else 0.0

    # 3. Content Uniqueness Score
    uniqueness = frontmatter.get("content_uniqueness_score")
    if uniqueness is None:
        uniqueness = uniqueness_from_similarity(max_sim)
        # Boost for high-value documents
        if frontmatter.get("project") == "core-instructions":
            uniqueness = min(5, uniqueness + 1)
        frontmatter["content_uniqueness_score"] = int(uniqueness)
        changed = True

    # 4. Merge Candidate
    merge_candidate = frontmatter.get("merge_candidate")
    if merge_candidate is None:
        threshold = RULES.get("merge_threshold", 0.88)
        is_merge_candidate = max_sim >= threshold or (
            frontmatter.get("status") in ["draft", "deprecated", "superseded"]
            and uniqueness <= 3
        )
        frontmatter["merge_candidate"] = is_merge_candidate
        changed = True
        merge_candidate = is_merge_candidate

    # 5. Consolidation Priority
    priority = frontmatter.get("consolidation_priority")
    if priority is None:
        if merge_candidate and uniqueness <= 2:
            priority = "P1"
        elif merge_candidate or uniqueness == 3:
            priority = "P2"
        else:
            priority = "P3"
        frontmatter["consolidation_priority"] = priority
        changed = True

    return changed, frontmatter, body, confidence, max_sim


def main():
    """Main synthesis routine."""
    modified = []
    all_files = []

    # Process all relevant directories
    for root in [DOC_ROOT, AGENT_ROOT, CODEX_AGENTS_ROOT]:
        if root.exists():
            all_files.extend(list(root.rglob("*.md")))

    # Also process root-level markdown files
    root_files = [f for f in pathlib.Path(".").glob("*.md") if f.is_file()]
    all_files.extend(root_files)

    for path in all_files:
        try:
            changed, frontmatter, body, conf, sim = synthesize_priority_matrix(path)
            if changed:
                success = write_frontmatter(path, frontmatter, body)
                if success:
                    modified.append(
                        {
                            "path": str(path),
                            "priority": frontmatter["consolidation_priority"],
                            "merge": frontmatter["merge_candidate"],
                            "uniqueness": frontmatter["content_uniqueness_score"],
                            "similarity_group": frontmatter["similarity_group"],
                            "confidence": round(conf, 2),
                            "max_similarity": round(sim, 2),
                        }
                    )
        except (KeyError, ValueError) as e:
            print(f"Error processing {path}: {e}", file=sys.stderr)

    # Output JSON summary
    result = {
        "modified": modified,
        "total_processed": len(all_files),
        "rules_version": RULES.get("version", "1.0"),
    }

    print(json.dumps(result, indent=2))
    return 0


if __name__ == "__main__":
    sys.exit(main())
