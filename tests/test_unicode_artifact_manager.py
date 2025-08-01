#!/usr/bin/env python3
"""
Test script for Unicode artifact manager.

This validates the enhanced Unicode handling functionality.
"""

import sys
import tempfile
from pathlib import Path

# Add scripts directory to path for imports
sys.path.insert(0, str(Path(__file__).parent.parent / "scripts"))

from unicode_artifact_manager import UnicodeArtifactManager  # noqa: E402


def test_unicode_artifact_manager():
    """Test the Unicode artifact manager functionality."""
    print("Testing Unicode Artifact Manager...")

    # Create manager
    manager = UnicodeArtifactManager()

    # Test environment detection
    capabilities = manager.detect_unicode_environment()
    print(f"Environment capabilities: {capabilities}")

    # Test filename normalization
    test_files = [
        "normal_file.txt",
        "file_with_émojis.log",
        "αβγ_greek.json",
        "测试文件.xml",
        "file<>with|problematic?chars.txt",
    ]

    print("\nTesting filename normalization:")
    for filename in test_files:
        try:
            normalized = manager.normalize_unicode_filename(filename)
            safe_display = manager.safe_display_filename(
                filename, unicode_capable=capabilities.get("unicode_display", True)
            )
            print(f"  Original: {repr(filename)}")
            print(f"  Normalized: {repr(normalized)}")
            print(f"  Safe display: {repr(safe_display)}")
            print()
        except UnicodeError as e:
            print(f"  Error processing {filename}: {e}")

    # Test with a temporary directory
    with tempfile.TemporaryDirectory() as temp_dir:
        temp_path = Path(temp_dir)

        # Create test files
        for filename in ["test.txt", "αβγ.log", "émoji_file.json"]:
            try:
                (temp_path / filename).touch()
            except OSError:
                # Skip files that can't be created on this filesystem
                print(f"Skipping creation of {filename} " "(filesystem limitation)")

        # Analyze the test directory
        analysis = manager.analyze_artifact_filenames(temp_path)
        print("Analysis results:")
        print(f"  Total files: {analysis['total_files']}")
        print(f"  Unicode files: {len(analysis['unicode_files'])}")
        print(f"  Problematic files: {len(analysis['problematic_files'])}")

        # Generate listing
        listing = manager.generate_unicode_aware_listing(temp_path, "text")
        print("\nGenerated listing:")
        print(listing)

    print("\nUnicode statistics:", manager.unicode_stats)
    print("Test completed successfully!")


if __name__ == "__main__":
    test_unicode_artifact_manager()
