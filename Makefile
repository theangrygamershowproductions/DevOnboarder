.PHONY: deps gen-secrets up test openapi

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
