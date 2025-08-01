.PHONY: deps gen-secrets up test openapi aar-setup aar-check aar-generate aar-validate aar-env-template

deps:
	docker compose -f docker-compose.dev.yaml build

gen-secrets:
	./scripts/generate-secrets.sh

up: gen-secrets deps
	docker compose -f docker-compose.dev.yaml up

test:
	        bash scripts/run_tests.sh

openapi:
	python scripts/generate_openapi.py

# AAR System Commands
aar-setup:
	@echo "Setting up AAR system..."
	@if [ -f .env ]; then echo "Loading environment from .env..."; set -a; source .env; set +a; fi
	@bash scripts/setup_aar_tokens.sh
	@echo "Creating logs directory structure..."
	@mkdir -p logs/aar logs/token-audit logs/compliance-reports
	@echo "AAR system setup complete"

aar-check:
	@echo "Checking AAR system status..."
	@bash scripts/setup_aar_tokens.sh analysis
	@echo "Validating AAR configuration..."
	@test -f config/aar-config.json && echo "✅ AAR config found" || echo "❌ AAR config missing"
	@test -f templates/aar-template.md && echo "✅ AAR template found" || echo "❌ AAR template missing"

aar-generate:
	@echo "Generating AAR report (requires workflow-run-id parameter)..."
	@if [ -z "$(WORKFLOW_ID)" ]; then \
		echo "Usage: make aar-generate WORKFLOW_ID=12345"; \
		echo "Alternative: make aar-generate WORKFLOW_ID=12345 CREATE_ISSUE=true"; \
	else \
		if [ -f .env ]; then set -a; source .env; set +a; fi && source .venv/bin/activate && python scripts/generate_aar.py --workflow-run-id $(WORKFLOW_ID) $(if $(CREATE_ISSUE),--create-issue); \
	fi

aar-validate:
	@echo "Validating AAR templates for markdown compliance..."
	@if [ -f .env ]; then set -a; source .env; set +a; fi && source .venv/bin/activate && python scripts/validate_templates.py
	@echo "AAR validation complete"

aar-env-template:
	@echo "Setting up .env for AAR system..."
	@if [ ! -f .env ]; then \
		echo "Creating new .env file..."; \
		echo "# AAR System Environment Variables" > .env; \
		echo "# DevOnboarder No Default Token Policy v1.0 Compliance" >> .env; \
		echo "" >> .env; \
		echo "# Primary token for issue automation (highest priority)" >> .env; \
		echo "#CI_ISSUE_AUTOMATION_TOKEN=your_issue_token_here" >> .env; \
		echo "" >> .env; \
		echo "# Secondary token for bot operations" >> .env; \
		echo "#CI_BOT_TOKEN=your_bot_token_here" >> .env; \
		echo "" >> .env; \
		echo "# Fallback token (use only when finely-scoped tokens unavailable)" >> .env; \
		echo "#GITHUB_TOKEN=your_github_token_here" >> .env; \
		echo "" >> .env; \
		echo "# Optional: GitHub CLI integration" >> .env; \
		echo "#GITHUB_TOKEN=\$$(gh auth token)" >> .env; \
		echo "✅ Created new .env file with AAR variables"; \
	else \
		echo "Existing .env found, checking for AAR variables..."; \
		if ! grep -q "CI_ISSUE_AUTOMATION_TOKEN" .env; then \
			echo "" >> .env; \
			echo "# AAR System Environment Variables (added by make aar-env-template)" >> .env; \
			echo "# DevOnboarder No Default Token Policy v1.0 Compliance" >> .env; \
			echo "" >> .env; \
			echo "# Primary token for issue automation (highest priority)" >> .env; \
			echo "#CI_ISSUE_AUTOMATION_TOKEN=your_issue_token_here" >> .env; \
			echo "" >> .env; \
			echo "# Secondary token for bot operations" >> .env; \
			echo "#CI_BOT_TOKEN=your_bot_token_here" >> .env; \
			echo "" >> .env; \
			echo "# Fallback token (use only when finely-scoped tokens unavailable)" >> .env; \
			echo "#GITHUB_TOKEN=your_github_token_here" >> .env; \
			echo "✅ Added AAR variables to existing .env file"; \
		else \
			echo "⚠️  AAR variables already exist in .env"; \
			echo "💡 Review existing tokens or manually edit .env"; \
		fi; \
	fi
	@echo "📋 Remember: Uncomment and set your actual tokens"
	@echo "🔒 .env is gitignored for security"
