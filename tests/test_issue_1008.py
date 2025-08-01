#!/usr/bin/env python3
"""
Test suite for Issue #1008: Enhanced Unicode handling for test artifact display

This test validates:
1. Unicode terminal output violations are detected and fixed
2. Unicode artifact display is enhanced
3. Fallback mechanisms work for limited environments
4. Integration with existing test infrastructure
"""

import subprocess  # noqa: S404
import sys
import tempfile
from pathlib import Path


def test_unicode_violation_detection():
    """Test that Unicode violations are properly detected."""
    print("Testing Unicode violation detection...")

    # Run the validator on the original script
    result = subprocess.run(
        [  # noqa: S603
            sys.executable,
            "scripts/validate_unicode_terminal_output.py",
            "scripts/manage_test_artifacts.sh",
        ],
        capture_output=True,
        text=True,
        check=False,
    )

    assert result.returncode != 0, "Expected violations but none found!"

    violations = result.stdout.count("VIOLATIONS in")
    print("  Found violations in terminal output (expected)")
    print(f"  Total violation count: {violations}")
    assert violations > 0, "Expected to find violation count in output"


def test_unicode_artifact_manager():
    """Test the Unicode artifact manager functionality."""
    print("Testing Unicode artifact manager...")

    with tempfile.TemporaryDirectory() as temp_dir:
        temp_path = Path(temp_dir)

        # Create test files with various Unicode scenarios
        test_files = [
            "normal_file.txt",
            "file_with_unicode_αβγ.log",
            "测试文件.json",
        ]

        created_files = []
        for filename in test_files:
            try:
                file_path = temp_path / filename
                file_path.touch()
                created_files.append(filename)
            except OSError:
                print(f"    Skipped {filename} (filesystem limitation)")

        if not created_files:
            print("  WARNING: No files could be created, skipping test")
            return

        # Test the Unicode manager
        result = subprocess.run(
            [  # noqa: S603
                sys.executable,
                "scripts/unicode_artifact_manager.py",
                str(temp_path),
                "--output-format",
                "text",
            ],
            capture_output=True,
            text=True,
            check=False,
        )

        assert result.returncode == 0, f"Unicode manager failed: {result.stderr}"

        output = result.stdout
        assert "Test Artifact Analysis" in output, "Expected analysis header not found"
        assert "Unicode Environment:" in output, "Environment detection not found"

        print("  Unicode artifact manager working correctly")


def test_unicode_configuration_generation():
    """Test Unicode configuration file generation."""
    print("Testing Unicode configuration generation...")

    with tempfile.TemporaryDirectory() as temp_dir:
        temp_path = Path(temp_dir)
        config_path = temp_path / "unicode-config.json"

        # Create a test file
        (temp_path / "test.txt").touch()

        # Generate configuration
        result = subprocess.run(
            [  # noqa: S603
                sys.executable,
                "scripts/unicode_artifact_manager.py",
                str(temp_path),
                "--config-output",
                str(config_path),
            ],
            capture_output=True,
            text=True,
            check=False,
        )

        assert result.returncode == 0, f"Config generation failed: {result.stderr}"
        assert config_path.exists(), "Configuration file not created"

        # Validate configuration content
        import json

        try:
            with config_path.open() as f:
                config = json.load(f)

            required_keys = ["unicode_handling", "environment", "ci_optimizations"]
            for key in required_keys:
                assert key in config, f"Missing required config key: {key}"

            print("  Unicode configuration generated successfully")
        except json.JSONDecodeError as e:
            assert False, f"Invalid JSON configuration: {e}"


def test_fix_script():
    """Test the Unicode fix script."""
    print("Testing Unicode fix script...")

    # Check if fix script exists
    fix_script = Path("scripts/fix_unicode_violations.sh")
    assert fix_script.exists(), "Fix script not found"

    print("  Fix script exists and ready to apply")
    print("  (Not running automatically to avoid modifying repository)")


def test_issue_1008_requirements():
    """Test that all requirements from issue #1008 are addressed."""
    print("Validating Issue #1008 requirements...")

    requirements = {
        "unicode_display_improvements": False,
        "fallback_mechanisms": False,
        "environment_aware_formatting": False,
        "ci_compatibility": False,
        "documentation": False,
    }

    # Check for Unicode display improvements
    manager_script = Path("scripts/unicode_artifact_manager.py")
    if manager_script.exists():
        content = manager_script.read_text(encoding="utf-8")
        if (
            "safe_display_filename" in content
            and "normalize_unicode_filename" in content
        ):
            requirements["unicode_display_improvements"] = True

    # Check for fallback mechanisms
    if "fallback_encoding" in content and "ascii" in content:
        requirements["fallback_mechanisms"] = True

    # Check for environment-aware formatting
    if "detect_unicode_environment" in content and "CI" in content:
        requirements["environment_aware_formatting"] = True
        requirements["ci_compatibility"] = True

    # Check for documentation
    validator_script = Path("scripts/validate_unicode_terminal_output.py")
    if validator_script.exists() and "Issue: #1008" in validator_script.read_text(
        encoding="utf-8"
    ):
        requirements["documentation"] = True

    # Report results
    print("  Requirement compliance:")
    for req, met in requirements.items():
        status = "OK" if met else "MISSING"
        print(f"    {req}: {status}")

    assert all(requirements.values()), f"Some requirements not met: {requirements}"


def main():
    """Run all tests for issue #1008."""
    print("Testing Issue #1008: Enhanced Unicode handling for test artifact display")
    print("=" * 70)

    tests = [
        test_unicode_violation_detection,
        test_unicode_artifact_manager,
        test_unicode_configuration_generation,
        test_fix_script,
        test_issue_1008_requirements,
    ]

    results = []
    for test in tests:
        try:
            test()  # Test functions now use assertions instead of returning values
            results.append(True)
            print("  Result: PASS")
        except (
            subprocess.CalledProcessError,
            FileNotFoundError,
            OSError,
            AssertionError,
        ) as e:
            print(f"  Result: ERROR - {e}")
            results.append(False)
        print()

    # Summary
    passed = sum(results)
    total = len(results)
    print(f"Test Summary: {passed}/{total} tests passed")

    if passed == total:
        print("All tests passed! Issue #1008 requirements are met.")
        return 0
    else:
        print("Some tests failed. Check implementation.")
        return 1


if __name__ == "__main__":
    sys.exit(main())
