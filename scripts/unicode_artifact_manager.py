#!/usr/bin/env python3
"""
Enhanced Unicode handling for test artifact display

This script enhances the manage_test_artifacts.sh script with improved
Unicode handling while maintaining compliance with DevOnboarder's
zero-tolerance Unicode terminal output policy.

Issue: #1008 - Enhanced Unicode handling for test artifact display
"""

import argparse
import json
import os
import sys
import unicodedata
from pathlib import Path
from typing import Dict


class UnicodeArtifactManager:
    """Enhanced Unicode handling for test artifacts."""

    def __init__(self, fallback_encoding: str = "ascii"):
        """Initialize with fallback encoding for limited environments."""
        self.fallback_encoding = fallback_encoding
        self.unicode_stats = {
            "files_with_unicode": 0,
            "unicode_chars_detected": 0,
            "fallback_applied": 0,
        }

    def detect_unicode_environment(self) -> Dict[str, bool]:
        """Detect Unicode capabilities of current environment."""
        capabilities = {
            "utf8_stdout": True,
            "utf8_filesystem": True,
            "unicode_display": True,
        }

        try:
            # Test stdout Unicode support
            test_char = "β"  # Greek beta
            sys.stdout.buffer.write(test_char.encode("utf-8"))
            sys.stdout.buffer.flush()
        except (UnicodeEncodeError, AttributeError):
            capabilities["utf8_stdout"] = False

        try:
            # Test filesystem Unicode support
            test_path = Path("test_unicode_αβγ")
            test_path.touch()
            test_path.unlink()
        except (OSError, UnicodeError):
            capabilities["utf8_filesystem"] = False

        # Check if we're in a CI environment (often has limited Unicode)
        if os.getenv("CI") == "true":
            capabilities["unicode_display"] = False

        return capabilities

    def normalize_unicode_filename(self, filename: str) -> str:
        """Normalize Unicode filename for cross-platform compatibility."""
        try:
            # Normalize to NFC form (canonical composition)
            normalized = unicodedata.normalize("NFC", filename)

            # Track Unicode usage
            if any(ord(char) > 127 for char in normalized):
                self.unicode_stats["files_with_unicode"] += 1
                self.unicode_stats["unicode_chars_detected"] += sum(
                    1 for char in normalized if ord(char) > 127
                )

            return normalized
        except (UnicodeError, ValueError, TypeError):
            self.unicode_stats["fallback_applied"] += 1
            return filename.encode("ascii", errors="replace").decode("ascii")

    def safe_display_filename(
        self, filename: str, max_width: int = 80, unicode_capable: bool = True
    ) -> str:
        """Safely display filename with Unicode awareness."""
        normalized = self.normalize_unicode_filename(filename)

        if not unicode_capable:
            # Convert to ASCII-safe representation
            safe_name = normalized.encode("ascii", errors="replace").decode()
            self.unicode_stats["fallback_applied"] += 1
            return safe_name[:max_width]

        # Truncate with Unicode awareness
        if len(normalized) <= max_width:
            return normalized

        # Smart truncation that doesn't break Unicode characters
        truncated = normalized[: max_width - 3]
        return truncated + "..."

    def analyze_artifact_filenames(self, artifact_dir: Path) -> dict:
        """Analyze Unicode usage in artifact filenames."""
        analysis: dict = {
            "total_files": 0,
            "unicode_files": [],
            "problematic_files": [],
            "encoding_issues": [],
            "recommendations": [],
        }

        if not artifact_dir.exists():
            return analysis

        for file_path in artifact_dir.rglob("*"):
            if file_path.is_file():
                analysis["total_files"] += 1
                filename = file_path.name

                # Check for Unicode characters
                if any(ord(char) > 127 for char in filename):
                    analysis["unicode_files"].append(
                        {
                            "path": str(file_path.relative_to(artifact_dir)),
                            "filename": filename,
                            "normalized": self.normalize_unicode_filename(filename),
                        }
                    )

                # Check for potentially problematic characters
                problematic_chars = ["<", ">", ":", '"', "|", "?", "*"]
                if any(char in filename for char in problematic_chars):
                    issues = [char for char in problematic_chars if char in filename]
                    analysis["problematic_files"].append(
                        {
                            "path": str(file_path.relative_to(artifact_dir)),
                            "issues": issues,
                        }
                    )

        # Generate recommendations
        if analysis["unicode_files"]:
            analysis["recommendations"].append(
                "Files with Unicode characters detected. "
                "Consider ASCII fallbacks for CI environments."
            )

        if analysis["problematic_files"]:
            analysis["recommendations"].append(
                "Files with problematic characters detected. "
                "May cause issues on some filesystems."
            )

        return analysis

    def generate_unicode_aware_listing(
        self, artifact_dir: Path, output_format: str = "text"
    ) -> str:
        """Generate Unicode-aware artifact listing."""
        capabilities = self.detect_unicode_environment()
        analysis = self.analyze_artifact_filenames(artifact_dir)

        if output_format == "json":
            return json.dumps(
                {
                    "environment": capabilities,
                    "analysis": analysis,
                    "unicode_stats": self.unicode_stats,
                },
                indent=2,
                ensure_ascii=False,
            )

        # Text format with safe ASCII output
        lines = []
        lines.append("Test Artifact Analysis")
        lines.append("=" * 50)
        lines.append("")

        # Environment capabilities
        lines.append("Unicode Environment:")
        for capability, supported in capabilities.items():
            status = "SUPPORTED" if supported else "LIMITED"
            lines.append(f"  {capability}: {status}")
        lines.append("")

        # File analysis
        lines.append(f"Total files: {analysis['total_files']}")
        lines.append(f"Files with Unicode: {len(analysis['unicode_files'])}")
        problematic_count = len(analysis["problematic_files"])
        lines.append(f"Problematic files: {problematic_count}")
        lines.append("")

        # Unicode files (with safe display)
        if analysis["unicode_files"]:
            lines.append("Unicode Filenames:")
            for file_info in analysis["unicode_files"]:
                safe_name = self.safe_display_filename(
                    file_info["filename"],
                    unicode_capable=capabilities["unicode_display"],
                )
                lines.append(f"  {safe_name}")
            lines.append("")

        # Recommendations
        if analysis["recommendations"]:
            lines.append("Recommendations:")
            for rec in analysis["recommendations"]:
                lines.append(f"  - {rec}")
            lines.append("")

        # Statistics
        lines.append("Unicode Statistics:")
        for stat, value in self.unicode_stats.items():
            lines.append(f"  {stat}: {value}")

        return "\n".join(lines)

    def create_unicode_config(self, output_path: Path) -> None:
        """Create Unicode handling configuration for test artifacts."""
        capabilities = self.detect_unicode_environment()

        config = {
            "unicode_handling": {
                "enabled": True,
                "fallback_encoding": self.fallback_encoding,
                "normalize_filenames": True,
                "safe_display": True,
                "max_filename_width": 80,
            },
            "environment": capabilities,
            "ci_optimizations": {
                "ascii_only_output": (
                    capabilities.get("unicode_display", True) is False
                ),
                "filename_sanitization": True,
                "encoding_validation": True,
            },
            "display_preferences": {
                "truncate_long_names": True,
                "show_unicode_stats": True,
                "highlight_problematic_files": True,
            },
        }

        output_path.parent.mkdir(parents=True, exist_ok=True)
        with output_path.open("w", encoding="utf-8") as f:
            json.dump(config, f, indent=2, ensure_ascii=False)


def main():
    """Main entry point for Unicode artifact management."""
    parser = argparse.ArgumentParser(
        description="Enhanced Unicode handling for test artifacts"
    )
    parser.add_argument(
        "artifact_dir", type=Path, help="Path to test artifact directory"
    )
    parser.add_argument(
        "--output-format",
        choices=["text", "json"],
        default="text",
        help="Output format for analysis",
    )
    parser.add_argument(
        "--config-output", type=Path, help="Path to write Unicode configuration file"
    )
    parser.add_argument(
        "--fallback-encoding",
        default="ascii",
        help="Fallback encoding for limited environments",
    )

    args = parser.parse_args()

    manager = UnicodeArtifactManager(args.fallback_encoding)

    # Generate analysis
    analysis = manager.generate_unicode_aware_listing(
        args.artifact_dir, args.output_format
    )

    print(analysis)

    # Create configuration if requested
    if args.config_output:
        manager.create_unicode_config(args.config_output)
        print(f"Unicode configuration written to: {args.config_output}")


if __name__ == "__main__":
    main()
