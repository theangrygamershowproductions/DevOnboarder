#!/usr/bin/env python
"""Generate the OpenAPI specification for the auth service."""

from __future__ import annotations

import json
from pathlib import Path
import os

import sys

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "src"))

os.environ.setdefault("APP_ENV", "development")

from devonboarder.auth_service import create_app  # noqa: E402


def main() -> None:
    """Write the application's OpenAPI spec to ``src/devonboarder/openapi.json``."""
    import subprocess  # nosec B404

    app = create_app()
    spec = app.openapi()
    output = ROOT / "src" / "devonboarder" / "openapi.json"

    # Write with minimal formatting first
    output.write_text(json.dumps(spec, indent=2))

    # Use prettier to format consistently
    try:
        subprocess.run(  # nosec B603, B607
            ["npx", "prettier", "--write", str(output)],
            cwd=ROOT,
            check=True,
            capture_output=True,
        )
        print(f"Wrote and formatted {output}")
    except subprocess.CalledProcessError as e:
        print(f"Warning: prettier formatting failed: {e}")
        print(f"Wrote {output} (unformatted)")


if __name__ == "__main__":
    main()
