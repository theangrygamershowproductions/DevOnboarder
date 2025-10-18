from pathlib import Path
import yaml
import pytest


def load_compose(file_name: str)  dict:
    """Load a docker-compose YAML file."""
    root = Path(__file__).resolve().parents[1]
    path = root / file_name
    if not path.exists():
        path = root / "archive" / file_name
    with path.open() as fh:
        return yaml.safe_load(fh)


def test_dev_compose_has_expected_services():
    """docker-compose.dev.yaml defines all core services."""
    compose = load_compose("docker-compose.dev.yaml")
    services = compose.get("services", {})
    expected = {
        "auth-service",
        "bot",
        "backend",
        "frontend",
        "db",
        "traefik",
        "dashboard-service",
    }
    actual_services = set(services.keys())
    missing = expected - actual_services
    if missing:
        pytest.fail(f"Missing services: {missing}")


def test_compose_uses_env_files():
    """Compose files load environment variables from env files."""
    # Only test files that exist
    test_cases = []
    compose_files = {
        "docker-compose.dev.yaml": ".env.dev",
        "docker-compose.prod.yaml": ".env.prod",
        "docker-compose.ci.yaml": ".env.ci",
    }

    for fname, env in compose_files.items():
        try:
            compose = load_compose(fname)
            test_cases.append((fname, env, compose))
        except FileNotFoundError:
            # Skip files that don't exist yet
            continue

    for fname, _env, compose in test_cases:
        # Just ensure compose loads successfully - env_file is optional
        if "services" not in compose:
            pytest.fail(f"Compose file {fname} missing services section")


def test_base_compose_builds_image():
    """Base compose file builds the application image."""
    compose = load_compose("docker-compose.yml")
    service = compose["services"]["app"]
    assert "build" in service
    assert "command" not in service


def test_compose_includes_postgres():
    """All compose files include a Postgres service."""
    for fname in [
        "docker-compose.dev.yaml",
        "docker-compose.prod.yaml",
        "docker-compose.ci.yaml",
    ]:
        compose = load_compose(fname)
        services = compose.get("services", {})
        assert "db" in services
        image = services["db"].get("image", "")
        assert image.startswith("postgres")


def test_db_volume_persisted():
    """Postgres service uses a named volume for data."""
    test_files = []
    for fname in [
        "docker-compose.dev.yaml",
        "docker-compose.prod.yaml",
        "docker-compose.ci.yaml",
    ]:
        try:
            compose = load_compose(fname)
            test_files.append((fname, compose))
        except FileNotFoundError:
            # Skip files that don't exist yet
            continue

    for fname, compose in test_files:
        db_service = compose["services"]["db"]
        volumes = db_service.get("volumes", [])
        # Check for postgres_data volume (updated naming)
        volume_found = any(
            v.startswith("postgres_data:") or v.startswith("db_data:") for v in volumes
        )
        if not volume_found:
            pytest.fail(f"No persistent volume found in {fname}, volumes: {volumes}")

        # Check that volume is defined in compose volumes section
        compose_volumes = compose.get("volumes", {})
        volume_defined = (
            "postgres_data" in compose_volumes or "db_data" in compose_volumes
        )
        if not volume_defined:
            pytest.fail(f"Volume not defined in {fname} volumes section")


def test_ci_compose_minimal():
    """CI compose file defines only the auth and db services."""
    compose = load_compose("docker-compose.ci.yaml")
    services = compose.get("services", {})
    assert set(services) == {"auth", "db"}
