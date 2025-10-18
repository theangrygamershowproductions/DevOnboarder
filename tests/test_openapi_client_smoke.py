"""Smoke tests for OpenAPI specification validity."""

import yaml
from pathlib import Path


def test_openapi_spec_exists():
    """Test that the OpenAPI spec file exists."""
    spec_path = Path("openapi/devonboarder.ci.yaml")
    assert spec_path.exists(), f"OpenAPI spec not found at {spec_path}"  # noqa: S101


def test_openapi_spec_valid_yaml():
    """Test that the OpenAPI spec is valid YAML."""
    spec_path = Path("openapi/devonboarder.ci.yaml")
    with open(spec_path, "r", encoding="utf-8") as f:
        spec = yaml.safe_load(f)

    # Basic OpenAPI 3.0 structure validation
    assert "openapi" in spec, "Missing 'openapi' field"  # noqa: S101
    assert "info" in spec, "Missing 'info' field"  # noqa: S101
    assert "title" in spec["info"], "Missing 'info.title' field"  # noqa: S101
    assert "version" in spec["info"], "Missing 'info.version' field"  # noqa: S101


def test_client_generation_placeholder():
    """Placeholder test for future client generation.

    This will be replaced with actual client import tests
    when the client generation pipeline is implemented.
    """
    # For now, just verify the spec exists for future client generation
    spec_path = Path("openapi/devonboarder.ci.yaml")
    # OpenAPI spec required for client generation
    assert spec_path.exists()  # noqa: S101
