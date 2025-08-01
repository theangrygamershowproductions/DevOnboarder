#!/usr/bin/env python3
"""
AAR Template Validation Script for Makefile Integration
Validates AAR templates for DevOnboarder markdown compliance
"""

import os
import re


def validate_md007_compliance(file_path):
    """Validate MD007 (list indentation) compliance."""
    if not os.path.exists(file_path):
        print(f"❌ File not found: {file_path}")
        return False

    with open(file_path, "r", encoding="utf-8") as f:
        lines = f.readlines()

    violations = []
    in_list = False
    expected_base_indent = 0

    for line_num, line in enumerate(lines, 1):
        list_match = re.match(r"^(\s*)-\s+(.*)$", line)

        if list_match:
            indent_spaces = len(list_match.group(1))

            if not in_list:
                expected_base_indent = indent_spaces
                in_list = True
            else:
                if indent_spaces > expected_base_indent:
                    expected_nested = expected_base_indent + 4
                    if indent_spaces != expected_nested:
                        msg = (
                            f"Line {line_num}: MD007 violation - nested list "
                            f"should have {expected_nested} spaces, "
                            f"got {indent_spaces}"
                        )
                        violations.append(msg)
        else:
            if (
                line.strip() == ""
                or not line.startswith(" ")
                or line.strip().startswith("#")
            ):
                in_list = False
                expected_base_indent = 0

    if violations:
        print(f"❌ MD007 violations in {file_path}:")
        for violation in violations:
            print(f"  {violation}")
        return False
    else:
        print(f"✅ {file_path}: MD007 compliant")
        return True


def validate_basic_markdown(file_path):
    """Validate basic markdown rules (no trailing spaces, etc.)."""
    if not os.path.exists(file_path):
        return False

    with open(file_path, "r", encoding="utf-8") as f:
        lines = f.readlines()

    issues = []

    # MD009: No trailing spaces (except 2 for line breaks)
    for line_num, line in enumerate(lines, 1):
        line_no_newline = line.rstrip("\n")
        if line_no_newline.endswith(" "):
            trailing_spaces = len(line_no_newline) - len(line_no_newline.rstrip(" "))
            if trailing_spaces != 2:
                msg = f"Line {line_num}: MD009 - {trailing_spaces} trailing spaces"
                issues.append(msg)

    if issues:
        print(f"❌ Basic markdown issues in {file_path}:")
        for issue in issues:
            print(f"  {issue}")
        return False
    else:
        print(f"✅ {file_path}: Basic markdown compliant")
        return True


def main():
    """Main validation function."""
    print("AAR Template Validation")
    print("=" * 30)

    templates = ["templates/aar-template.md", "templates/security-report.md"]

    all_valid = True

    for template in templates:
        if os.path.exists(template):
            md007_valid = validate_md007_compliance(template)
            basic_valid = validate_basic_markdown(template)
            all_valid = all_valid and md007_valid and basic_valid
        else:
            print(f"❌ Template not found: {template}")
            all_valid = False

    print("\n" + "=" * 30)
    if all_valid:
        print("✅ All AAR templates are valid")
        exit(0)
    else:
        print("❌ AAR template validation failed")
        exit(1)


if __name__ == "__main__":
    main()
