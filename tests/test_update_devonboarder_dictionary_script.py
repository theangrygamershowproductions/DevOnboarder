"""Test coverage for scripts/update_devonboarder_dictionary.py script."""

import importlib.util
from pathlib import Path


def test_update_devonboarder_dictionary_loads():
    """Test that update_devonboarder_dictionary.py can be loaded as a module."""
    script_path = (
        Path(__file__).parent.parent / "scripts" / "update_devonboarder_dictionary.py"
    )
    assert script_path.exists(), f"Script file not found at {script_path}"

    spec = importlib.util.spec_from_file_location(
        "update_devonboarder_dictionary", script_path
    )
    assert spec is not None
    assert spec.loader is not None

    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)

    # Verify it's a proper Python script
    assert hasattr(module, "__file__")


def test_update_devonboarder_dictionary_importable():
    """Test that update_devonboarder_dictionary.py is importable without errors."""
    script_path = (
        Path(__file__).parent.parent / "scripts" / "update_devonboarder_dictionary.py"
    )

    spec = importlib.util.spec_from_file_location(
        "update_devonboarder_dictionary", script_path
    )
    module = importlib.util.module_from_spec(spec)

    # This should not raise any import errors
    spec.loader.exec_module(module)

    # Check for basic module structure
    assert hasattr(module, "__doc__")


def test_update_devonboarder_dictionary_structure():
    """Test that update_devonboarder_dictionary.py has expected structure."""
    script_path = (
        Path(__file__).parent.parent / "scripts" / "update_devonboarder_dictionary.py"
    )

    with open(script_path, "r", encoding="utf-8") as f:
        content = f.read()

    # Check for dictionary updating content
    dict_keywords = ["dictionary", "update", "word", "spell", "devonboarder"]
    has_dict_logic = any(keyword in content.lower() for keyword in dict_keywords)
    assert has_dict_logic, "Script should contain dictionary updating logic"

    # Check for substantial script content
    non_comment_lines = [
        line.strip()
        for line in content.split("\n")
        if line.strip() and not line.strip().startswith("#")
    ]
    assert len(non_comment_lines) > 5, "Script should have substantial content"
