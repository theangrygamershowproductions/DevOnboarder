"""DevOnboarder package with basic plugin support."""

from importlib import util
from pathlib import Path
from typing import Dict

from .app import greet


def _discover_plugins() -> Dict[str, object]:
    """Return a mapping of plugin names to imported modules."""
    registry: Dict[str, object] = {}
    plugins_dir = Path(__file__).resolve().parents[2] / "plugins"
    if not plugins_dir.is_dir():
        return registry
    for path in plugins_dir.iterdir():
        if path.is_dir() and (path / "__init__.py").exists():
            module_name = f"plugins.{path.name}"
            spec = util.spec_from_file_location(module_name, path / "__init__.py")
            if spec and spec.loader:
                module = util.module_from_spec(spec)
                try:
                    spec.loader.exec_module(module)
                except Exception:  # pragma: no cover - plugin import failure
                    continue
                registry[path.name] = module
    return registry


PLUGINS = _discover_plugins()

__all__ = ["greet", "PLUGINS"]
