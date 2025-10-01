#!/bin/bash
# Ensure logs directory structure for centralized cache management
# This script is called by CI and local development to ensure proper directory structure

set -e

echo "Setting up logs directory structure for centralized cache management"

# Create logs directory and subdirectories
mkdir -p logs
mkdir -p logs/.pytest_cache
mkdir -p logs/.mypy_cache
mkdir -p logs/htmlcov

# Ensure logs directory is writable
chmod -R 755 logs

echo "Logs directory structure ready:"
echo "  logs/.pytest_cache - Pytest cache"
echo "  logs/.mypy_cache - MyPy cache"
echo "  logs/htmlcov - Coverage HTML reports"
echo "  logs/ - General logs and coverage files"

# List the structure for verification
ls -la logs/ 2>/dev/null || echo "Directory structure created successfully"
