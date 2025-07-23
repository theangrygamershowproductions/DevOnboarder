import os

SEARCH_PATTERNS = [
    "python:3.11",
    "Python 3.11",
    "python3.11",
    "3.11"
]

EXCLUDE_DIRS = {'.git', 'node_modules', 'htmlcov', '.venv',
                'venv', '__pycache__', '.pytest_cache', 'coverage', '.egg-info'}


def should_exclude(path):
    return any(excluded in path.split(os.sep) for excluded in EXCLUDE_DIRS)


def scan_repo(root='.'):
    for dirpath, dirnames, filenames in os.walk(root):
        # Exclude unwanted directories
        dirnames[:] = [d for d in dirnames if d not in EXCLUDE_DIRS]
        for filename in filenames:
            if filename.endswith(
                ('.pyc', '.png', '.jpg', '.jpeg', '.gif', '.zip', '.tar', '.gz')
            ):
                continue
            filepath = os.path.join(dirpath, filename)
            try:
                with open(
                    filepath, 'r', encoding='utf-8', errors='ignore'
                ) as f:
                    for i, line in enumerate(f, 1):
                        for pattern in SEARCH_PATTERNS:
                            if pattern in line:
                                print(f"{filepath}:{i}: {line.strip()}")
            except (IOError, OSError) as e:
                print(f"Could not read {filepath}: {e}")


if __name__ == "__main__":
    print("Scanning for Python 3.11 references...")
    scan_repo()
