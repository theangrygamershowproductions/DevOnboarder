import os
import tempfile
from pathlib import Path

import pytest
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker

# Set up test environment variables before importing auth_service
os.environ.setdefault("APP_ENV", "development")
os.environ.setdefault("JWT_SECRET_KEY", "test-secret-key-for-testing")
# Use logs directory for test database to avoid root pollution
os.environ.setdefault("DATABASE_URL", "sqlite:///logs/test.db")
os.environ.setdefault("DISCORD_TOKEN", "test-discord-token")
os.environ.setdefault("DISCORD_GUILD_ID", "12345")

from devonboarder import auth_service  # noqa: E402


@pytest.fixture(autouse=True, scope="function")
def setup_test_database():
    """Set up clean database for each test."""
    # Set required environment variables for auth_service before any imports
    import os
    import sys

    # Add src directory to Python path
    src_path = os.path.join(os.path.dirname(os.path.dirname(__file__)), "src")
    if src_path not in sys.path:
        sys.path.insert(0, src_path)

    os.environ.setdefault("JWT_SECRET_KEY", "test-jwt-secret-for-testing")
    os.environ.setdefault("DATABASE_URL", "sqlite:///test_devonboarder.db")

    # Create temporary database file
    db_fd, db_path = tempfile.mkstemp(suffix=".db")
    os.close(db_fd)

    # Configure test database URL
    test_db_url = f"sqlite:///{db_path}"

    # Update auth_service database configuration
    auth_service.engine = create_engine(test_db_url, echo=False)
    auth_service.SessionLocal = sessionmaker(
        autocommit=False, autoflush=False, bind=auth_service.engine
    )

    # Clear any existing metadata to avoid conflicts
    auth_service.Base.metadata.clear()

    # Re-import all models to register them with the cleared metadata
    # This ensures fresh registration for each test
    import importlib

    # Force reload of modules to re-register models
    modules_to_reload = [
        "devonboarder.auth_service",
        "src.feedback_service.api",
        "src.xp.api",
    ]

    for module_name in modules_to_reload:
        if module_name in sys.modules:
            importlib.reload(sys.modules[module_name])

    # Import feedback model to ensure it's registered
    try:
        from src.feedback_service.api import Feedback  # noqa: F401
    except ImportError:
        # Skip feedback model import if src package not available
        pass

    # Create all tables after models are re-registered
    auth_service.Base.metadata.create_all(bind=auth_service.engine)

    # Initialize database (this might create initial data)
    auth_service.init_db()

    yield

    # Cleanup: close all connections and remove temporary database
    auth_service.engine.dispose()
    try:
        os.unlink(db_path)
    except FileNotFoundError:
        pass
        pass


@pytest.fixture(autouse=True)
def cleanup_dependency_inventory():
    """Remove dependency_inventory.xlsx created during tests."""
    yield
    path = Path("dependency_inventory.xlsx")
    if path.exists():
        path.unlink()
