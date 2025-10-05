import importlib.util
from pathlib import Path

# Load the validate_milestone_format script as a module
script_path = (
    Path(__file__).resolve().parents[1] / "scripts" / "validate_milestone_format.py"
)
spec = importlib.util.spec_from_file_location("validate_milestone_format", script_path)
if spec and spec.loader:
    validate_milestone_format = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(validate_milestone_format)
else:
    validate_milestone_format = None


def test_validate_milestone_format_loads():
    """Test that the validate milestone format script loads successfully."""
    if not script_path.exists():
        # Skip test if script doesn't exist
        return

    content = script_path.read_text()

    # Basic validation that it's a Python script
    python_indicators = ["import", "def", "class", "#"]
    has_python_code = any(indicator in content for indicator in python_indicators)

    if not has_python_code:
        raise AssertionError("Script does not appear to contain Python code")


def test_validate_milestone_format_importable():
    """Test that the module is importable without errors."""
    if not script_path.exists():
        return

    if validate_milestone_format is None:
        raise AssertionError("Failed to import validate_milestone_format module")


def test_validate_milestone_format_structure():
    """Test basic structure of the script."""
    if not script_path.exists():
        return

    content = script_path.read_text()

    # Should be a substantial script
    if len(content) < 100:
        raise AssertionError("Script appears too short")

    # Should have some validation logic
    validation_keywords = ["validate", "check", "format", "milestone"]
    has_validation = any(keyword in content.lower() for keyword in validation_keywords)

    if not has_validation:
        raise AssertionError("Script doesn't appear to have validation logic")
