.PHONY: deps gen-secrets up

deps:
	docker compose -f docker-compose.dev.yaml build

gen-secrets:
	./scripts/generate-secrets.sh

up: gen-secrets deps
	docker compose -f docker-compose.dev.yaml up
