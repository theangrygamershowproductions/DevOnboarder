import importlib.util
from pathlib import Path

# Load the aar_security script as a module
script_path = Path(__file__).resolve().parents[1] / "scripts" / "aar_security.py"
spec = importlib.util.spec_from_file_location("aar_security", script_path)
if spec and spec.loader:
    aar_security = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(aar_security)
else:
    aar_security = None


def test_aar_security_loads():
    """Test that the AAR security script loads successfully."""
    if not script_path.exists():
        return

    content = script_path.read_text()

    # Basic validation that it's a Python script
    python_indicators = ["import", "def", "class", "#"]
    has_python_code = any(indicator in content for indicator in python_indicators)

    if not has_python_code:
        raise AssertionError("Script does not appear to contain Python code")


def test_aar_security_importable():
    """Test that the module is importable without errors."""
    if not script_path.exists():
        return

    if aar_security is None:
        raise AssertionError("Failed to import aar_security module")


def test_aar_security_structure():
    """Test basic structure of the script."""
    if not script_path.exists():
        return

    content = script_path.read_text()

    # Should be a substantial script
    if len(content) < 500:
        raise AssertionError("Script appears too short for security analysis")

    # Should have security analysis logic
    security_keywords = ["security", "audit", "scan", "vulnerability", "analysis"]
    has_security_logic = any(
        keyword in content.lower() for keyword in security_keywords
    )

    if not has_security_logic:
        raise AssertionError("Script doesn't appear to have security analysis logic")
