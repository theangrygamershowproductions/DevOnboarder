#!/usr/bin/env python3
"""Test the PR summary validation."""

import sys
from pathlib import Path

# Add the project root to the path
sys.path.insert(0, str(Path(__file__).parent.parent))

from scripts.validate_pr_summary import validate_pr_summary  # noqa: E402


def test_validation():
    """Test the validation function."""
    # Test with the actual PR_SUMMARY.md using project root
    project_root = Path(__file__).parent.parent
    pr_summary_path = project_root / "PR_SUMMARY.md"

    if not pr_summary_path.exists():
        print(f"❌ PR_SUMMARY.md not found at {pr_summary_path}")
        raise FileNotFoundError("PR_SUMMARY.md not found")

    is_valid, errors = validate_pr_summary(pr_summary_path)

    print(f"📋 Validation Results for {pr_summary_path}")
    print(f"✅ Valid: {is_valid}")

    if errors:
        print("❌ Errors found:")
        for error in errors:
            print(f"  • {error}")
    else:
        print("✅ No errors found")

    if not is_valid:
        raise AssertionError(f"Validation failed with errors: {errors}")


if __name__ == "__main__":
    test_validation()
