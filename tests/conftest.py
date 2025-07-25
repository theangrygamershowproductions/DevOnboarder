from pathlib import Path
import pytest


@pytest.fixture(autouse=True)
def cleanup_dependency_inventory():
    """Remove dependency_inventory.xlsx created during tests."""
    yield
    path = Path("dependency_inventory.xlsx")
    if path.exists():
        path.unlink()
