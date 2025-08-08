import tempfile
import shutil
from pathlib import Path
from devonboarder import PLUGINS


def test_sample_plugin_loaded():
    assert "sample" in PLUGINS
    plugin = PLUGINS["sample"]
    assert hasattr(plugin, "register")
    assert plugin.register() == "Sample plugin loaded"


def test_no_plugins_when_directory_missing():
    """Test that _discover_plugins returns empty dict when plugins dir doesn't exist."""
    from devonboarder import _discover_plugins

    # Temporarily move plugins directory to test the missing case
    plugins_dir = Path(__file__).resolve().parents[1] / "plugins"
    temp_dir = None

    if plugins_dir.exists():
        temp_dir = tempfile.mkdtemp()
        temp_plugins = Path(temp_dir) / "plugins_backup"
        shutil.move(str(plugins_dir), str(temp_plugins))

    try:
        # Now plugins directory doesn't exist
        result = _discover_plugins()
        assert result == {}
    finally:
        # Restore plugins directory if we moved it
        if temp_dir and Path(temp_dir, "plugins_backup").exists():
            shutil.move(str(Path(temp_dir) / "plugins_backup"), str(plugins_dir))
            shutil.rmtree(temp_dir)
