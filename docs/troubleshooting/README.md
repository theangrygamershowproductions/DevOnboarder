# Troubleshooting Documentation

This directory contains troubleshooting guides for common DevOnboarder issues.

## Quick Reference

### Container Health Issues

- **[Discord Bot Health Check Fix](DISCORD_BOT_HEALTH_CHECK_FIX.md)** - Quick fix for "unhealthy" bot containers
- **[Docker Container Health Troubleshooting](DOCKER_CONTAINER_HEALTH_TROUBLESHOOTING.md)** - Comprehensive container health debugging
- **[Centralized Logging Permissions](CENTRALIZED_LOGGING_PERMISSIONS.md)** - Container permissions for centralized logging

### CI/CD Issues

- **[CI MyPy Type Stubs](CI_MYPY_TYPE_STUBS.md)** - MyPy passes locally but fails in CI due to missing type stubs
- **[Automerge Hanging Indefinitely](AUTOMERGE_HANGING_INDEFINITELY.md)** - CRITICAL: Repository configuration issues blocking all PR merges

### Common Problems

| Problem | Quick Fix | Documentation |
|---------|-----------|---------------|
| Bot container shows "unhealthy" | [Health Check Fix](DISCORD_BOT_HEALTH_CHECK_FIX.md) | Custom health check script |
| Permission denied errors | `sudo chown 1001:1001 logs/bot/` | [Centralized Logging Permissions](CENTRALIZED_LOGGING_PERMISSIONS.md) |
| MyPy passes locally but fails in CI | Add `types-*` to `pyproject.toml` | [CI MyPy Type Stubs](CI_MYPY_TYPE_STUBS.md) |
| **Automerge hangs indefinitely** | **Check default branch + status names** | **[Automerge Hanging Guide](AUTOMERGE_HANGING_INDEFINITELY.md)** |
| TypeScript compilation fails | Fix file permissions with container UID | [Permission Section](DOCKER_CONTAINER_HEALTH_TROUBLESHOOTING.md#issue-2-file-permission-mismatches-with-volume-mounts) |
| Health check scripts fail | Use ES module syntax (`import` not `require`) | [ES Module Section](DOCKER_CONTAINER_HEALTH_TROUBLESHOOTING.md#issue-3-es-module-vs-commonjs-syntax) |

### Need Help?

If your issue isn't covered here:

1. Check the [main documentation](../README.md)
2. Search [GitHub Issues](https://github.com/theangrygamershowproductions/DevOnboarder/issues)
3. Create a new issue with detailed information

## Contributing

When adding new troubleshooting documentation:

1. Create focused, solution-oriented guides
2. Include both quick fixes and comprehensive explanations
3. Use clear symptoms and step-by-step solutions
4. Test all provided commands and code examples
5. Update this index with the new documentation
