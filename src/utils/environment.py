"""Environment configuration management for DevOnboarder.

This module provides centralized environment detection and configuration
for all DevOnboarder services across multiple deployment environments.

Supported environments:
- TESTING: Unit tests and automated testing
- CI: Continuous integration pipelines
- DEBUG: Development with verbose logging
- DEV (Development): Local development
- PROD (Production): Production deployment
"""

from __future__ import annotations

import os
from enum import Enum
from typing import Any


class Environment(Enum):
    """Supported DevOnboarder environments."""

    TESTING = "testing"
    CI = "ci"
    DEBUG = "debug"
    DEVELOPMENT = "development"
    PRODUCTION = "production"

    @classmethod
    def current(cls) -> Environment:
        """Get the current environment from APP_ENV variable."""
        app_env = os.getenv("APP_ENV", "development").lower()
        # Map common variations to standard names
        env_mapping = {
            "test": cls.TESTING,
            "testing": cls.TESTING,
            "ci": cls.CI,
            "debug": cls.DEBUG,
            "dev": cls.DEVELOPMENT,
            "development": cls.DEVELOPMENT,
            "prod": cls.PRODUCTION,
            "production": cls.PRODUCTION,
        }

        return env_mapping.get(app_env, cls.DEVELOPMENT)

    @property
    def is_testing(self) -> bool:
        """Check if current environment is testing."""
        return self == Environment.TESTING

    @property
    def is_ci(self) -> bool:
        """Check if current environment is CI."""
        return self == Environment.CI

    @property
    def is_debug(self) -> bool:
        """Check if current environment is debug."""
        return self == Environment.DEBUG

    @property
    def is_development(self) -> bool:
        """Check if current environment is development."""
        return self == Environment.DEVELOPMENT

    @property
    def is_production(self) -> bool:
        """Check if current environment is production."""
        return self == Environment.PRODUCTION

    @property
    def requires_secure_config(self) -> bool:
        """Check if environment requires secure configuration."""
        return self in (Environment.PRODUCTION, Environment.CI)

    @property
    def allows_debug_logging(self) -> bool:
        """Check if environment allows debug logging."""
        return self in (Environment.DEBUG, Environment.TESTING, Environment.DEVELOPMENT)

    @property
    def database_url_pattern(self) -> str:
        """Get the expected database URL pattern for this environment."""
        patterns = {
            Environment.TESTING: "sqlite:///./test_devonboarder.db",
            Environment.CI: "sqlite:///./test_devonboarder.db",
            Environment.DEBUG: "sqlite:///./debug_devonboarder.db",
            Environment.DEVELOPMENT: (
                "postgresql://devuser:devpass@db:5432/devonboarder_dev"
            ),
            Environment.PRODUCTION: (
                "postgresql://produser:***@db:5432/devonboarder_prod"
            ),
        }
        return patterns[self]

    @property
    def cors_origins(self) -> list[str]:
        """Get CORS origins for this environment."""
        if self.is_development or self.is_debug or self.is_testing:
            return ["*"]
        elif self.is_ci:
            return [
                "http://localhost",
                "http://localhost:3000",
                "http://localhost:8001",
                "http://localhost:8002",
                "http://localhost:8003",
                "http://localhost:8081",
            ]
        else:  # Production
            return [
                "https://dev.theangrygamershow.com",
                "https://auth.theangrygamershow.com",
                "https://api.theangrygamershow.com",
                "https://discord.theangrygamershow.com",
                "https://dashboard.theangrygamershow.com",
            ]

    @property
    def log_level(self) -> str:
        """Get logging level for this environment."""
        levels = {
            Environment.TESTING: "WARNING",
            Environment.CI: "INFO",
            Environment.DEBUG: "DEBUG",
            Environment.DEVELOPMENT: "INFO",
            Environment.PRODUCTION: "ERROR",
        }
        return levels[self]


def get_environment() -> Environment:
    """Get the current environment."""
    return Environment.current()


def is_testing() -> bool:
    """Check if running in testing environment."""
    return get_environment().is_testing


def is_ci() -> bool:
    """Check if running in CI environment."""
    return get_environment().is_ci or os.getenv("CI", "").lower() == "true"


def is_debug() -> bool:
    """Check if running in debug environment."""
    return get_environment().is_debug or os.getenv("DEBUG", "").lower() == "true"


def is_development() -> bool:
    """Check if running in development environment."""
    return get_environment().is_development


def is_production() -> bool:
    """Check if running in production environment."""
    return get_environment().is_production


def requires_secure_config() -> bool:
    """Check if current environment requires secure configuration."""
    return get_environment().requires_secure_config


# Enhanced conditional helpers for controlled environments
def is_controlled_environment() -> bool:
    """Check if running in an environment we fully control.

    Returns True for testing, CI, and debug environments where we have
    complete control over configuration and can use aggressive optimizations.
    """
    env = get_environment()
    return env.is_testing or env.is_ci or env.is_debug


