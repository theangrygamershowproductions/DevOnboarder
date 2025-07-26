#!/usr/bin/env python3
"""Test the PR summary validation."""

from scripts.validate_pr_summary import validate_pr_summary
import sys
from pathlib import Path

# Add the project root to the path
sys.path.insert(0, str(Path(__file__).parent.parent))


def test_validation():
    """Test the validation function."""
    # Test with the actual PR_SUMMARY.md
    pr_summary_path = Path("PR_SUMMARY.md")

    if not pr_summary_path.exists():
        print("❌ PR_SUMMARY.md not found")
        return False

    is_valid, errors = validate_pr_summary(pr_summary_path)

    print(f"📋 Validation Results for {pr_summary_path}")
    print(f"✅ Valid: {is_valid}")

    if errors:
        print("❌ Errors found:")
        for error in errors:
            print(f"  • {error}")
    else:
        print("✅ No errors found")

    return is_valid


if __name__ == "__main__":
    test_validation()
