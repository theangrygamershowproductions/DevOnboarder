# Enhanced Environment Conditionals - Usage Examples

## 🎯 New Conditional Helpers for Controlled Environments

DevOnboarder now provides sophisticated conditional helpers that make it easy to write environment-specific code, especially for the environments we control (testing, CI, debug).

## 🔧 Available Conditional Helpers

### Core Environment Detection

```python
from utils.environment import (
    is_testing, is_ci, is_debug, is_development, is_production
)
```

### Enhanced Conditional Helpers (NEW)

```python
from utils.environment import (
    is_controlled_environment,      # testing, ci, debug
    is_fast_environment,           # testing, ci (speed optimized)
    is_verbose_environment,        # ci, debug (detailed logging)
    is_isolated_environment,       # testing, ci, debug (SQLite)
    is_ephemeral_environment,      # testing, ci (data doesn't persist)
    allows_dangerous_operations,   # testing, ci, debug (safe to reset)
    requires_production_safety     # development, production (conservative)
)
```

## 💡 Practical Usage Examples

### 1. Database Operations

```python
from utils.environment import allows_dangerous_operations, is_isolated_environment

def reset_database():
    """Reset database - only safe in controlled environments."""
    if allows_dangerous_operations():
        # Safe to drop and recreate database in testing/CI/debug
        drop_all_tables()
        create_fresh_schema()
        print("Database reset completed")
    else:
        raise RuntimeError("Database reset not allowed in this environment")

def get_database_pool_size():
    """Get appropriate database connection pool size."""
    if is_isolated_environment():
        # SQLite environments (testing/CI/debug) - single connection
        return 1
    else:
        # PostgreSQL environments (dev/prod) - multiple connections
        return 10
```

### 2. Caching Strategies

```python
from utils.environment import is_fast_environment, is_ephemeral_environment

def setup_cache():
    """Configure caching based on environment needs."""
    if is_fast_environment():
        # Aggressive caching for testing/CI (speed matters)
        cache_ttl = 3600  # 1 hour
        cache_size = 1000  # Large cache
    elif is_ephemeral_environment():
        # Short-lived cache for testing/CI
        cache_ttl = 300   # 5 minutes
        cache_size = 100  # Small cache
    else:
        # Conservative caching for dev/prod
        cache_ttl = 1800  # 30 minutes
        cache_size = 500  # Medium cache

    return setup_redis_cache(ttl=cache_ttl, max_size=cache_size)
```

### 3. Logging Configuration

```python
from utils.environment import is_verbose_environment, requires_production_safety

def configure_logging():
    """Set up logging appropriate for environment."""
    if is_verbose_environment():
        # Detailed logging for CI/debug
        setup_detailed_logging()
        enable_request_logging()
        enable_database_query_logging()
    elif requires_production_safety():
        # Conservative logging for dev/prod
        setup_error_logging_only()
        enable_security_logging()
    else:
        # Minimal logging for testing
        setup_warning_logging()
```

### 4. Testing and Development Tools

```python
from utils.environment import is_controlled_environment, allows_dangerous_operations

def enable_development_tools():
    """Enable tools only in safe environments."""
    if is_controlled_environment():
        # Safe to enable powerful debugging tools
        enable_api_debugging()
        enable_database_introspection()
        enable_cache_inspection()

        if allows_dangerous_operations():
            # Extra dangerous tools for testing/CI/debug
            enable_data_seeding()
            enable_schema_migration_tools()
            enable_cache_clearing_endpoints()
```

### 5. API Rate Limiting

```python
from utils.environment import requires_production_safety, is_fast_environment

def get_rate_limit():
    """Get appropriate rate limiting based on environment."""
    if requires_production_safety():
        # Conservative limits for dev/production
        return {"requests": 100, "window": 3600}  # 100/hour
    elif is_fast_environment():
        # Relaxed limits for testing/CI (speed matters)
        return {"requests": 10000, "window": 60}  # 10k/minute
    else:
        # Moderate limits for debug
        return {"requests": 1000, "window": 300}  # 1k/5min
```

### 6. Service Initialization

```python
from utils.environment import (
    is_ephemeral_environment,
    is_isolated_environment,
    requires_production_safety
)

def initialize_services():
    """Initialize services appropriate for environment."""
    if is_ephemeral_environment():
        # Testing/CI - use mocks and in-memory services
        setup_mock_email_service()
        setup_in_memory_cache()
        setup_test_discord_client()

    elif is_isolated_environment():
        # Debug - use local services but real implementations
        setup_local_email_service()
        setup_redis_cache()
        setup_debug_discord_client()

    elif requires_production_safety():
        # Dev/Prod - full services with monitoring
        setup_production_email_service()
        setup_monitored_cache()
        setup_production_discord_client()
        enable_health_checks()
```

### 7. Error Handling

```python
from utils.environment import allows_dangerous_operations, requires_production_safety

def handle_critical_error(error):
    """Handle errors appropriately for environment."""
    if allows_dangerous_operations():
        # Testing/CI/Debug - aggressive error recovery
        reset_application_state()
        clear_all_caches()
        reinitialize_services()

    elif requires_production_safety():
        # Dev/Prod - conservative error handling
        log_error_securely(error)
        notify_monitoring_service(error)
        attempt_graceful_recovery()

    else:
        # Fallback - basic error handling
        log_error(error)
```

## 🎯 Quick Decision Matrix

| Condition | Testing | CI | Debug | Development | Production |
|-----------|---------|----|----|-------------|------------|
| `is_controlled_environment()` | ✅ | ✅ | ✅ | ❌ | ❌ |
| `is_fast_environment()` | ✅ | ✅ | ❌ | ❌ | ❌ |
| `is_verbose_environment()` | ❌ | ✅ | ✅ | ❌ | ❌ |
| `is_isolated_environment()` | ✅ | ✅ | ✅ | ❌ | ❌ |
| `is_ephemeral_environment()` | ✅ | ✅ | ❌ | ❌ | ❌ |
| `allows_dangerous_operations()` | ✅ | ✅ | ✅ | ❌ | ❌ |
| `requires_production_safety()` | ❌ | ❌ | ❌ | ✅ | ✅ |

## 🚀 Real-World Integration Example

```python
from utils.environment import (
    is_controlled_environment,
    is_fast_environment,
    allows_dangerous_operations,
    requires_production_safety
)

class DatabaseManager:
    def __init__(self):
        if is_controlled_environment():
            self.pool_size = 1  # SQLite doesn't need pools
            self.timeout = 5    # Fast timeout for tests
        else:
            self.pool_size = 10 # PostgreSQL benefits from pools
            self.timeout = 30   # Longer timeout for real operations

    def reset_schema(self):
        if allows_dangerous_operations():
            # Safe to completely reset in testing/CI/debug
            self.drop_all_tables()
            self.create_schema()
        else:
            raise RuntimeError("Schema reset not allowed in this environment")

    def optimize_for_speed(self):
        if is_fast_environment():
            # Aggressive optimizations for testing/CI
            self.disable_foreign_key_checks()
            self.use_memory_tables()
            self.disable_transaction_logging()
        elif requires_production_safety():
            # Conservative settings for dev/prod
            self.enable_all_constraints()
            self.enable_audit_logging()
            self.enable_backup_on_write()
```

This enhanced conditional system makes it much easier to write environment-aware code that automatically adapts to the specific needs and safety requirements of each environment!
