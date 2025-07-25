from devonboarder import PLUGINS


def test_sample_plugin_loaded():
    assert "sample" in PLUGINS
    plugin = PLUGINS["sample"]
    assert hasattr(plugin, "register")
    assert plugin.register() == "Sample plugin loaded"
