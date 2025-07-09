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
    app = create_app()
    spec = app.openapi()
    output = ROOT / "src" / "devonboarder" / "openapi.json"
    output.write_text(json.dumps(spec, indent=2))
    print(f"Wrote {output}")


if __name__ == "__main__":
    main()
