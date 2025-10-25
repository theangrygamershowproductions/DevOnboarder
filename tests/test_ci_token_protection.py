"""Test CI token protection functionality."""

import os
import tempfile

# Import the token loader
from scripts.token_loader import TokenLoader


class TestCITokenProtection:
    """Test suite for CI token protection."""

    def test_ci_token_protection_prevents_override(self):
        """Test that CI tokens are not overridden by test placeholders."""
        # Simulate CI environment
        os.environ["CI"] = "true"

        # Set a "real" GitHub Actions secret (test value, not real)
        real_token = "ghp_1234567890abcdef_REAL_TOKEN"  # nosec B105
        os.environ["CI_ISSUE_AUTOMATION_TOKEN"] = real_token

        # Create a temporary .tokens.ci file with test placeholder
        with tempfile.NamedTemporaryFile(
            mode="w", suffix=".tokens.ci", delete=False
        ) as f:
            f.write(
                "CI_ISSUE_AUTOMATION_TOKEN=" + "ci_test_ci_issue_automation_token_placeholder\n"
            )
            f.write("CI_BOT_TOKEN=ci_test_ci_bot_token_placeholder\n")
            temp_tokens_file = f.name

        try:
            # Create token loader and load tokens
            loader = TokenLoader()
            loader.load_tokens(temp_tokens_file)

            # Check if protection worked - real token should be preserved
            final_token = os.environ.get("CI_ISSUE_AUTOMATION_TOKEN")
            expected_msg = "CI token was overridden with test placeholder"
            assert final_token == real_token, expected_msg

        finally:
            # Cleanup
            os.unlink(temp_tokens_file)
            if "CI" in os.environ:
                del os.environ["CI"]
            if "CI_ISSUE_AUTOMATION_TOKEN" in os.environ:
                del os.environ["CI_ISSUE_AUTOMATION_TOKEN"]

    def test_normal_token_loading_still_works(self):
        """Test that normal token loading still works in non-CI environments."""
        # Ensure we're not in CI environment
        if "CI" in os.environ:
            del os.environ["CI"]

        # Remove any existing test token
        if "TEST_TOKEN" in os.environ:
            del os.environ["TEST_TOKEN"]

        # Create a temporary tokens file
        with tempfile.NamedTemporaryFile(mode="w", suffix=".tokens", delete=False) as f:
            f.write("TEST_TOKEN=normal_token_value\n")
            temp_tokens_file = f.name

        try:
            # Create token loader and load tokens
            loader = TokenLoader()
            loader.load_tokens(temp_tokens_file)

            # Check if normal loading worked
            final_token = os.environ.get("TEST_TOKEN")
            expected = "normal_token_value"  # nosec B105
            assert final_token == expected, "Normal token loading failed"

        finally:
            # Cleanup
            os.unlink(temp_tokens_file)
            if "TEST_TOKEN" in os.environ:
                del os.environ["TEST_TOKEN"]
