#!/usr/bin/env python3
"""
Fix duplicate milestone_id values in milestone documentation.

This script identifies and resolves duplicate milestone_id values by adding
sequence suffixes to ensure uniqueness while preserving chronological order.
"""

import yaml
from pathlib import Path
from typing import Dict, List, Tuple


def extract_yaml_frontmatter(content: str)  Tuple[Dict, str]:
    """Extract YAML frontmatter and content from markdown file."""
    if not content.startswith("---\n"):
        return {}, content

    # Find the closing ---
    lines = content.split("\n")
    yaml_end = -1
    for i, line in enumerate(lines[1:], 1):
        if line.strip() == "---":
            yaml_end = i
            break

    if yaml_end == -1:
        return {}, content

    yaml_content = "\n".join(lines[1:yaml_end])
    markdown_content = "\n".join(lines[yaml_end  1 :])

    try:
        yaml_data = yaml.safe_load(yaml_content)
        return yaml_data or {}, markdown_content
    except yaml.YAMLError:
        return {}, content


def update_yaml_frontmatter(yaml_data: Dict, content: str)  str:
    """Update file content with new YAML frontmatter."""
    yaml_str = yaml.dump(yaml_data, default_flow_style=False, sort_keys=False)
    return f"---\n{yaml_str}---\n{content}"


def find_milestone_files()  List[Path]:
    """Find all milestone documentation files."""
    milestone_dir = Path("milestones")
    if not milestone_dir.exists():
        return []

    return list(milestone_dir.rglob("*.md"))


def analyze_duplicates()  Dict[str, List[Path]]:
    """Analyze milestone files and identify duplicate milestone_id values."""
    milestone_files = find_milestone_files()
    milestone_ids = {}

    for file_path in milestone_files:
        try:
            with open(file_path, "r", encoding="utf-8") as f:
                content = f.read()

            yaml_data, _ = extract_yaml_frontmatter(content)
            milestone_id = yaml_data.get("milestone_id", "")

            if milestone_id:
                if milestone_id not in milestone_ids:
                    milestone_ids[milestone_id] = []
                milestone_ids[milestone_id].append(file_path)

        except Exception as e:
            print(f"Error processing {file_path}: {e}")

    # Return only duplicates
    return {k: v for k, v in milestone_ids.items() if len(v) > 1}


def fix_duplicate_milestone_ids():
    """Fix duplicate milestone_id values by adding sequence suffixes."""
    duplicates = analyze_duplicates()

    if not duplicates:
        print(" No duplicate milestone_id values found.")
        return

    print(f" Found {len(duplicates)} sets of duplicate milestone_id values:")

    for milestone_id, files in duplicates.items():
        print(f"\nPIN: Duplicate milestone_id: {milestone_id}")
        print(f"   Files affected: {len(files)}")

        # Sort files by modification time to preserve chronological order
        files_with_mtime = [(f, f.stat().st_mtime) for f in files]
        files_with_mtime.sort(key=lambda x: x[1])

        for i, (file_path, _) in enumerate(files_with_mtime):
            try:
                with open(file_path, "r", encoding="utf-8") as f:
                    content = f.read()

                yaml_data, markdown_content = extract_yaml_frontmatter(content)

                if i == 0:
                    # Keep the first file (oldest) unchanged
                    print(f"    Keeping original: {file_path}")
                    continue

                # Add sequence suffix to subsequent files
                new_milestone_id = f"{milestone_id}-{i1}"
                yaml_data["milestone_id"] = new_milestone_id

                # Update file content
                new_content = update_yaml_frontmatter(yaml_data, markdown_content)

                with open(file_path, "w", encoding="utf-8") as f:
                    f.write(new_content)

                print(f"    Updated: {file_path}")
                print(f"      New milestone_id: {new_milestone_id}")

            except Exception as e:
                print(f"    Error updating {file_path}: {e}")


def fix_filename_patterns():
    """Fix filename patterns to match required format."""
    milestone_files = find_milestone_files()

    for file_path in milestone_files:
        filename = file_path.name

        # Check if filename contains invalid type 'ci-fix'
        if "ci-fix" in filename:
            print(f" Fixing filename pattern: {filename}")

            # Replace 'ci-fix' with 'infrastructure'
            new_filename = filename.replace("ci-fix", "infrastructure")
            new_path = file_path.parent / new_filename

            # Also update the YAML frontmatter type
            try:
                with open(file_path, "r", encoding="utf-8") as f:
                    content = f.read()

                yaml_data, markdown_content = extract_yaml_frontmatter(content)

                if yaml_data.get("type") == "ci-fix":
                    yaml_data["type"] = "infrastructure"
                    content = update_yaml_frontmatter(yaml_data, markdown_content)

                # Write to new filename
                with open(new_path, "w", encoding="utf-8") as f:
                    f.write(content)

                # Remove old file
                file_path.unlink()

                print(f"    Renamed: {filename}  {new_filename}")
                print("    Updated type: ci-fix  infrastructure")

            except IOError as e:
                print(f"    Error fixing {file_path}: {e}")


def main():
    """Main function to fix milestone validation issues."""
    print(" DevOnboarder Milestone Validation Issue Fixer")
    print("=" * 50)

    print("\n1. Analyzing duplicate milestone_id values...")
    fix_duplicate_milestone_ids()

    print("\n2. Fixing filename patterns...")
    fix_filename_patterns()

    print("\n Milestone validation fixes complete!")
    print("\nNext steps:")
    print("- Run: python scripts/validate_milestone_format.py --summary")
    print("- Commit fixed files")
    print("- Verify 100% validation pass rate")


if __name__ == "__main__":
    main()
