import os
import sys
import language_tool_python
try:
    from requests.exceptions import RequestException
except Exception:
    RequestException = Exception

files = sys.argv[1:]
if not files:
    print('No files provided')
    sys.exit(0)

server = os.environ.get("LANGUAGETOOL_URL", "https://api.languagetool.org/v2")
try:
    tool = language_tool_python.LanguageTool("en-US", remote_server=server)
except RequestException as e:
    print(f"Could not reach the LanguageTool server: {e}")
    sys.exit(1)
except Exception as e:
    print(f"Failed to initialize LanguageTool: {e}")
    sys.exit(1)

errors = 0
for path in files:
    with open(path, 'r', encoding='utf-8') as f:
        text = f.read()
    try:
        matches = tool.check(text)
    except RequestException as e:
        print(f"{path}: LanguageTool connection error: {e}")
        sys.exit(1)
    except Exception as e:
        print(f"{path}: LanguageTool error {e}")
        sys.exit(1)
    if matches:
        print(f"{path}: {len(matches)} issues found")
        for m in matches:
            line, col = m.get_line_and_column(text)
            print(f"- Line {line}, column {col}: {m.message}")
        errors += len(matches)

if errors:
    print(f'{errors} issues found.')
    sys.exit(1)
print('No LanguageTool issues found.')
