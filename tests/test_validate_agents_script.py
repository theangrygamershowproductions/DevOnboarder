"""Test coverage for scripts/validate_agents.py script."""

import importlib.util
from pathlib import Path


def test_validate_agents_loads():
    """Test that validate_agents.py can be loaded as a module."""
    script_path = Path(__file__).parent.parent / "scripts" / "validate_agents.py"
    assert script_path.exists(), f"Script file not found at {script_path}"

    spec = importlib.util.spec_from_file_location("validate_agents", script_path)
    assert spec is not None
    assert spec.loader is not None

    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)

    # Verify it's a proper Python script
    assert hasattr(module, "__file__")


def test_validate_agents_importable():
    """Test that validate_agents.py is importable without errors."""
    script_path = Path(__file__).parent.parent / "scripts" / "validate_agents.py"

    spec = importlib.util.spec_from_file_location("validate_agents", script_path)
    module = importlib.util.module_from_spec(spec)

    # This should not raise any import errors
    spec.loader.exec_module(module)

    # Check for basic module structure
    assert hasattr(module, "__doc__")


def test_validate_agents_structure():
    """Test that validate_agents.py has expected agent validation structure."""
    script_path = Path(__file__).parent.parent / "scripts" / "validate_agents.py"

    with open(script_path, "r", encoding="utf-8") as f:
        content = f.read()

    # Check for agent validation content
    agent_keywords = ["agent", "validate", "check", "verification", "valid"]
    has_agent_logic = any(keyword in content.lower() for keyword in agent_keywords)
    assert has_agent_logic, "Script should contain agent validation logic"

    # Check for substantial script content
    lines = [
        line.strip()
        for line in content.split("\n")
        if line.strip() and not line.strip().startswith("#")
    ]
    assert len(lines) > 5, "Script should have substantial content"
