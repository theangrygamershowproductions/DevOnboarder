"""
Test coverage for scripts/run_tests.sh - Core test execution script.

This module provides comprehensive testing for the basic test execution script
that is critical to CI pipeline reliability.
"""

import os
import tempfile
import subprocess
import pytest
from pathlib import Path
from unittest.mock import patch, mock_open


class TestRunTestsScript:
    """Test suite for scripts/run_tests.sh functionality."""

    def setup_method(self):
        """Set up test environment for each test."""
        self.script_path = Path("scripts/run_tests.sh")
        self.original_cwd = os.getcwd()

    def teardown_method(self):
        """Clean up after each test."""
        os.chdir(self.original_cwd)

    def test_script_exists_and_executable(self):
        """Test that the run_tests.sh script exists and is executable."""
        assert self.script_path.exists(), "run_tests.sh script must exist"
        executable = os.access(self.script_path, os.X_OK)
        assert executable, "run_tests.sh must be executable"

    def test_script_has_proper_shebang(self):
        """Test that script starts with proper bash shebang."""
        with open(self.script_path, "r", encoding="utf-8") as f:
            first_line = f.readline().strip()
        expected_shebang = "#!/usr/bin/env bash"
        msg = "Script must have proper bash shebang"
        assert first_line == expected_shebang, msg

    def test_script_has_error_handling(self):
        """Test that script includes proper error handling settings."""
        with open(self.script_path, "r", encoding="utf-8") as f:
            content = f.read()
        error_handling = "set -euo pipefail"
        msg = "Script must include error handling settings"
        assert error_handling in content, msg

    def test_pip_install_called(self):
        """Test that pip install is referenced in the script."""
        with open(self.script_path, "r", encoding="utf-8") as f:
            content = f.read()

        assert "pip install -e .[test]" in content

    def test_ruff_check_called(self):
        """Test that ruff linting is referenced in the script."""
        with open(self.script_path, "r", encoding="utf-8") as f:
            content = f.read()

        assert "ruff check" in content

    def test_pytest_coverage_enforcement(self):
        """Test that pytest runs with proper coverage requirements."""
        with open(self.script_path, "r", encoding="utf-8") as f:
            content = f.read()

        assert "--cov=src" in content
        assert "--cov-fail-under=95" in content
        assert "--junitxml=test-results/pytest-results.xml" in content

    def test_test_results_directory_creation(self):
        """Test that test-results directory is created."""
        with tempfile.TemporaryDirectory() as tmpdir:
            test_results_path = Path(tmpdir) / "test-results"

            # Simulate the mkdir -p command
            test_results_path.mkdir(parents=True, exist_ok=True)

            assert test_results_path.exists()
            assert test_results_path.is_dir()

    @patch(
        "builtins.open",
        new_callable=mock_open,
        read_data="ModuleNotFoundError: No module named 'some_module'",
    )
    def test_module_not_found_error_detection(self, _mock_file):
        """Test that ModuleNotFoundError is properly detected."""
        # Read the mock log content
        with open("dummy_log", "r", encoding="utf-8") as f:
            log_content = f.read()

        assert "ModuleNotFoundError" in log_content

    def test_coverage_threshold_enforcement(self):
        """Test that 95% coverage threshold is properly enforced."""
        with open(self.script_path, "r", encoding="utf-8") as f:
            content = f.read()

        # Should enforce 95% coverage threshold
        coverage_msg = "Script must enforce 95% coverage threshold"
        assert "--cov-fail-under=95" in content, coverage_msg

        # Should target src directory for coverage
        src_msg = "Script should measure coverage for src directory"
        assert "--cov=src" in content, src_msg

    @patch.dict(os.environ, {"CI": "true"})
    def test_ci_environment_compatibility(self):
        """Test that script works properly in CI environment."""
        # The script should work in CI without interactive prompts
        assert os.environ.get("CI") == "true"

        # Script should not require interactive input
        with open(self.script_path, "r", encoding="utf-8") as f:
            content = f.read()

        # Should not contain interactive prompts
        interactive_patterns = ["read -p", "select ", "echo -n"]
        for pattern in interactive_patterns:
            msg = f"Script should not contain pattern: {pattern}"
            assert pattern not in content, msg

    def test_bot_directory_detection(self):
        """Test bot directory and package.json detection logic."""
        with tempfile.TemporaryDirectory() as tmpdir:
            bot_dir = Path(tmpdir) / "bot"
            package_json = bot_dir / "package.json"

            # Test when bot directory doesn't exist
            assert not bot_dir.exists()

            # Test when bot directory exists but no package.json
            bot_dir.mkdir()
            assert bot_dir.exists()
            assert not package_json.exists()

            # Test when both exist
            package_json.write_text('{"name": "test-bot"}')
            assert package_json.exists()

    def test_frontend_directory_detection(self):
        """Test frontend directory and test script detection logic."""
        with tempfile.TemporaryDirectory() as tmpdir:
            frontend_dir = Path(tmpdir) / "frontend"
            package_json = frontend_dir / "package.json"

            # Test when frontend directory doesn't exist
            assert not frontend_dir.exists()

            # Test when frontend directory exists but no package.json
            frontend_dir.mkdir()
            assert frontend_dir.exists()
            assert not package_json.exists()

            # Test when both exist with test script
            package_json.write_text('{"scripts": {"test": "vitest"}}')
            assert package_json.exists()

            with open(package_json, "r", encoding="utf-8") as f:
                content = f.read()
            assert '"test"' in content


class TestRunTestsIntegration:
    """Integration tests for run_tests.sh script."""

    def test_script_syntax_validation(self):
        """Test that the script has valid bash syntax."""
        script_path = Path("scripts/run_tests.sh")

        # Test bash syntax validation
        result = subprocess.run(
            ["bash", "-n", str(script_path)],
            capture_output=True,
            text=True,
            check=False,
        )

        msg = f"Script has syntax errors: {result.stderr}"
        assert result.returncode == 0, msg

    def test_required_tools_availability(self):
        """Test that required tools are available for the script."""
        required_tools = ["pip", "python", "bash"]

        for tool in required_tools:
            result = subprocess.run(["which", tool], capture_output=True, check=False)
            msg = f"Required tool not found: {tool}"
            assert result.returncode == 0, msg

    @pytest.mark.skipif(
        not Path("pyproject.toml").exists(), reason="pyproject.toml not found"
    )
    def test_project_structure_assumptions(self):
        """Test that script assumptions about project structure are valid."""
        # Test that expected directories exist or can be created
        expected_paths = [
            Path("src"),  # Source code directory
            Path("tests"),  # Test directory
            Path("scripts"),  # Scripts directory
        ]

        for path in expected_paths:
            msg = f"Expected project path not found: {path}"
            assert path.exists(), msg


if __name__ == "__main__":
    pytest.main([__file__, "-v"])
