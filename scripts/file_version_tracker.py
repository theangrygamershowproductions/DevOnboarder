#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""File Version Tracker for DevOnboarder AAR System.

Tracks file changes between CI runs to provide comprehensive change analysis
for After Action Reports following DevOnboarder standards.
"""

import hashlib
import json
import subprocess  # noqa: S404
import sys
from datetime import datetime, timezone
from pathlib import Path
from typing import Any, Dict, List, Optional

# INFRASTRUCTURE CHANGE: Import standardized UTC timestamp utilities
# Purpose: Fix critical diagnostic issue with GitHub API timestamp synchronization
# Evidence: docs/troubleshooting/TIMESTAMP_SYNCHRONIZATION_DIAGNOSTIC_ISSUE.md
# Date: 2025-09-21
try:
    from src.utils.timestamps import get_utc_display_timestamp
except ImportError:
    from src.utils.timestamp_fallback import get_utc_display_timestamp


class FileVersionTracker:
    """Track file versions and changes for AAR analysis."""

    def __init__(self, tracking_file: str = "logs/file-versions.json"):
        """Initialize file version tracker.

        Parameters
        ----------
        tracking_file : str
            Path to file version tracking database.
        """
        self.tracking_file = Path(tracking_file)
        self.tracking_file.parent.mkdir(parents=True, exist_ok=True)
        self.version_data = self._load_version_data()

    def _load_version_data(self) -> Dict[str, Any]:
        """Load existing version tracking data.

        Returns
        -------
        Dict[str, Any]
            Version tracking data.
        """
        if self.tracking_file.exists():
            try:
                with open(self.tracking_file, "r", encoding="utf-8") as file:
                    return json.load(file)
            except (json.JSONDecodeError, OSError):
                # If file is corrupted, start fresh
                return {"files": {}, "snapshots": {}}

        return {"files": {}, "snapshots": {}}

    def _save_version_data(self) -> None:
        """Save version tracking data to file."""
        with open(self.tracking_file, "w", encoding="utf-8") as file:
            json.dump(self.version_data, file, indent=2, ensure_ascii=False)

    def _calculate_file_hash(self, file_path: Path) -> str:
        """Calculate SHA-256 hash of file content.

        Parameters
        ----------
        file_path : Path
            Path to file to hash.

        Returns
        -------
        str
            SHA-256 hash of file content.
        """
        sha256_hash = hashlib.sha256()
        try:
            with open(file_path, "rb") as file:
                for chunk in iter(lambda: file.read(4096), b""):
                    sha256_hash.update(chunk)
            return sha256_hash.hexdigest()
        except OSError:
            # File no longer exists or unreadable
            return "DELETED_OR_UNREADABLE"

    def scan_workspace_files(
        self, include_patterns: Optional[List[str]] = None
    ) -> Dict[str, Any]:
        """Scan workspace files and record their current state.

        Parameters
        ----------
        include_patterns : Optional[List[str]]
            File patterns to include in scan.

        Returns
        -------
        Dict[str, Any]
            Current file state snapshot.
        """
        if include_patterns is None:
            # Default patterns for DevOnboarder workspace
            include_patterns = [
                "src/**/*.py",
                "bot/**/*.ts",
                "bot/**/*.js",
                "frontend/**/*.tsx",
                "frontend/**/*.ts",
                "frontend/**/*.js",
                "tests/**/*.py",
                "scripts/**/*.py",
                "scripts/**/*.sh",
                "*.py",
                "*.md",
                "*.json",
                "*.yaml",
                "*.yml",
                "pyproject.toml",
                "package.json",
                "Dockerfile",
                "docker-compose*.yaml",
            ]

        current_snapshot = {
            # INFRASTRUCTURE CHANGE: Use proper UTC timestamp for accuracy
            # Purpose: Maintain consistency with GitHub API timestamp sync fix
            "timestamp": datetime.now(timezone.utc).isoformat(),
            "files": {},
            "git_info": self._get_git_info(),
        }

        workspace_root = Path(".")

        for pattern in include_patterns:
            # Use glob to find matching files
            for file_path in workspace_root.glob(pattern):
                if file_path.is_file() and not self._should_exclude_file(file_path):
                    relative_path = str(file_path.relative_to(workspace_root))
                    file_hash = self._calculate_file_hash(file_path)
                    file_stat = file_path.stat()

                    current_snapshot["files"][relative_path] = {
                        "hash": file_hash,
                        "size": file_stat.st_size,
                        "modified": datetime.fromtimestamp(
                            file_stat.st_mtime
                        ).isoformat(),
                    }

        return current_snapshot

    def _should_exclude_file(self, file_path: Path) -> bool:
        """Check if file should be excluded from tracking.

        Parameters
        ----------
        file_path : Path
            File path to check.

        Returns
        -------
        bool
            True if file should be excluded.
        """
        # Exclude patterns following DevOnboarder standards
        exclude_patterns = [
            ".venv",
            "node_modules",
            "__pycache__",
            ".git",
            ".pytest_cache",
            "logs",
            "test-results",
            "coverage",
            ".coverage",
            "*.pyc",
            "*.pyo",
            "*.pyd",
            "auth.db",
            "test.db",
            "*.log",
        ]

        file_str = str(file_path)

        for pattern in exclude_patterns:
            if pattern in file_str:
                return True

        return False

    def _get_git_info(self) -> Dict[str, str]:
        """Get current Git information.

        Returns
        -------
        Dict[str, str]
            Git repository information.
        """
        git_info = {}

        try:
            # Get current commit hash
            result = subprocess.run(
                ["git", "rev-parse", "HEAD"],
                capture_output=True,
                text=True,
                check=True,
                encoding="utf-8",
            )
            git_info["commit"] = result.stdout.strip()

            # Get current branch
            result = subprocess.run(
                ["git", "branch", "--show-current"],
                capture_output=True,
                text=True,
                check=True,
                encoding="utf-8",
            )
            git_info["branch"] = result.stdout.strip()

            # Get repository status
            result = subprocess.run(
                ["git", "status", "--porcelain"],
                capture_output=True,
                text=True,
                check=True,
                encoding="utf-8",
            )
            git_info["dirty"] = bool(result.stdout.strip())

        except (subprocess.CalledProcessError, FileNotFoundError):
            git_info = {"error": "Git information unavailable"}

        return git_info

    def create_snapshot(self, snapshot_name: str) -> str:
        """Create a named snapshot of current file state.

        Parameters
        ----------
        snapshot_name : str
            Name for the snapshot.

        Returns
        -------
        str
            Snapshot ID.
        """
        snapshot = self.scan_workspace_files()
        snapshot_id = f"{snapshot_name}_{datetime.now().strftime('%Y%m%d_%H%M%S')}"

        self.version_data["snapshots"][snapshot_id] = snapshot
        self._save_version_data()

        return snapshot_id

    def compare_snapshots(self, snapshot1_id: str, snapshot2_id: str) -> Dict[str, Any]:
        """Compare two snapshots to identify changes.

        Parameters
        ----------
        snapshot1_id : str
            First snapshot ID (baseline).
        snapshot2_id : str
            Second snapshot ID (comparison).

        Returns
        -------
        Dict[str, Any]
            Detailed comparison results.
        """
        if snapshot1_id not in self.version_data["snapshots"]:
            raise ValueError(f"Snapshot {snapshot1_id} not found")

        if snapshot2_id not in self.version_data["snapshots"]:
            raise ValueError(f"Snapshot {snapshot2_id} not found")

        snapshot1 = self.version_data["snapshots"][snapshot1_id]
        snapshot2 = self.version_data["snapshots"][snapshot2_id]

        files1 = snapshot1["files"]
        files2 = snapshot2["files"]

        comparison = {
            "baseline": snapshot1_id,
            "comparison": snapshot2_id,
            "added_files": [],
            "deleted_files": [],
            "modified_files": [],
            "unchanged_files": [],
            "summary": {},
        }

        all_files = set(files1.keys()) | set(files2.keys())

        for file_path in all_files:
            if file_path in files1 and file_path in files2:
                # File exists in both snapshots
                if files1[file_path]["hash"] != files2[file_path]["hash"]:
                    comparison["modified_files"].append(
                        {
                            "path": file_path,
                            "size_change": (
                                files2[file_path]["size"] - files1[file_path]["size"]
                            ),
                            "old_hash": files1[file_path]["hash"],
                            "new_hash": files2[file_path]["hash"],
                        }
                    )
                else:
                    comparison["unchanged_files"].append(file_path)
            elif file_path in files2:
                # File added
                comparison["added_files"].append(
                    {
                        "path": file_path,
                        "size": files2[file_path]["size"],
                        "hash": files2[file_path]["hash"],
                    }
                )
            else:
                # File deleted
                comparison["deleted_files"].append(
                    {
                        "path": file_path,
                        "size": files1[file_path]["size"],
                        "hash": files1[file_path]["hash"],
                    }
                )

        # Create summary statistics
        comparison["summary"] = {
            "total_files_baseline": len(files1),
            "total_files_comparison": len(files2),
            "files_added": len(comparison["added_files"]),
            "files_deleted": len(comparison["deleted_files"]),
            "files_modified": len(comparison["modified_files"]),
            "files_unchanged": len(comparison["unchanged_files"]),
            "net_file_change": len(files2) - len(files1),
        }

        return comparison

    def get_changes_since_commit(self, commit_hash: str) -> Dict[str, Any]:
        """Get file changes since a specific Git commit.

        Parameters
        ----------
        commit_hash : str
            Git commit hash to compare against.

        Returns
        -------
        Dict[str, Any]
            Changes since the specified commit.
        """
        try:
            # Get list of changed files since commit
            result = subprocess.run(
                ["git", "diff", "--name-status", f"{commit_hash}..HEAD"],
                capture_output=True,
                text=True,
                check=True,
                encoding="utf-8",
            )

            changes = {
                "base_commit": commit_hash,
                "current_commit": self._get_git_info().get("commit", "unknown"),
                "added_files": [],
                "modified_files": [],
                "deleted_files": [],
                "renamed_files": [],
            }

            for line in result.stdout.strip().split("\n"):
                if not line:
                    continue

                parts = line.split("\t")
                status = parts[0]
                file_path = parts[1] if len(parts) > 1 else ""

                if status == "A":
                    changes["added_files"].append(file_path)
                elif status == "M":
                    changes["modified_files"].append(file_path)
                elif status == "D":
                    changes["deleted_files"].append(file_path)
                elif status.startswith("R"):
                    # Renamed file
                    old_path = parts[1] if len(parts) > 1 else ""
                    new_path = parts[2] if len(parts) > 2 else ""
                    changes["renamed_files"].append(
                        {"old_path": old_path, "new_path": new_path}
                    )

            return changes

        except (subprocess.CalledProcessError, FileNotFoundError) as error:
            return {"error": f"Git diff failed: {error}"}

    def generate_change_report(self, comparison_data: Dict[str, Any]) -> str:
        """Generate human-readable change report.

        Parameters
        ----------
        comparison_data : Dict[str, Any]
            Comparison data from compare_snapshots or get_changes_since_commit.

        Returns
        -------
        str
            Formatted change report.
        """
        report_lines = [
            "# File Change Analysis Report",
            "",
            # INFRASTRUCTURE CHANGE: Fixed critical timestamp mislabeling issue
            # Was: datetime.now().strftime('%Y-%m-%d %H:%M:%S UTC') - claimed UTC
            # but used local time
            # Now: get_utc_display_timestamp() - actual UTC for GitHub API sync
            # Evidence: 3-minute discrepancies in diagnostic timeline analysis
            f"**Generated**: {get_utc_display_timestamp()}",
            "",
        ]

        if "summary" in comparison_data:
            # Snapshot comparison report
            summary = comparison_data["summary"]
            report_lines.extend(
                [
                    "## Summary",
                    "",
                    f"- **Total files in baseline**: {summary['total_files_baseline']}",
                    f"- **Total files in comparison**: "
                    f"{summary['total_files_comparison']}",
                    f"- **Net change**: {summary['net_file_change']} files",
                    f"- **Files added**: {summary['files_added']}",
                    f"- **Files deleted**: {summary['files_deleted']}",
                    f"- **Files modified**: {summary['files_modified']}",
                    f"- **Files unchanged**: {summary['files_unchanged']}",
                    "",
                ]
            )

            # Added files
            if comparison_data["added_files"]:
                report_lines.extend(["## Added Files", ""])
                for file_info in comparison_data["added_files"]:
                    size_kb = file_info["size"] / 1024
                    report_lines.append(f"- `{file_info['path']}` ({size_kb:.1f} KB)")
                report_lines.append("")

            # Modified files
            if comparison_data["modified_files"]:
                report_lines.extend(["## Modified Files", ""])
                for file_info in comparison_data["modified_files"]:
                    size_change = file_info["size_change"]
                    change_indicator = (
                        f"+{size_change}" if size_change >= 0 else str(size_change)
                    )
                    report_lines.append(
                        f"- `{file_info['path']}` ({change_indicator} bytes)"
                    )
                report_lines.append("")

            # Deleted files
            if comparison_data["deleted_files"]:
                report_lines.extend(["## Deleted Files", ""])
                for file_info in comparison_data["deleted_files"]:
                    size_kb = file_info["size"] / 1024
                    report_lines.append(f"- `{file_info['path']}` ({size_kb:.1f} KB)")
                report_lines.append("")

        else:
            # Git diff report
            report_lines.extend(
                [
                    "## Git Changes",
                    "",
                    f"**Base commit**: {comparison_data.get('base_commit', 'unknown')}",
                    f"**Current commit**: "
                    f"{comparison_data.get('current_commit', 'unknown')}",
                    "",
                ]
            )

            for change_type, files in comparison_data.items():
                if change_type in ["base_commit", "current_commit", "error"]:
                    continue

                if files:
                    section_title = change_type.replace("_", " ").title()
                    report_lines.extend([f"### {section_title}", ""])

                    if isinstance(files[0], dict) and "old_path" in files[0]:
                        # Renamed files
                        for file_info in files:
                            report_lines.append(
                                f"- `{file_info['old_path']}` → "
                                f"`{file_info['new_path']}`"
                            )
                    else:
                        # Regular file list
                        for file_path in files:
                            report_lines.append(f"- `{file_path}`")

                    report_lines.append("")

        return "\n".join(report_lines)

    def cleanup_old_snapshots(self, keep_count: int = 50) -> int:
        """Clean up old snapshots to prevent storage bloat.

        Parameters
        ----------
        keep_count : int
            Number of recent snapshots to keep.

        Returns
        -------
        int
            Number of snapshots removed.
        """
        snapshots = list(self.version_data["snapshots"].keys())

        if len(snapshots) <= keep_count:
            return 0

        # Sort by timestamp (assuming snapshot names include timestamps)
        snapshots.sort()

        # Remove oldest snapshots
        snapshots_to_remove = snapshots[:-keep_count]

        for snapshot_id in snapshots_to_remove:
            del self.version_data["snapshots"][snapshot_id]

        self._save_version_data()

        return len(snapshots_to_remove)


def main():
    """Main function for file version tracker script."""
    import argparse

    parser = argparse.ArgumentParser(description="Track file versions for AAR analysis")
    parser.add_argument(
        "--create-snapshot", help="Create a new snapshot with given name"
    )
    parser.add_argument(
        "--compare",
        nargs=2,
        metavar=("SNAPSHOT1", "SNAPSHOT2"),
        help="Compare two snapshots",
    )
    parser.add_argument(
        "--git-diff", metavar="COMMIT", help="Show changes since Git commit"
    )
    parser.add_argument(
        "--cleanup",
        type=int,
        metavar="COUNT",
        help="Clean up old snapshots, keeping COUNT recent ones",
    )
    parser.add_argument(
        "--list-snapshots", action="store_true", help="List all available snapshots"
    )

    args = parser.parse_args()

    # Validate virtual environment
    if not sys.prefix.endswith(".venv"):
        print("ERROR: Must run in virtual environment (.venv)")
        print("Run: source .venv/bin/activate")
        sys.exit(1)

    try:
        tracker = FileVersionTracker()

        if args.create_snapshot:
            snapshot_id = tracker.create_snapshot(args.create_snapshot)
            print(f"Created snapshot: {snapshot_id}")

        elif args.compare:
            comparison = tracker.compare_snapshots(args.compare[0], args.compare[1])
            report = tracker.generate_change_report(comparison)
            print(report)

        elif args.git_diff:
            changes = tracker.get_changes_since_commit(args.git_diff)
            if "error" in changes:
                print(f"Error: {changes['error']}")
                sys.exit(1)
            else:
                report = tracker.generate_change_report(changes)
                print(report)

        elif args.cleanup:
            removed_count = tracker.cleanup_old_snapshots(args.cleanup)
            print(f"Removed {removed_count} old snapshots")

        elif args.list_snapshots:
            snapshots = list(tracker.version_data["snapshots"].keys())
            if snapshots:
                print("Available snapshots:")
                for snapshot_id in sorted(snapshots):
                    snapshot_data = tracker.version_data["snapshots"][snapshot_id]
                    timestamp = snapshot_data.get("timestamp", "unknown")
                    file_count = len(snapshot_data.get("files", {}))
                    print(f"  {snapshot_id} ({timestamp}, {file_count} files)")
            else:
                print("No snapshots available")

        else:
            # Default: create current snapshot
            snapshot_id = tracker.create_snapshot("current")
            print(f"Created current snapshot: {snapshot_id}")

    except Exception as error:
        print(f"ERROR: File tracking failed: {error}")
        sys.exit(1)


if __name__ == "__main__":
    main()
