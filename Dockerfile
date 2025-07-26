# =============================================================================
# File: Dockerfile
# Version: 1.0.0
# Author: DevOnboarder Project
# Created: 2025-07-25
# Updated: 2025-07-25
# Purpose: Multi-service container for CI/CD pipeline
# Dependencies: Python 3.12, Node.js 22
# DevOnboarder Project Standards: Compliant with copilot-instructions.md
# =============================================================================

FROM python:3.12-slim

# Install system dependencies
RUN apt-get update && apt-get install -y \
   curl \
   git \
   build-essential \
   && rm -rf /var/lib/apt/lists/*

# Install Node.js 22
RUN curl -fsSL https://deb.nodesource.com/setup_22.x | bash - && \
   apt-get install -y nodejs

# Set working directory
WORKDIR /app

# Copy Python project configuration
COPY pyproject.toml ./
COPY src ./src

# Install Python dependencies
RUN pip install --no-cache-dir --root-user-action=ignore -e .[test]

# Copy remaining project files
COPY . ./

# Install frontend dependencies if package.json exists
RUN if [ -f "frontend/package.json" ]; then \
   cd frontend && npm ci; \
   fi

# Install bot dependencies if package.json exists
RUN if [ -f "bot/package.json" ]; then \
   cd bot && npm ci; \
   fi

# Expose ports for services
EXPOSE 8001 8002 8081

# Default command (can be overridden by docker-compose)
CMD ["python", "-m", "devonboarder.auth_service"]
