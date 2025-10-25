#!/usr/bin/env python3
"""Fix duplicate tags in frontmatter."""

import os
import yaml


def fix_duplicate_tags_in_file(file_path):
    """Remove duplicate tags from a markdown file's frontmatter."""
    try:
        with open(file_path, "r", encoding="utf-8") as f:
            content = f.read()

        # Check if file has frontmatter
        if not content.startswith("---"):
            return False

        # Split frontmatter and content
        parts = content.split("---", 2)
        if len(parts) < 3:
            return False

        frontmatter_text = parts[1].strip()
        body = parts[2]

        # Parse YAML
        try:
            frontmatter = yaml.safe_load(frontmatter_text)
        except yaml.YAMLError:
            print(f"Warning: Could not parse YAML in {file_path}")
            return False

        if not isinstance(frontmatter, dict):
            return False

        # Fix duplicate tags
        if "tags" in frontmatter and isinstance(frontmatter["tags"], list):
            original_tags = frontmatter["tags"]
            # Remove duplicates while preserving order
            unique_tags = []
            seen = set()
            for tag in original_tags:
                if tag not in seen:
                    unique_tags.append(tag)
                    seen.add(tag)

            if len(unique_tags) != len(original_tags):
                print(f"Fixing duplicate tags in: {file_path}")
                frontmatter["tags"] = unique_tags

                # Write back to file
                new_frontmatter = yaml.dump(
                    frontmatter, default_flow_style=False, allow_unicode=True
                ).strip()
                new_content = f"---\n{new_frontmatter}\n---{body}"

                with open(file_path, "w", encoding="utf-8") as f:
                    f.write(new_content)
                return True

    except Exception as e:
        print(f"Error processing {file_path}: {e}")

    return False


def main():
    """Fix duplicate tags in all markdown files."""
    fixed_count = 0
    processed_count = 0

    for root, dirs, files in os.walk("."):
        # Skip node_modules and other irrelevant directories
        dirs[:] = [
            d for d in dirs if d not in [".git", "node_modules", ".venv", "__pycache__"]
        ]

        for file in files:
            if file.endswith(".md"):
                file_path = os.path.join(root, file)
                processed_count = 1

                if fix_duplicate_tags_in_file(file_path):
                    fixed_count = 1

    print(f"\nProcessed {processed_count} markdown files")
    print(f"Fixed duplicate tags in {fixed_count} files")


if __name__ == "__main__":
    main()
