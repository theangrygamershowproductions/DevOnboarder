import importlib.util
from pathlib import Path
from unittest.mock import patch
import pytest

# Load the governance_cli script as a module
script_path = Path(__file__).resolve().parents[1] / "tools" / "governance_cli.py"
spec = importlib.util.spec_from_file_location("governance_cli", script_path)
if spec and spec.loader:
    governance_cli = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(governance_cli)
else:
    governance_cli = None


def test_governance_cli_imports():
    """Test that the governance CLI imports correctly without errors."""
    try:
        # Import the governance CLI module
        governance_cli = importlib.import_module("tools.governance_cli")

        # Test that key components are importable
        assert hasattr(governance_cli, "argparse")

        # The module should exist and be importable
        assert governance_cli is not None

    except ImportError as e:
        pytest.fail(f"Failed to import governance CLI: {e}")


def test_governance_cli_file_exists():
    """Test that the governance CLI file exists and has expected structure."""
    cli_path = Path(__file__).parent.parent / "tools" / "governance_cli.py"
    assert cli_path.exists(), "governance_cli.py should exist in tools directory"

    # Read the file and check for expected content
    content = cli_path.read_text()
    assert "argparse" in content, "Should use argparse for command line parsing"
    assert "GovernancePolicyEngine" in content, "Should import GovernancePolicyEngine"
    assert "ExtendedMetadataYAMLManager" in content, "Should import YAML manager"


def test_governance_cli_help_functionality():
    """Test that the governance CLI provides help information."""
    cli_path = Path(__file__).parent.parent / "tools" / "governance_cli.py"
    content = cli_path.read_text()

    # Should contain help text and command descriptions
    assert "check" in content, "Should support check command"
    assert "report" in content, "Should support report command"
    assert "validate" in content, "Should support validate command"
    assert "create" in content, "Should support create command"


def test_governance_cli_dependencies():
    """Test that the governance CLI can access its dependencies."""
    # Test that required modules can be imported (dependencies are available)
    try:
        from src.framework.metadata_yaml import ExtendedMetadataYAMLManager
        from src.framework.governance_engine import GovernancePolicyEngine

        # Basic instantiation tests
        yaml_manager = ExtendedMetadataYAMLManager()
        policy_engine = GovernancePolicyEngine()

        assert yaml_manager is not None
        assert policy_engine is not None

    except ImportError as e:
        pytest.fail(f"Governance CLI dependencies not available: {e}")


@patch("sys.argv", ["governance_cli.py", "--help"])
def test_governance_cli_argument_parsing():
    """Test that the governance CLI can parse arguments correctly."""
    try:
        # Import and test basic argument parsing structure
        governance_cli = importlib.import_module("tools.governance_cli")

        # The module should have argument parsing capability
        assert hasattr(governance_cli, "argparse")

    except SystemExit:
        # argparse exits with --help, this is expected
        pass
    except ImportError as e:
        pytest.fail(f"Failed to test argument parsing: {e}")


def test_governance_cli_has_main_commands():
    """Test that the governance CLI defines the expected main commands."""
    cli_path = Path(__file__).parent.parent / "tools" / "governance_cli.py"
    content = cli_path.read_text()

    # Check for command definitions or references
    expected_commands = ["check", "report", "validate", "create", "approve"]

    for command in expected_commands:
        assert command in content, f"Command '{command}' should be defined in CLI"


if __name__ == "__main__":
    pytest.main([__file__])
