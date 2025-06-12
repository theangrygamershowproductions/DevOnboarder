# PATCHED v0.1.1 .devcontainer/Dockerfile — Node 22 with Python 3.13
FROM mcr.microsoft.com/vscode/devcontainers/javascript-node:22 AS base
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      python3-venv python3-distutils python3-pip \
 && rm -rf /var/lib/apt/lists/*

FROM python:3.13-slim AS python

FROM base
# Copy Python 3.13 runtime from the official image
COPY --from=python /usr/local /usr/local
