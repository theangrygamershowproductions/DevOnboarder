---
similarity_group: setup.md-docs
content_uniqueness_score: 4
merge_candidate: false
consolidation_priority: P3
---
# DevOnboarder Setup Guide

## Quick Start

For immediate setup, see [QUICKSTART.md](../QUICKSTART.md).

## Detailed Setup

### Prerequisites

- Python 3.11
- Node.js 18
- Docker and Docker Compose
- Git

### Installation

1. **Clone the repository:**

   ```bash
   git checkout main && git pull
   git checkout -b feat/your-feature-name
   ```

2. **Set up virtual environment:**

   ```bash
   source .venv/bin/activate  # MANDATORY - enforced by safe commit wrapper
   ```

3. **Install dependencies:**

   ```bash
   pip install -e .[test]
   npm ci --prefix bot
   npm ci --prefix frontend
   ```

4. **Run quality validation:**

   ```bash
   ./scripts/qc_pre_push.sh  # 95% quality threshold validation
   ```

5. **Use safe commit wrapper:**

   ```bash
   ./scripts/safe_commit.sh "FEAT(component): description"  # NEVER use git commit directly
   ```

## Environment Variables

See [Environment Variables](env.md) for detailed configuration.

## Service Architecture

- **Backend**: FastAPI services in `src/` (Auth: 8002, XP: 8001)
- **Bot**: TypeScript Discord.js bot in `bot/` (Port: 8081)
- **Frontend**: React  Vite in `frontend/` (Port: 8081 dev server)
- **Database**: PostgreSQL with SQLAlchemy models

## Development Workflow

See [Contributing Guide](../CONTRIBUTING.md) for detailed development workflow instructions.

For comprehensive development guidelines, see:

- [Contributing Guide](../CONTRIBUTING.md)
- [Git Guidelines](git-guidelines.md)
- [Quality Control Policy](policies/quality-control-policy.md)

## Troubleshooting

See [Troubleshooting Guide](troubleshooting.md) for common issues.
