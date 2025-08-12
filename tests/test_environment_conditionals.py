"""Test enhanced environment conditional helpers."""

from src.utils.environment import (
    Environment,
    allows_dangerous_operations,
    get_environment,
    is_controlled_environment,
    requires_production_safety,
    requires_secure_config,
    is_fast_environment,
    is_verbose_environment,
    is_isolated_environment,
    is_ephemeral_environment,
    get_config_value,
)
import os


def test_allows_dangerous_operations():
    """Test allows_dangerous_operations conditional."""
    # Save original environment
    original_env = os.environ.get("APP_ENV")

    try:
        # Testing, CI, and Debug allow dangerous operations
        os.environ["APP_ENV"] = "testing"
        assert allows_dangerous_operations()

        os.environ["APP_ENV"] = "ci"
        assert allows_dangerous_operations()

        os.environ["APP_ENV"] = "debug"
        assert allows_dangerous_operations()

        # Development and Production do not allow dangerous operations
        os.environ["APP_ENV"] = "development"
        assert not allows_dangerous_operations()

        os.environ["APP_ENV"] = "production"
        assert not allows_dangerous_operations()

    finally:
        # Restore original environment
        if original_env is not None:
            os.environ["APP_ENV"] = original_env
        elif "APP_ENV" in os.environ:
            del os.environ["APP_ENV"]


def test_is_controlled_environment():
    """Test is_controlled_environment conditional."""
    # Save original environment
    original_env = os.environ.get("APP_ENV")

    try:
        # Testing, CI, and Debug are controlled
        os.environ["APP_ENV"] = "testing"
        assert is_controlled_environment()

        os.environ["APP_ENV"] = "ci"
        assert is_controlled_environment()

        os.environ["APP_ENV"] = "debug"
        assert is_controlled_environment()

        # Development and Production are not controlled
        os.environ["APP_ENV"] = "development"
        assert not is_controlled_environment()

        os.environ["APP_ENV"] = "production"
        assert not is_controlled_environment()

    finally:
        # Restore original environment
        if original_env is not None:
            os.environ["APP_ENV"] = original_env
        elif "APP_ENV" in os.environ:
            del os.environ["APP_ENV"]


def test_requires_production_safety():
    """Test requires_production_safety conditional."""
    # Save original environment
    original_env = os.environ.get("APP_ENV")

    try:
        # Development and Production require production safety
        os.environ["APP_ENV"] = "development"
        assert requires_production_safety()

        os.environ["APP_ENV"] = "production"
        assert requires_production_safety()

        # Testing, CI, and Debug don't require production safety
        os.environ["APP_ENV"] = "testing"
        assert not requires_production_safety()

        os.environ["APP_ENV"] = "ci"
        assert not requires_production_safety()

        os.environ["APP_ENV"] = "debug"
        assert not requires_production_safety()

    finally:
        # Restore original environment
        if original_env is not None:
            os.environ["APP_ENV"] = original_env
        elif "APP_ENV" in os.environ:
            del os.environ["APP_ENV"]


def test_requires_secure_config():
    """Test requires_secure_config conditional."""
    # Save original environment
    original_env = os.environ.get("APP_ENV")

    try:
        # Production and CI require secure config
        os.environ["APP_ENV"] = "production"
        assert requires_secure_config()

        os.environ["APP_ENV"] = "ci"
        assert requires_secure_config()

        # Testing, Debug, and Development don't require secure config
        for env in ["testing", "debug", "development"]:
            os.environ["APP_ENV"] = env
            assert not requires_secure_config()

    finally:
        # Restore original environment
        if original_env is not None:
            os.environ["APP_ENV"] = original_env
        elif "APP_ENV" in os.environ:
            del os.environ["APP_ENV"]


def test_environment_edge_cases():
    """Test edge cases for environment detection."""
    # Save original environment
    original_env = os.environ.get("APP_ENV")

    try:
        # Test unknown environment defaults to development
        os.environ["APP_ENV"] = "unknown"
        current_env = get_environment()
        assert current_env == Environment.DEVELOPMENT

        # Test empty environment defaults to development
        os.environ["APP_ENV"] = ""
        current_env = get_environment()
        assert current_env == Environment.DEVELOPMENT

        # Test missing environment defaults to development
        if "APP_ENV" in os.environ:
            del os.environ["APP_ENV"]
        current_env = get_environment()
        assert current_env == Environment.DEVELOPMENT

    finally:
        # Restore original environment
        if original_env is not None:
            os.environ["APP_ENV"] = original_env
        elif "APP_ENV" in os.environ:
            del os.environ["APP_ENV"]


def test_is_fast_environment():
    """Test is_fast_environment conditional for testing/CI optimization."""
    # Save original environment
    original_env = os.environ.get("APP_ENV")

    try:
        # Testing and CI are fast environments
        os.environ["APP_ENV"] = "testing"
        assert is_fast_environment()

        os.environ["APP_ENV"] = "ci"
        assert is_fast_environment()

        # Other environments are not fast
        for env in ["debug", "development", "production"]:
            os.environ["APP_ENV"] = env
            assert not is_fast_environment()

    finally:
        # Restore original environment
        if original_env is not None:
            os.environ["APP_ENV"] = original_env
        elif "APP_ENV" in os.environ:
            del os.environ["APP_ENV"]


