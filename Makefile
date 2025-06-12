# PATCHED v0.1.0 Makefile — fix indentation
.PHONY: dev-docker dev-stack

dev-docker:
	docker compose -f docker-compose.yml -f docker-compose.override.yaml up --build

dev-stack:
	docker compose -f docker-compose.dev.yaml up -d --build
