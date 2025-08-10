#!/usr/bin/env python3
"""
Enhanced GitHub issue commenting for AAR system.

Provides structured, contextual AAR summaries directly in GitHub issues/PRs
for immediate developer visibility within VSCode and GitHub interface.
"""

import argparse
import os
import subprocess
import sys
from datetime import datetime
from pathlib import Path


def run_command(cmd: list[str]) -> tuple[str, int]:
    """Run shell command and return output and exit code."""
    try:
        result = subprocess.run(cmd, capture_output=True, text=True, check=False)
        return result.stdout.strip(), result.exitcode
    except Exception as e:
        return f"Error: {e}", 1


def get_aar_summary(aar_path: str) -> dict[str, str]:
    """Extract key insights from AAR file for comment summary."""
    if not os.path.exists(aar_path):
        return {"status": "AAR file not found"}

    try:
        with open(aar_path, "r", encoding="utf-8") as f:
            content = f.read()

        # Extract key sections for summary
        summary = {
            "files_changed": "Unknown",
            "agents_updated": "0",
            "key_decisions": "None documented",
            "action_items": "0",
            "codex_alignment": "Not verified",
        }

        # Parse file for structured data
        lines = content.split("\n")
        for i, line in enumerate(lines):
            if "Files Changed:" in line or "Changed Files:" in line:
                # Look for number in next few lines
                for j in range(i, min(i + 5, len(lines))):
                    if lines[j].strip().isdigit():
                        summary["files_changed"] = lines[j].strip()
                        break
            elif "Agents Updated:" in line or "Codex Agents:" in line:
                # Extract agent count
                for j in range(i, min(i + 3, len(lines))):
                    if lines[j].strip().isdigit():
                        summary["agents_updated"] = lines[j].strip()
                        break
            elif "Action Items:" in line:
                # Count action items
                action_count = 0
                for j in range(i + 1, min(i + 20, len(lines))):
                    if lines[j].strip().startswith("- [ ]"):
                        action_count += 1
                summary["action_items"] = str(action_count)
            elif "Codex Alignment:" in line:
                # Check alignment status
                if "Verified" in content[i : i + 100]:
                    summary["codex_alignment"] = "Verified"

        return summary

    except Exception as e:
        return {"status": f"Error parsing AAR: {e}"}


def create_structured_comment(
    ref_type: str, ref_number: str, aar_summary: dict[str, str]
) -> str:
    """Create structured comment for GitHub issue/PR."""

    quarter = f"Q{((datetime.now().month - 1) // 3) + 1}"
    year = datetime.now().year

    if ref_type == "pull_request":
        aar_path = f".aar/{year}/{quarter}/pull-requests/pr-{ref_number}-*.md"
        icon = "🔀"
        title = f"AAR Complete for PR #{ref_number}"
    else:
        aar_path = f".aar/{year}/{quarter}/issues/issue-{ref_number}-*.md"
        icon = "🎯"
        title = f"AAR Complete for Issue #{ref_number}"

    # Build summary table
    summary_table = f"""
| Metric | Value |
|--------|-------|
| Files Changed | {aar_summary.get("files_changed", "Unknown")} |
| Codex Agents | {aar_summary.get("agents_updated", "0")} updated |
| Action Items | {aar_summary.get("action_items", "0")} identified |
| Codex Alignment | {aar_summary.get("codex_alignment", "Not verified")} |
"""

    comment = f"""## {icon} {title}

### 📊 Summary

{summary_table}

### 📁 Resources

**AAR Location**: `{aar_path}`
**Follow-up Issue**: Automatically created with action items
**Purpose**: Preserve institutional knowledge and improve development processes

### 🧠 Key Insights

- **Technical Decisions**: Documented in AAR for future reference
- **Process Analysis**: Development workflow insights captured
- **Lessons Learned**: Best practices and gotchas identified
- **Action Items**: {aar_summary.get("action_items", "0")} items tracked for follow-up

### 💡 For Developers

This AAR is immediately accessible in VSCode via:
- GitHub Issues/PRs panel
- Direct file access in `.aar/` directory
- Follow-up issue tracking for action items

*Posted automatically by DevOnboarder AAR system following \
"quiet reliability" philosophy*"""

    return comment


def post_github_comment(ref_type: str, ref_number: str, comment_body: str) -> bool:
    """Post comment to GitHub issue or PR using GitHub CLI."""

    if ref_type == "pull_request":
        cmd = ["gh", "pr", "comment", ref_number, "--body", comment_body]
    else:
        cmd = ["gh", "issue", "comment", ref_number, "--body", comment_body]

    output, exit_code = run_command(cmd)

    if exit_code == 0:
        print(f"Successfully posted comment to {ref_type} #{ref_number}")
        return True
    else:
        print(f"Failed to post comment: {output}")
        return False


def main():
    """Main entry point for issue commenting automation."""
    parser = argparse.ArgumentParser(
        description="Post structured AAR comments to GitHub issues/PRs"
    )
    parser.add_argument(
        "--type",
        choices=["issue", "pull_request", "aar"],
        required=True,
        help="Type of comment to post",
    )
    parser.add_argument(
        "--ref",
        required=True,
        help="Issue/PR number or reference (e.g., 'pr-123', '456')",
    )
    parser.add_argument("--aar-path", help="Path to AAR file for summary extraction")

    args = parser.parse_args()

    # Parse reference
    ref_number = args.ref.replace("pr-", "").replace("issue-", "")
    ref_type = "pull_request" if "pr-" in args.ref else "issue"

    # Find AAR file if not provided
    if not args.aar_path:
        quarter = f"Q{((datetime.now().month - 1) // 3) + 1}"
        year = datetime.now().year

        if ref_type == "pull_request":
            aar_dir = f".aar/{year}/{quarter}/pull-requests/"
            pattern = f"pr-{ref_number}-*.md"
        else:
            aar_dir = f".aar/{year}/{quarter}/issues/"
            pattern = f"issue-{ref_number}-*.md"

        # Find matching AAR file
        if os.path.exists(aar_dir):
            aar_files = list(Path(aar_dir).glob(pattern))
            if aar_files:
                args.aar_path = str(aar_files[0])

    # Extract AAR summary
    aar_summary = {}
    if args.aar_path:
        aar_summary = get_aar_summary(args.aar_path)

    # Create and post comment
    comment = create_structured_comment(ref_type, ref_number, aar_summary)

    success = post_github_comment(ref_type, ref_number, comment)

    if success:
        print(f"Enhanced AAR comment posted to {ref_type} #{ref_number}")
        sys.exit(0)
    else:
        print(f"Failed to post comment to {ref_type} #{ref_number}")
        sys.exit(1)


if __name__ == "__main__":
    main()
