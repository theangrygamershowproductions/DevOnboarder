# generate_project_index.py
# PATCHED v0.1.0 docs/generate_project_index.py — index docs directory

"""Generate a Markdown index of all documents under the docs folder."""

from pathlib import Path


def generate_index(
    base_dir: str = "docs",
    index_file: str = "PROJECTS_INDEX.md",
):
    """Write a simple Markdown index of the documentation tree."""
    base_path = Path(base_dir)
    output_file = base_path / index_file
    lines = ["# Project Index\n"]

    for section in sorted(base_path.iterdir()):
        if section.is_dir():
            section_title = section.name.upper()
            lines.append(f"\n## {section_title}\n")
            for md_file in sorted(section.rglob("*.md")):
                if md_file.name == index_file:
                    continue  # Skip the index file itself
                rel_path = md_file.relative_to(base_path)
                lines.append(f"- [{md_file.stem}]({rel_path.as_posix()})")

    output_file.write_text("\n".join(lines))
    print(f"✅ Index written to: {output_file}")


if __name__ == "__main__":
    generate_index()
