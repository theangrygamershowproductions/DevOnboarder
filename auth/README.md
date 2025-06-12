---
project: "TAGS"
module: "Documentation Tools"
phase: "Maintenance Automation"
tags: ["metadata", "markdown", "indexing", "automation"]
updated: "12 June 2025 09:33 (EST)"
version: "v1.2.6"
author: "Chad Allan Reesey (Mr. Potato)"
email: "education@thenagrygamershow.com"
description: "Manages indexing and metadata injection for project documentation."
---

# Documentation Tools – Maintenance Automation
<!-- PATCHED v0.2.0 auth/README.md — Auth service overview and usage -->

# Auth Service

This directory contains the FastAPI authentication microservice.

## Docker

```bash
docker build -t devonboarder-auth ./auth
docker run -p 8000:8000 devonboarder-auth
```

## Local Development

```bash
cd auth
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
uvicorn app.main:app --reload
```

### Running Tests

```bash
cd auth
pytest -q
```

Environment variables such as `AUTH_SECRET_KEY` and `DATABASE_URL` may be added via `.env.development`.
