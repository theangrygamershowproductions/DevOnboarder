from pathlib import Path
import yaml


def load_compose(file_name: str) -> dict:
    """Load a docker-compose YAML file."""
    path = Path(__file__).resolve().parents[1] / file_name
    with path.open() as fh:
        return yaml.safe_load(fh)


def test_dev_compose_has_redis_service():
    """docker-compose.dev.yaml defines a redis service."""
    compose = load_compose("docker-compose.dev.yaml")
    services = compose.get("services", {})
    assert "redis" in services
    ports = services["redis"].get("ports", [])
    assert "6379:6379" in ports


def test_base_compose_builds_image():
    """Base compose file builds the application image."""
    compose = load_compose("docker-compose.yml")
    service = compose["services"]["app"]
    assert "build" in service
    assert "command" not in service


def test_compose_includes_postgres():
    """Both compose files include a Postgres service."""
    for fname in ["docker-compose.yml", "docker-compose.dev.yaml"]:
        compose = load_compose(fname)
        services = compose.get("services", {})
        assert "db" in services
        image = services["db"].get("image", "")
        assert image.startswith("postgres")
