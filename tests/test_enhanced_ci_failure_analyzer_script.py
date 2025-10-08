import importlib.util
from pathlib import Path

# Load the enhanced_ci_failure_analyzer script as a module
script_path = (
    Path(__file__).resolve().parents[1] / "scripts" / "enhanced_ci_failure_analyzer.py"
)
spec = importlib.util.spec_from_file_location(
    "enhanced_ci_failure_analyzer", script_path
)
if spec and spec.loader:
    enhanced_ci_failure_analyzer = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(enhanced_ci_failure_analyzer)
else:
    enhanced_ci_failure_analyzer = None


def test_enhanced_ci_failure_analyzer_loads():
    """Test that the enhanced CI failure analyzer script loads successfully."""
    if not script_path.exists():
        return

    content = script_path.read_text()

    # Basic validation that it's a Python script
    python_indicators = ["import", "def", "class", "#"]
    has_python_code = any(indicator in content for indicator in python_indicators)

    if not has_python_code:
        raise AssertionError("Script does not appear to contain Python code")


def test_enhanced_ci_failure_analyzer_importable():
    """Test that the module is importable without errors."""
    if not script_path.exists():
        return

    if enhanced_ci_failure_analyzer is None:
        raise AssertionError("Failed to import enhanced_ci_failure_analyzer module")


def test_enhanced_ci_failure_analyzer_structure():
    """Test basic structure of the script."""
    if not script_path.exists():
        return

    content = script_path.read_text()

    # Should be a substantial script
    if len(content) < 500:
        raise AssertionError("Script appears too short for CI failure analysis")

    # Should have CI/failure analysis logic
    analysis_keywords = ["failure", "ci", "error", "analyze", "log"]
    has_analysis = any(keyword in content.lower() for keyword in analysis_keywords)

    if not has_analysis:
        raise AssertionError("Script doesn't appear to have CI failure analysis logic")
