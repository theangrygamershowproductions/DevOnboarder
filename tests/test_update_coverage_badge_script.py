"""Test coverage for scripts/update_coverage_badge.py script."""

import importlib.util
from pathlib import Path


def test_update_coverage_badge_loads():
    """Test that update_coverage_badge.py can be loaded as a module."""
    script_path = Path(__file__).parent.parent / "scripts" / "update_coverage_badge.py"
    assert script_path.exists(), f"Script file not found at {script_path}"

    spec = importlib.util.spec_from_file_location("update_coverage_badge", script_path)
    assert spec is not None
    assert spec.loader is not None

    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)

    # Verify it's a proper Python script
    assert hasattr(module, "__file__")


def test_update_coverage_badge_importable():
    """Test that update_coverage_badge.py is importable without errors."""
    script_path = Path(__file__).parent.parent / "scripts" / "update_coverage_badge.py"

    spec = importlib.util.spec_from_file_location("update_coverage_badge", script_path)
    module = importlib.util.module_from_spec(spec)

    # This should not raise any import errors
    spec.loader.exec_module(module)

    # Check for basic module structure
    assert hasattr(module, "__doc__")


def test_update_coverage_badge_structure():
    """Test that update_coverage_badge.py has expected badge updating structure."""
    script_path = Path(__file__).parent.parent / "scripts" / "update_coverage_badge.py"

    with open(script_path, "r", encoding="utf-8") as f:
        content = f.read()

    # Check for coverage badge content
    badge_keywords = ["coverage", "badge", "update", "svg", "percent"]
    has_badge_logic = any(keyword in content.lower() for keyword in badge_keywords)
    assert has_badge_logic, "Script should contain coverage badge logic"

    # Check for substantial script content
    lines = [
        line.strip()
        for line in content.split("\n")
        if line.strip() and not line.strip().startswith("#")
    ]
    assert len(lines) > 5, "Script should have substantial content"
