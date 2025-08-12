# Environment Configuration Quick Start Guide

## 🎯 Quick Setup

DevOnboarder supports 5 environment modes. To switch environments:

### 1. Edit your `.env` file

```bash
# Open .env file and change this line:
APP_ENV=development  # Change to any of: testing, ci, debug, development, production
```

### 2. Restart services to pick up changes

```bash
# If using Docker
docker compose down && docker compose up -d

# If running directly
# Restart your Python/Node services
```

## 🏗️ Environment Modes

### `testing` - For Unit Tests

- **Database**: SQLite (fast, isolated)
- **Tokens**: 60 second expiration (rapid testing)
- **Logging**: WARNING level (minimal noise)
- **CORS**: Wildcard (test flexibility)

### `ci` - For CI Pipelines

- **Database**: SQLite (CI-friendly)
- **Tokens**: 5 minute expiration
- **Logging**: INFO level (detailed CI insights)
- **CORS**: 6 localhost origins (comprehensive testing)

### `debug` - For Troubleshooting

- **Database**: SQLite (separate debug database)
- **Tokens**: 1 hour expiration (long debugging sessions)
- **Logging**: DEBUG level (maximum verbosity)
- **CORS**: Wildcard (debugging flexibility)

### `development` - For Local Development (Default)

- **Database**: PostgreSQL (production-like)
- **Tokens**: 1 hour expiration
- **Logging**: INFO level (balanced feedback)
- **CORS**: Wildcard (development flexibility)

### `production` - For Production Deployment

- **Database**: PostgreSQL (production)
- **Tokens**: 30 minute expiration (security)
- **Logging**: ERROR level (production safety)
- **CORS**: Restricted domains (security)

## 🔧 How It Works

### Current Environment Detection

```bash
# Check your current environment
cd /home/potato/DevOnboarder
source .venv/bin/activate
python -c "
import sys; sys.path.insert(0, 'src')
from utils.environment import get_environment
print(f'Current environment: {get_environment()}')
"
```

### Environment Variables in Code

```python
# In your Python code
from utils.environment import get_environment, is_testing, get_database_url

# Automatic environment detection
env = get_environment()
print(f"Running in {env} mode")

# Environment-specific logic
if is_testing():
    print("Fast test mode active")

# Get environment-appropriate config
db_url = get_database_url()  # Automatically correct for environment
```

## 🚀 Common Scenarios

### Switch to Test Mode

```bash
# Edit .env file:
APP_ENV=testing

# Run tests
python -m pytest
```

### Switch to Debug Mode

```bash
# Edit .env file:
APP_ENV=debug

# Start with maximum logging
python -c "from utils.environment import get_log_level; print(get_log_level())"
# Output: DEBUG
```

### Switch to Production Mode

```bash
# Edit .env file:
APP_ENV=production

# Verify security settings
python -c "
import sys; sys.path.insert(0, 'src')
from utils.environment import get_environment
env = get_environment()
print(f'Secure config required: {env.requires_secure_config}')
print(f'Log level: {env.log_level}')
"
# Output: Secure config required: True, Log level: ERROR
```

## 📋 Troubleshooting

### Environment Not Switching?

1. Check your `.env` file has `APP_ENV=desired_mode`
2. Restart services after changing environment
3. Verify with: `python -c "import os; print(os.getenv('APP_ENV'))"`

### Can't Find Environment Module?

```bash
# Make sure you're in the right directory and virtual environment
cd /home/potato/DevOnboarder
source .venv/bin/activate
python -c "import sys; sys.path.insert(0, 'src'); from utils.environment import get_environment"
```

### Need to Reset to Default?

```bash
# Set back to development mode
# Edit .env file:
APP_ENV=development
```

## 📖 Full Documentation

For complete details, see: `docs/env.md`

For environment security and management: `docs/LESSONS_LEARNED_ENV_MANAGEMENT.md`