def test_is_verbose_environment():
    """Test is_verbose_environment conditional for detailed logging."""
    # Save original environment
    original_env = os.environ.get("APP_ENV")

    try:
        # CI and debug are verbose environments
        os.environ["APP_ENV"] = "ci"
        assert is_verbose_environment()

        os.environ["APP_ENV"] = "debug"
        assert is_verbose_environment()

        # Other environments are not verbose
        for env in ["testing", "development", "production"]:
            os.environ["APP_ENV"] = env
            assert not is_verbose_environment()

    finally:
        # Restore original environment
        if original_env is not None:
            os.environ["APP_ENV"] = original_env
        elif "APP_ENV" in os.environ:
            del os.environ["APP_ENV"]


def test_is_isolated_environment():
    """Test is_isolated_environment conditional for isolated resources."""
    # Save original environment
    original_env = os.environ.get("APP_ENV")

    try:
        # Testing, CI, and debug use isolated resources
        for env in ["testing", "ci", "debug"]:
            os.environ["APP_ENV"] = env
            assert is_isolated_environment()

        # Development and production don't use isolated resources
        for env in ["development", "production"]:
            os.environ["APP_ENV"] = env
            assert not is_isolated_environment()

    finally:
        # Restore original environment
        if original_env is not None:
            os.environ["APP_ENV"] = original_env
        elif "APP_ENV" in os.environ:
            del os.environ["APP_ENV"]


def test_is_ephemeral_environment():
    """Test is_ephemeral_environment conditional for temporary data."""
    # Save original environment
    original_env = os.environ.get("APP_ENV")

    try:
        # Testing and CI are ephemeral environments
        os.environ["APP_ENV"] = "testing"
        assert is_ephemeral_environment()

        os.environ["APP_ENV"] = "ci"
        assert is_ephemeral_environment()

        # Other environments are not ephemeral
        for env in ["debug", "development", "production"]:
            os.environ["APP_ENV"] = env
            assert not is_ephemeral_environment()

    finally:
        # Restore original environment
        if original_env is not None:
            os.environ["APP_ENV"] = original_env
        elif "APP_ENV" in os.environ:
            del os.environ["APP_ENV"]


def test_get_config_value():
    """Test get_config_value function for environment-specific configuration."""
    # Save original environment
    original_env = os.environ.get("APP_ENV")
    original_token = os.environ.get("TOKEN_EXPIRE_SECONDS")
    original_redis = os.environ.get("REDIS_URL")
    original_init = os.environ.get("INIT_DB_ON_STARTUP")

    try:
        # Clean up environment variables for testing
        if "TOKEN_EXPIRE_SECONDS" in os.environ:
            del os.environ["TOKEN_EXPIRE_SECONDS"]
        if "REDIS_URL" in os.environ:
            del os.environ["REDIS_URL"]
        if "INIT_DB_ON_STARTUP" in os.environ:
            del os.environ["INIT_DB_ON_STARTUP"]

        # Test environment-specific defaults
        os.environ["APP_ENV"] = "testing"
        assert get_config_value("TOKEN_EXPIRE_SECONDS", "default") == 60
        assert get_config_value("REDIS_URL", "default") == "redis://localhost:6379/1"
        assert get_config_value("INIT_DB_ON_STARTUP", "default") == "true"

        os.environ["APP_ENV"] = "production"
        assert get_config_value("TOKEN_EXPIRE_SECONDS", "default") == 1800
        assert get_config_value("REDIS_URL", "default") == "redis://redis:6379/0"
        assert get_config_value("INIT_DB_ON_STARTUP", "default") == "false"

        # Test environment variable override
        os.environ["TOKEN_EXPIRE_SECONDS"] = "9999"
        assert get_config_value("TOKEN_EXPIRE_SECONDS", "default") == "9999"

        # Test default fallback for unknown key
        assert get_config_value("UNKNOWN_KEY", "fallback") == "fallback"

    finally:
        # Restore original environment
        if original_env is not None:
            os.environ["APP_ENV"] = original_env
        elif "APP_ENV" in os.environ:
            del os.environ["APP_ENV"]

        if original_token is not None:
            os.environ["TOKEN_EXPIRE_SECONDS"] = original_token
        elif "TOKEN_EXPIRE_SECONDS" in os.environ:
            del os.environ["TOKEN_EXPIRE_SECONDS"]

        if original_redis is not None:
            os.environ["REDIS_URL"] = original_redis
        elif "REDIS_URL" in os.environ:
            del os.environ["REDIS_URL"]

        if original_init is not None:
            os.environ["INIT_DB_ON_STARTUP"] = original_init
        elif "INIT_DB_ON_STARTUP" in os.environ:
            del os.environ["INIT_DB_ON_STARTUP"]
