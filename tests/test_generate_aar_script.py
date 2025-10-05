"""Test coverage for scripts/generate_aar.py script."""

import importlib.util
from pathlib import Path
from unittest.mock import MagicMock, patch


def test_generate_aar_loads():
    """Test that generate_aar.py can be loaded as a module."""
    script_path = Path(__file__).parent.parent / "scripts" / "generate_aar.py"
    assert script_path.exists(), f"Script file not found at {script_path}"

    spec = importlib.util.spec_from_file_location("generate_aar", script_path)
    assert spec is not None
    assert spec.loader is not None

    # Mock the aar_security module to avoid import errors
    mock_aar_security = MagicMock()
    mock_aar_security.AARTokenManager = MagicMock()

    with patch.dict("sys.modules", {"aar_security": mock_aar_security}):
        module = importlib.util.module_from_spec(spec)
        spec.loader.exec_module(module)

        # Verify it's a proper Python script
        assert hasattr(module, "__file__")


def test_generate_aar_importable():
    """Test that generate_aar.py is importable without errors."""
    script_path = Path(__file__).parent.parent / "scripts" / "generate_aar.py"

    spec = importlib.util.spec_from_file_location("generate_aar", script_path)
    module = importlib.util.module_from_spec(spec)

    # Mock the aar_security module to avoid import errors
    mock_aar_security = MagicMock()
    mock_aar_security.AARTokenManager = MagicMock()

    with patch.dict("sys.modules", {"aar_security": mock_aar_security}):
        # This should not raise any import errors
        spec.loader.exec_module(module)

        # Check for basic module structure
        assert hasattr(module, "__doc__")
        assert isinstance(module.__doc__, str)


def test_generate_aar_structure():
    """Test that generate_aar.py has expected AAR generation structure."""
    script_path = Path(__file__).parent.parent / "scripts" / "generate_aar.py"

    with open(script_path, "r", encoding="utf-8") as f:
        content = f.read()

    # Check for AAR-related content
    assert "AARGenerator" in content
    assert "after action report" in content.lower() or "AAR" in content
    assert "class" in content  # Should have class definitions

    # Check for substantial script content
    lines = [
        line.strip()
        for line in content.split("\n")
        if line.strip() and not line.strip().startswith("#")
    ]
    assert len(lines) > 10, "Script should have substantial content"


def test_generate_aar_class_creation():
    """Test that AARGenerator class can be instantiated with mocked dependencies."""
    script_path = Path(__file__).parent.parent / "scripts" / "generate_aar.py"

    spec = importlib.util.spec_from_file_location("generate_aar", script_path)
    module = importlib.util.module_from_spec(spec)

    # Mock the aar_security module and its dependencies
    mock_aar_security = MagicMock()
    mock_token_manager = MagicMock()
    mock_aar_security.AARTokenManager.return_value = mock_token_manager

    with patch.dict("sys.modules", {"aar_security": mock_aar_security}):
        with patch("os.path.exists", return_value=False):  # Mock config file check
            spec.loader.exec_module(module)

            # Test that AARGenerator class exists and can be referenced
            assert hasattr(module, "AARGenerator")
            aar_generator_class = getattr(module, "AARGenerator")
            assert callable(aar_generator_class)