def is_fast_environment() -> bool:
    """Check if environment is optimized for speed (testing/CI).

    Use this for enabling aggressive caching, shorter timeouts, or
    simplified logic in environments where speed matters most.
    """
    env = get_environment()
    return env.is_testing or env.is_ci


def is_verbose_environment() -> bool:
    """Check if environment should have verbose logging (CI/debug).

    Use this to enable detailed logging, debug output, or additional
    monitoring in environments where visibility is important.
    """
    env = get_environment()
    return env.is_ci or env.is_debug


def is_isolated_environment() -> bool:
    """Check if environment uses isolated resources (testing/CI/debug).

    Returns True for environments that use SQLite databases and isolated
    Redis instances. Use this for cleanup logic or resource management.
    """
    env = get_environment()
    return env.is_testing or env.is_ci or env.is_debug


def is_ephemeral_environment() -> bool:
    """Check if environment is ephemeral (testing/CI).

    Use this for environments where data doesn't need to persist
    between runs. Enables aggressive cleanup and reset strategies.
    """
    env = get_environment()
    return env.is_testing or env.is_ci


def allows_dangerous_operations() -> bool:
    """Check if environment allows potentially dangerous operations.

    Returns True for controlled environments where it's safe to:
    - Drop and recreate databases
    - Clear all caches
    - Reset application state
    - Use mock services
    """
    env = get_environment()
    return env.is_testing or env.is_ci or env.is_debug


def requires_production_safety() -> bool:
    """Check if environment requires production-level safety measures.

    Use this to enable:
    - Conservative timeouts
    - Data validation
    - Rate limiting
    - Secure defaults
    """
    env = get_environment()
    return env.is_development or env.is_production


def get_database_url(override: str | None = None) -> str:
    """Get database URL for current environment.

    Args:
        override: Optional URL to use instead of environment default

    Returns:
        Database URL appropriate for current environment
    """
    if override:
        return override

    env_url = os.getenv("DATABASE_URL")
    if env_url:
        return env_url

    return get_environment().database_url_pattern


def get_cors_origins() -> list[str]:
    """Get CORS origins for current environment.

    Returns:
        List of allowed CORS origins
    """
    # Check for explicit CORS configuration first
    origins = os.getenv("CORS_ALLOW_ORIGINS")
    if origins:
        return [o.strip() for o in origins.split(",") if o.strip()]

    # Use environment-specific defaults
    return get_environment().cors_origins


def get_log_level() -> str:
    """Get log level for current environment."""
    return get_environment().log_level


def get_config_value(key: str, default: Any = None) -> Any:
    """Get configuration value with environment-aware defaults.

    Args:
        key: Configuration key name
        default: Default value if not found

    Returns:
        Configuration value
    """
    env = get_environment()

    # Environment-specific configuration
    env_defaults: dict[str, dict[Environment, Any]] = {
        "TOKEN_EXPIRE_SECONDS": {
            Environment.TESTING: 60,  # Short for tests
            Environment.CI: 300,  # 5 minutes for CI
            Environment.DEBUG: 3600,  # 1 hour for debugging
            Environment.DEVELOPMENT: 3600,  # 1 hour for dev
            Environment.PRODUCTION: 1800,  # 30 minutes for prod
        },
        "REDIS_URL": {
            Environment.TESTING: "redis://localhost:6379/1",
            Environment.CI: "redis://localhost:6379/2",
            Environment.DEBUG: "redis://localhost:6379/3",
            Environment.DEVELOPMENT: "redis://localhost:6379/0",
            Environment.PRODUCTION: "redis://redis:6379/0",
        },
        "INIT_DB_ON_STARTUP": {
            Environment.TESTING: "true",
            Environment.CI: "true",
            Environment.DEBUG: "true",
            Environment.DEVELOPMENT: "true",
            Environment.PRODUCTION: "false",
        },
    }

    # Try environment variable first
    env_value = os.getenv(key)
    if env_value is not None:
        return env_value

    # Try environment-specific default
    if key in env_defaults and env in env_defaults[key]:
        return env_defaults[key][env]

    # Return provided default
    return default


# Export commonly used functions
__all__ = [
    "Environment",
    "get_environment",
    "is_testing",
    "is_ci",
    "is_debug",
    "is_development",
    "is_production",
    "requires_secure_config",
    # Enhanced conditional helpers for controlled environments
    "is_controlled_environment",
    "is_fast_environment",
    "is_verbose_environment",
    "is_isolated_environment",
    "is_ephemeral_environment",
    "allows_dangerous_operations",
    "requires_production_safety",
    # Configuration functions
    "get_database_url",
    "get_cors_origins",
    "get_log_level",
    "get_config_value",
]
