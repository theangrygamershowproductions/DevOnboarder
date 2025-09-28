from devonboarder import auth_service
from fastapi import HTTPException


def test_validate_password_accepts_short_passwords():
    # 10 ASCII chars -> 10 bytes
    auth_service._validate_password_for_bcrypt("shortpwd")


def test_validate_password_rejects_long_passwords():
    # Create a password > 72 bytes when UTF-8 encoded
    long_password = "a" * 100
    try:
        auth_service._validate_password_for_bcrypt(long_password)
    except HTTPException as exc:
        assert exc.status_code == 400
        assert "Password too long" in exc.detail
    else:
        raise AssertionError("Expected HTTPException for long password")


def test_validate_password_handles_multibyte_overflow():
    # Use 4-byte unicode characters to ensure byte-length > char-length
    # '😊' is 4 bytes in UTF-8
    pwd = "😊" * 20  # 80 bytes
    try:
        auth_service._validate_password_for_bcrypt(pwd)
    except HTTPException as exc:
        assert exc.status_code == 400
    else:
        raise AssertionError("Expected HTTPException for multibyte long password")
