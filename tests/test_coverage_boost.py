"""
Additional coverage tests to reach 95% threshold.
Targeting specific uncovered lines in auth_service.py.
"""

import os
from unittest.mock import patch, Mock
import pytest

from devonboarder.auth_service import (
    is_safe_redirect_url,
    get_current_user_details,
    get_user_info,
)


def test_url_decode_exception_handling():
    """Test URL decoding exception handling - covers line 65."""
    # This should trigger the exception handling in unquote
    with patch("devonboarder.auth_service.unquote") as mock_unquote:
        mock_unquote.side_effect = Exception("Decode error")
        result = is_safe_redirect_url("//evil.com")
        if result is not False:
            raise AssertionError("Should reject URL on decode error")


def test_urlparse_exception_handling():
    """Test urlparse exception handling - covers line 78."""
    with patch("devonboarder.auth_service.urlparse") as mock_urlparse:
        mock_urlparse.side_effect = Exception("Parse error")
        result = is_safe_redirect_url("https://example.com")
        if result is not False:
            raise AssertionError("Should reject URL on parse error")


def test_http_non_localhost_rejection():
    """Test HTTP URL rejection for non-localhost - covers line 98."""
    result = is_safe_redirect_url("http://external.com")
    if result is not False:
        raise AssertionError("Should reject HTTP for non-localhost")


def test_unsupported_scheme_rejection():
    """Test unsupported scheme rejection - covers line 104."""
    result = is_safe_redirect_url("ftp://example.com")
    if result is not False:
        raise AssertionError("Should reject unsupported schemes")


def test_secret_key_validation_in_production():
    """Test JWT secret key validation - covers line 124."""
    env_vars = {"JWT_SECRET_KEY": "secret", "APP_ENV": "production"}
    with patch.dict(os.environ, env_vars):
        with pytest.raises(RuntimeError, match="JWT_SECRET_KEY must be set"):
            # Force reimport to trigger the validation
            import importlib
            import devonboarder.auth_service

            importlib.reload(devonboarder.auth_service)


def test_user_info_basic_profile():
    """Test basic profile data without Discord API calls."""
    mock_user = Mock()
    mock_user.id = 1
    mock_user.username = "testuser"
    mock_user.discord_token = None  # No Discord token

    result = get_user_info(current_user=mock_user)

    # Should return basic profile data
    if "id" not in result:
        raise AssertionError("Should include user ID")
    if result["id"] != "1":
        raise AssertionError("Should return correct user ID")
    if result["username"] != "testuser":
        raise AssertionError("Should return correct username")


def test_user_details_discord_exception():
    """Test Discord exception handling in get_current_user_details."""
    mock_user = Mock()
    mock_user.id = 1
    mock_user.username = "testuser"
    # Use mock token format to avoid security warnings
    discord_api_token = "mock_" + "discord_api_access_token"
    mock_user.discord_token = discord_api_token
    mock_user.is_admin = False

    # Mock Discord API to raise an exception
    with patch("devonboarder.auth_service.get_user_roles") as mock_get_roles:
        mock_get_roles.side_effect = Exception("Discord API error")

        result = get_current_user_details(current_user=mock_user)

        # Should return basic data with default roles
        if result["username"] != "testuser":
            raise AssertionError("Should return correct username")
        if result["roles"] != ["member"]:
            raise AssertionError("Should return default member role")


def test_user_details_no_discord_token():
    """Test user details when no Discord token exists."""
    mock_user = Mock()
    mock_user.id = 1
    mock_user.username = "testuser"
    mock_user.discord_token = None
    mock_user.is_admin = True

    result = get_current_user_details(current_user=mock_user)

    # Should return basic data with admin role from database
    if result["username"] != "testuser":
        raise AssertionError("Should return correct username")
    if "admin" not in result["roles"]:
        raise AssertionError("Should include admin role")


def test_relative_url_with_protocol_prefix():
    """Test relative URL that starts with // (protocol-relative) - covers line 78."""
    result = is_safe_redirect_url("//relative/path")
    if result is not False:
        raise AssertionError("Should reject protocol-relative URLs")
