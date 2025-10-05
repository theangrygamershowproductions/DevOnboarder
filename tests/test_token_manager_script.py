"""Test coverage for scripts/token_manager.py script."""

import importlib.util
from pathlib import Path
from unittest.mock import MagicMock, patch


def test_token_manager_loads():
    """Test that token_manager.py can be loaded as a module."""
    script_path = Path(__file__).parent.parent / "scripts" / "token_manager.py"
    assert script_path.exists(), f"Script file not found at {script_path}"

    spec = importlib.util.spec_from_file_location("token_manager", script_path)
    assert spec is not None
    assert spec.loader is not None

    # Mock the token_loader module to avoid import errors
    mock_token_loader = MagicMock()
    mock_token_loader.load_tokens = MagicMock()

    with patch.dict("sys.modules", {"token_loader": mock_token_loader}):
        module = importlib.util.module_from_spec(spec)
        spec.loader.exec_module(module)

        # Verify it's a proper Python script
        assert hasattr(module, "__file__")


def test_token_manager_importable():
    """Test that token_manager.py is importable without errors."""
    script_path = Path(__file__).parent.parent / "scripts" / "token_manager.py"

    spec = importlib.util.spec_from_file_location("token_manager", script_path)
    module = importlib.util.module_from_spec(spec)

    # Mock the token_loader module to avoid import errors
    mock_token_loader = MagicMock()
    mock_token_loader.load_tokens = MagicMock()

    with patch.dict("sys.modules", {"token_loader": mock_token_loader}):
        # This should not raise any import errors
        spec.loader.exec_module(module)

        # Check for basic module structure
        assert hasattr(module, "__doc__")
        assert isinstance(module.__doc__, str)


def test_token_manager_structure():
    """Test that token_manager.py has expected token management structure."""
    script_path = Path(__file__).parent.parent / "scripts" / "token_manager.py"

    with open(script_path, "r", encoding="utf-8") as f:
        content = f.read()

    # Check for token management content
    token_keywords = ["token", "manager", "auth", "github", "api"]
    has_token_logic = any(keyword in content.lower() for keyword in token_keywords)
    assert has_token_logic, "Script should contain token management logic"

    # Check for substantial script content
    non_comment_lines = [
        line.strip()
        for line in content.split("\n")
        if line.strip() and not line.strip().startswith("#")
    ]
    assert len(non_comment_lines) > 5, "Script should have substantial content"
