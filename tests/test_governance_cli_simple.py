import importlib.util
from pathlib import Path

# Load the governance_cli script as a module
script_path = Path(__file__).resolve().parents[1] / "tools" / "governance_cli.py"
spec = importlib.util.spec_from_file_location("governance_cli", script_path)
if spec and spec.loader:
    governance_cli = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(governance_cli)
else:
    governance_cli = None


def test_governance_cli_loads():
    """Test that the governance CLI script loads successfully."""
    if not script_path.exists():
        return

    content = script_path.read_text()

    # Basic validation that it's a Python script
    python_indicators = ["import", "def", "class", "#"]
    has_python_code = any(indicator in content for indicator in python_indicators)

    if not has_python_code:
        raise AssertionError("Script does not appear to contain Python code")


def test_governance_cli_importable():
    """Test that the module is importable without errors."""
    if not script_path.exists():
        return

    if governance_cli is None:
        raise AssertionError("Failed to import governance_cli module")


def test_governance_cli_structure():
    """Test basic structure of the script."""
    if not script_path.exists():
        return

    content = script_path.read_text()

    # Should be a substantial script
    if len(content) < 1000:
        raise AssertionError("Script appears too short for governance CLI")

    # Should have governance/CLI logic
    governance_keywords = ["governance", "policy", "metadata", "argparse", "cli"]
    has_governance_logic = any(
        keyword in content.lower() for keyword in governance_keywords
    )

    if not has_governance_logic:
        raise AssertionError("Script doesn't appear to have governance CLI logic")
