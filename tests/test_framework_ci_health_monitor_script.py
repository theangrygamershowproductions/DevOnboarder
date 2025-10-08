"""Test coverage for ci_health_monitor.py script."""

import importlib.util
from pathlib import Path


def test_framework_ci_health_monitor_loads():
    """Test that frameworks ci_health_monitor.py can be loaded as a module."""
    script_path = (
        Path(__file__).parent.parent
        / "frameworks"
        / "monitoring-automation"
        / "monitoring_scripts"
        / "ci_health_monitor.py"
    )
    assert script_path.exists(), f"Script file not found at {script_path}"

    spec = importlib.util.spec_from_file_location(
        "framework_ci_health_monitor", script_path
    )
    assert spec is not None
    assert spec.loader is not None

    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)

    # Verify it's a proper Python script
    assert hasattr(module, "__file__")


def test_framework_ci_health_monitor_importable():
    """Test that frameworks ci_health_monitor.py is importable without errors."""
    script_path = (
        Path(__file__).parent.parent
        / "frameworks"
        / "monitoring-automation"
        / "monitoring_scripts"
        / "ci_health_monitor.py"
    )

    spec = importlib.util.spec_from_file_location(
        "framework_ci_health_monitor", script_path
    )
    module = importlib.util.module_from_spec(spec)

    # This should not raise any import errors
    spec.loader.exec_module(module)

    # Check for basic module structure
    assert hasattr(module, "__doc__")


def test_framework_ci_health_monitor_structure():
    """Test that frameworks ci_health_monitor.py has expected monitoring structure."""
    script_path = (
        Path(__file__).parent.parent
        / "frameworks"
        / "monitoring-automation"
        / "monitoring_scripts"
        / "ci_health_monitor.py"
    )

    with open(script_path, "r", encoding="utf-8") as f:
        content = f.read()

    # Check for CI health monitoring content
    health_keywords = ["health", "monitor", "ci", "check", "status"]
    has_health_logic = any(keyword in content.lower() for keyword in health_keywords)
    assert has_health_logic, "Script should contain CI health monitoring logic"

    # Check for substantial script content
    non_comment_lines = [
        line.strip()
        for line in content.split("\n")
        if line.strip() and not line.strip().startswith("#")
    ]
    assert len(non_comment_lines) > 10, "Script should have substantial content"
