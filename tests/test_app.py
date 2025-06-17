from devonboarder.app import greet


def test_greet_empty_string():
    """Return greeting when name is empty."""
    assert greet("") == "Hello, !"


def test_greet_special_chars():
    """Return greeting when name contains special characters."""
    assert greet("Codex_123!") == "Hello, Codex_123!!"
