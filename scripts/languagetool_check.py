import os
import sys

import language_tool_python


def check_file(path: str, tool: language_tool_python.LanguageTool) -> int:
    """Check a single file and return the number of issues."""
    with open(path, encoding="utf-8") as f:
        text = f.read()
    try:
        matches = tool.check(text)
    except Exception as e:  # network or parsing errors
        print(f"{path}: LanguageTool error {e}")
        return 1
    if matches:
        print(f"{path}: {len(matches)} issues found")
        for m in matches:
            line, col = m.get_line_and_column(text)
            print(f"- Line {line}, column {col}: {m.message}")
        return len(matches)
    return 0


def main(files: list[str]) -> None:
    url = os.environ.get("LANGUAGETOOL_URL", "https://api.languagetool.org/v2")
    try:
        tool = language_tool_python.LanguageTool("en-US", remote_server=url)
    except Exception as e:  # initialization errors
        print(f"Failed to initialize LanguageTool: {e}")
        sys.exit(2)

    errors = 0
    for path in files:
        errors += check_file(path, tool)
    if errors:
        print(f"{errors} issues found.")
    else:
        print("No LanguageTool issues found.")
    sys.exit(errors)


if __name__ == "__main__":
    if len(sys.argv) <= 1:
        sys.exit(0)
    main(sys.argv[1:])
