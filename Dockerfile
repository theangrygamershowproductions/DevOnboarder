# =============================================================================
# File: Dockerfile
# Version: 2.1.0 - Clean multi-stage build for DevOnboarder
# Author: DevOnboarder Project
# Created: 2025-07-25
# Updated: 2025-08-05
# Purpose: Multi-service container with development and production targets
# Dependencies: Python 3.12, Node.js 22
# DevOnboarder Project Standards: Compliant with copilot-instructions.md
# =============================================================================

# ===== BASE STAGE =====
FROM python:3.12-slim AS base

# Install system dependencies
RUN apt-get update && apt-get install -y \
    curl \
    git \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Install Node.js 22
RUN curl -fsSL https://deb.nodesource.com/setup_22.x | bash - && \
    apt-get install -y nodejs && \
    rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Create logs directory
RUN mkdir -p logs

# ===== DEVELOPMENT STAGE =====
FROM base AS development

# Copy Python project configuration first
COPY pyproject.toml ./
COPY requirements-dev.txt ./

# Copy source code BEFORE installing dependencies
COPY src ./src
COPY scripts ./scripts

# Now install Python dependencies (development)
RUN pip install --no-cache-dir -e .[test]

# Create development user (non-root)
RUN useradd -m -s /bin/bash devuser && \
    chown -R devuser:devuser /app
USER devuser

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8001/health || curl -f http://localhost:8002/health || exit 1

# Default development command
CMD ["python", "-m", "devonboarder.server"]

# ===== PRODUCTION STAGE =====
FROM base AS production

# Copy Python project configuration
COPY pyproject.toml ./

# Copy source code FIRST
COPY src ./src

# Install Python dependencies (production only)
RUN pip install --no-cache-dir -e .

# Copy remaining project files
COPY . ./

# Create production user (non-root) and fix ownership
RUN useradd -m -s /bin/bash appuser && \
    chown -R appuser:appuser /app
USER appuser

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8001/health || curl -f http://localhost:8002/health || exit 1

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
