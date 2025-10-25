from devonboarder import auth_service
import pytest
from fastapi import HTTPException


def test_validate_password_accepts_short_passwords():
    # 10 ASCII chars + 10 bytes
    auth_service._validate_password_for_bcrypt("shortpwd")


def test_validate_password_rejects_none_password():
    with pytest.raises(HTTPException, match="Password required"):
        auth_service._validate_password_for_bcrypt(None)


def test_validate_password_accepts_empty_password():
    # Empty passwords are allowed for Discord OAuth accounts
    result = auth_service._validate_password_for_bcrypt("")
    assert result == ""


def test_validate_password_rejects_long_passwords():
    # Create a password > 72 bytes when UTF-8 encoded
    long_password = "a" * 100
    truncated = auth_service._validate_password_for_bcrypt(long_password)
    assert truncated == long_password[:72]
    assert len(truncated.encode("utf-8")) == 72


def test_validate_password_handles_multibyte_overflow():
    # Use 4-byte unicode characters to ensure byte-length > char-length
    # '😊' is 4 bytes in UTF-8
    pwd = "😊" * 20  # 80 bytes
    truncated = auth_service._validate_password_for_bcrypt(pwd)
    assert len(truncated.encode("utf-8")) == 72
    # Should be 18 full emojis (72 / 4 = 18)
    assert truncated == "😊" * 18
