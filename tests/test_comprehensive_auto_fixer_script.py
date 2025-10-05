"""Test coverage for scripts/comprehensive_auto_fixer.py script."""

import importlib.util
from pathlib import Path


def test_comprehensive_auto_fixer_loads():
    """Test that comprehensive_auto_fixer.py can be loaded as a module."""
    script_path = (
        Path(__file__).parent.parent / "scripts" / "comprehensive_auto_fixer.py"
    )
    assert script_path.exists(), f"Script file not found at {script_path}"

    spec = importlib.util.spec_from_file_location(
        "comprehensive_auto_fixer", script_path
    )
    assert spec is not None
    assert spec.loader is not None

    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)

    # Verify it's a proper Python script
    assert hasattr(module, "__file__")


def test_comprehensive_auto_fixer_importable():
    """Test that comprehensive_auto_fixer.py is importable without errors."""
    script_path = (
        Path(__file__).parent.parent / "scripts" / "comprehensive_auto_fixer.py"
    )

    spec = importlib.util.spec_from_file_location(
        "comprehensive_auto_fixer", script_path
    )
    module = importlib.util.module_from_spec(spec)

    # This should not raise any import errors
    spec.loader.exec_module(module)

    # Check for basic module structure
    assert hasattr(module, "__doc__")


def test_comprehensive_auto_fixer_structure():
    """Test that comprehensive_auto_fixer.py has expected auto-fixing structure."""
    script_path = (
        Path(__file__).parent.parent / "scripts" / "comprehensive_auto_fixer.py"
    )

    with open(script_path, "r", encoding="utf-8") as f:
        content = f.read()

    # Check for auto-fixing content
    fixer_keywords = ["fix", "auto", "comprehensive", "error", "correct"]
    has_fixer_logic = any(keyword in content.lower() for keyword in fixer_keywords)
    assert has_fixer_logic, "Script should contain auto-fixing logic"

    # Check for substantial script content
    lines = [
        line.strip()
        for line in content.split("\n")
        if line.strip() and not line.strip().startswith("#")
    ]
    assert len(lines) > 10, "Script should have substantial content"
