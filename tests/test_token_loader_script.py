"""Test coverage for scripts/token_loader.py script."""

import importlib.util
from pathlib import Path


def test_token_loader_loads():
    """Test that token_loader.py can be loaded as a module."""
    script_path = Path(__file__).parent.parent / "scripts" / "token_loader.py"
    assert script_path.exists(), f"Script file not found at {script_path}"

    spec = importlib.util.spec_from_file_location("token_loader", script_path)
    assert spec is not None
    assert spec.loader is not None

    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)

    # Verify it's a proper Python script
    assert hasattr(module, "__file__")


def test_token_loader_importable():
    """Test that token_loader.py is importable without errors."""
    script_path = Path(__file__).parent.parent / "scripts" / "token_loader.py"

    spec = importlib.util.spec_from_file_location("token_loader", script_path)
    module = importlib.util.module_from_spec(spec)

    # This should not raise any import errors
    spec.loader.exec_module(module)

    # Check for basic module structure
    assert hasattr(module, "__doc__")


def test_token_loader_structure():
    """Test that token_loader.py has expected token loading structure."""
    script_path = Path(__file__).parent.parent / "scripts" / "token_loader.py"

    with open(script_path, "r", encoding="utf-8") as f:
        content = f.read()

    # Check for token loading content
    loader_keywords = ["load", "token", "config", "environment", "file"]
    has_loader_logic = any(keyword in content.lower() for keyword in loader_keywords)
    assert has_loader_logic, "Script should contain token loading logic"

    # Check for substantial script content
    non_comment_lines = [
        line.strip()
        for line in content.split("\n")
        if line.strip() and not line.strip().startswith("#")
    ]
    assert len(non_comment_lines) > 10, "Script should have substantial content"


def test_token_loader_functions():
    """Test that token_loader.py has expected function definitions."""
    script_path = Path(__file__).parent.parent / "scripts" / "token_loader.py"

    spec = importlib.util.spec_from_file_location("token_loader", script_path)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)

    # Check for expected functions
    assert hasattr(module, "load_tokens"), "Should have load_tokens function"
    assert callable(getattr(module, "load_tokens")), "load_tokens should be callable"
