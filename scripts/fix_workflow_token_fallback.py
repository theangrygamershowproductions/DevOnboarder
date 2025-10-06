#!/usr/bin/env python3
"""
Fix GitHub Actions token fallback syntax across all workflows.

The issue: ${{ secrets.A || secrets.B }} fails when secret A exists but is empty.
Solution: Replace with multi-step token selection using GITHUB_OUTPUT pattern.
"""

import re
import sys
from pathlib import Path
from typing import List, Tuple


def find_problematic_patterns(content: str) -> List[Tuple[int, str, str]]:
    """Find lines with problematic token fallback patterns."""
    patterns = []
    lines = content.split("\n")

    # Pattern to match: secrets.TOKEN1 || secrets.TOKEN2 (with fallbacks)
    token_pattern = (
        r"\$\{\{\s*secrets\.[A-Z_]+\s*\|\|\s*secrets\.[A-Z_]+"
        r"(?:\s*\|\|\s*secrets\.[A-Z_]+)*\s*\}\}"
    )  # noqa: B105

    for i, line in enumerate(lines, 1):
        matches = re.findall(token_pattern, line)
        for match in matches:
            patterns.append((i, line.strip(), match))

    return patterns


def extract_tokens_from_pattern(pattern: str) -> List[str]:
    """Extract token names from fallback pattern."""
    # Extract all secret names from the pattern
    token_matches = re.findall(r"secrets\.([A-Z_]+)", pattern)
    return token_matches


def generate_token_selection_step(tokens: List[str], step_id: str = "set-token") -> str:
    """Generate the multi-step token selection step."""
    lines = [
        "      - name: Set token for authentication",
        f"        id: {step_id}",
        "        run: |",
        "          # Multi-step token selection following Priority Matrix pattern",
    ]

    # Build if-elif chain for token selection
    for i, token in enumerate(tokens):
        condition = "if" if i == 0 else "elif"
        lines.extend(
            [
                f'          {condition} [ -n "${{{{ secrets.{token} }}}}" ]; then',
                f'              echo "selected-token=${{{{ secrets.{token} }}}}" '
                f">> $GITHUB_OUTPUT",
                f'              echo "token-source={token}" >> $GITHUB_OUTPUT',
            ]
        )

    lines.extend(
        [
            "          else",
            '              echo "::error::No authentication token available '
            'for operations!"',
            "              exit 1",
            "          fi",
            '          echo "Using token source: $(cat $GITHUB_OUTPUT | '
            'grep token-source | cut -d= -f2)"',
            "",
        ]
    )

    return "\n".join(lines)


def fix_workflow_file(filepath: Path, dry_run: bool = False) -> bool:
    """Fix token fallback patterns in a workflow file."""
    print(f"Processing: {filepath.name}")

    with open(filepath, "r") as f:
        content = f.read()

    patterns = find_problematic_patterns(content)
    if not patterns:
        print(f"  ✅ No problematic patterns found in {filepath.name}")
        return False

    print(f"  🔍 Found {len(patterns)} problematic patterns:")
    for line_num, line, pattern in patterns:
        print(f"    Line {line_num}: {pattern}")

    if dry_run:
        print(f"  📋 Dry run - would fix {len(patterns)} patterns")
        return True

    # For now, just report what needs fixing
    # Implementation of actual fixes would go here
    print(f"  ⚠️  Implementation needed for {filepath.name}")
    return True


def main():
    """Main function to process all workflow files."""
    if len(sys.argv) > 1 and sys.argv[1] == "--dry-run":
        dry_run = True
        print("🔍 DRY RUN MODE - No files will be modified")
    else:
        dry_run = False

    workflows_dir = Path(__file__).parent.parent / ".github" / "workflows"

    if not workflows_dir.exists():
        print(f"❌ Workflows directory not found: {workflows_dir}")
        return 1

    workflow_files = list(workflows_dir.glob("*.yml"))
    print(f"📁 Found {len(workflow_files)} workflow files")

    modified_count = 0
    for workflow_file in sorted(workflow_files):
        if fix_workflow_file(workflow_file, dry_run):
            modified_count += 1

    print("\n📊 Summary:")
    print(f"  Files processed: {len(workflow_files)}")
    print(f"  Files needing fixes: {modified_count}")

    return 0


if __name__ == "__main__":
    sys.exit(main())
