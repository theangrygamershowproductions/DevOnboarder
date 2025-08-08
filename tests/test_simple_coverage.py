"""
Simple coverage optimization targeting specific uncovered lines.
Focus on straightforward test cases that actually exercise the code.
"""

from unittest.mock import patch, Mock

from devonboarder.auth_service import (
    is_safe_redirect_url,
    discord_login,
    onboarding_status,
)


def test_empty_url_security():
    """Test security handling of empty URLs - covers line 52."""
    result = is_safe_redirect_url("")
    expected = False
    if result != expected:
        raise AssertionError("Empty URL should be rejected")


def test_whitespace_url_security():
    """Test security handling of whitespace URLs - covers line 52."""
    result = is_safe_redirect_url("   ")
    expected = False
    if result != expected:
        raise AssertionError("Whitespace URL should be rejected")


def test_none_url_security():
    """Test security handling of None URLs - covers line 52."""
    result = is_safe_redirect_url(None)  # type: ignore[arg-type]
    expected = False
    if result != expected:
        raise AssertionError("None URL should be rejected")


def test_backslash_url_normalization():
    """Test backslash normalization in URLs - covers line 59."""
    # This will normalize backslashes but still fail validation
    result = is_safe_redirect_url("\\\\malicious.com")
    expected = False
    if result != expected:
        raise AssertionError("Malicious URL should be rejected")


def test_protocol_relative_url_blocking():
    """Test blocking of protocol-relative URLs - covers lines 65-67."""
    result = is_safe_redirect_url("//evil.com/attack")
    expected = False
    if result != expected:
        raise AssertionError("Protocol-relative URL should be blocked")


def test_url_decode_exception():
    """Test URL decode exception handling - covers lines 71-72."""
    with patch("devonboarder.auth_service.unquote", side_effect=Exception):
        result = is_safe_redirect_url("test")
        expected = False
        if result != expected:
            raise AssertionError("Should handle decode exception")


def test_urlparse_exception():
    """Test URL parse exception handling - covers line 98."""
    with patch("devonboarder.auth_service.urlparse", side_effect=Exception):
        result = is_safe_redirect_url("test")
        expected = False
        if result != expected:
            raise AssertionError("Should handle parse exception")


def test_path_protocol_relative():
    """Test path protocol-relative detection - covers line 104."""
    # This URL should trigger the path.startswith("//") check
    result = is_safe_redirect_url("//evil.com")
    expected = False
    if result != expected:
        raise AssertionError("Path protocol-relative should be blocked")


def test_onboarding_status_pending():
    """Test onboarding status for users without contributions - covers lines 490-492."""
    mock_user = Mock()
    mock_user.contributions = []  # Empty list = pending

    result = onboarding_status(current_user=mock_user)
    if result["status"] != "pending":
        raise AssertionError("User without contributions should be pending")


def test_onboarding_status_complete():
    """Test onboarding status for users with contributions - covers lines 490-492."""
    mock_user = Mock()
    mock_user.contributions = ["contribution1"]  # Has contributions = complete

    result = onboarding_status(current_user=mock_user)
    if result["status"] != "complete":
        raise AssertionError("User with contributions should be complete")


def test_http_localhost_with_port():
    """Test HTTP localhost with port number - covers lines 111, 124."""
    # This should trigger the HTTP localhost check (line 111) and netloc port splitting
    result = is_safe_redirect_url("http://localhost:3000/path")
    # Actually, localhost should be in allowed_domains, so this should pass
    expected = True
    if result != expected:
        raise AssertionError("HTTP localhost should be allowed")


def test_https_localhost_with_port():
    """Test HTTPS localhost with port number - covers line 124."""
    # This will trigger the netloc port splitting logic on line 124
    result = is_safe_redirect_url("https://localhost:8080/path")
    # This should pass validation since localhost is in allowed_domains
    expected = True
    if result != expected:
        raise AssertionError("HTTPS localhost should be allowed")


def test_discord_oauth_redirect_generation():
    """Test Discord OAuth URL generation - covers lines 305-317."""
    with patch.dict("os.environ", {"DISCORD_CLIENT_ID": "test123"}):
        response = discord_login(redirect_to="/dashboard")
        location = response.headers.get("location", "")
        if "discord.com/oauth2/authorize" not in location:
            raise AssertionError("Should redirect to Discord OAuth")
        if "client_id=test123" not in location:
            raise AssertionError("Should include client ID")
