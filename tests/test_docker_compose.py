from pathlib import Path
import yaml


def load_compose(file_name: str) -> dict:
    """Load a docker-compose YAML file."""
    path = Path(__file__).resolve().parents[1] / file_name
    with path.open() as fh:
        return yaml.safe_load(fh)


def test_dev_compose_has_expected_services():
    """docker-compose.dev.yaml defines all core services."""
    compose = load_compose("docker-compose.dev.yaml")
    services = compose.get("services", {})
    expected = {"auth", "bot", "xp", "frontend", "db"}
    assert expected.issubset(services)


def test_compose_uses_env_files():
    """Both compose files load environment variables from env files."""
    for fname, env in [
        ("docker-compose.dev.yaml", ".env.dev"),
        ("docker-compose.prod.yaml", ".env.prod"),
    ]:
        compose = load_compose(fname)
        service = compose["services"]["auth"]
        env_file = service.get("env_file")
        assert env_file == [env] or env_file == env


def test_base_compose_builds_image():
    """Base compose file builds the application image."""
    compose = load_compose("docker-compose.yml")
    service = compose["services"]["app"]
    assert "build" in service
    assert "command" not in service


def test_compose_includes_postgres():
    """Both compose files include a Postgres service."""
    for fname in ["docker-compose.dev.yaml", "docker-compose.prod.yaml"]:
        compose = load_compose(fname)
        services = compose.get("services", {})
        assert "db" in services
        image = services["db"].get("image", "")
        assert image.startswith("postgres")


def test_db_volume_persisted():
    """Postgres service uses a named volume for data."""
    for fname in ["docker-compose.dev.yaml", "docker-compose.prod.yaml"]:
        compose = load_compose(fname)
        db_service = compose["services"]["db"]
        volumes = db_service.get("volumes", [])
        assert any(v.startswith("db_data:") for v in volumes)
        assert "db_data" in compose.get("volumes", {})
