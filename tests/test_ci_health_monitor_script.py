import importlib.util
from pathlib import Path

# Load the ci_health_monitor script as a module
spec = importlib.util.spec_from_file_location(
    "ci_health_monitor",
    Path(__file__).resolve().parents[1] / "scripts" / "ci_health_monitor.py",
)
ci_health_monitor = importlib.util.module_from_spec(spec)
spec.loader.exec_module(ci_health_monitor)


def test_ci_health_monitor_loads():
    """Test that the CI health monitor module loads successfully."""
    script_path = (
        Path(__file__).resolve().parents[1] / "scripts" / "ci_health_monitor.py"
    )
    content = script_path.read_text()

    # Basic validation that it's a Python script
    python_indicators = ["import", "def", "class", "#"]
    has_python_code = any(indicator in content for indicator in python_indicators)

    if not has_python_code:
        raise AssertionError("Script does not appear to contain Python code")

    if len(content) < 50:
        raise AssertionError("Script is too short to be meaningful")


def test_ci_health_monitor_importable():
    """Test that the module is importable without errors."""
    if ci_health_monitor is None:
        raise AssertionError("Failed to import ci_health_monitor module")
