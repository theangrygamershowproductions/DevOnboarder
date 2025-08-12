"""Simple test to hit the final coverage points needed for 95%."""

from devonboarder.auth_service import is_safe_redirect_url


def test_relative_url_coverage():
    """Test relative URL paths to hit missing coverage lines."""
    # Test relative URL that's safe (line 79 return True)
    assert is_safe_redirect_url("relative/path")
    assert is_safe_redirect_url("simple-path")

    # Test path with query parameters
    assert is_safe_redirect_url("path?param=value")
