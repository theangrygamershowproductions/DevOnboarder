#!/usr/bin/env python3
"""
DevOnboarder CI Debugging Wrapper

A unified tool for downloading and analyzing CI reports, logs, and artifacts.
Simplifies debugging CI failures by providing easy access to all relevant information.

Usage:
    python scripts/ci_debug_wrapper.py [command] [options]

Commands:
    status          - Show current CI status and recent runs
    logs            - Download logs for specific run or latest failed run
    artifacts       - Download CI artifacts (coverage, test results, etc.)
    report          - Generate comprehensive CI debugging report
    failures        - Analyze and summarize CI failures
    watch           - Monitor CI runs in real-time

Examples:
    python scripts/ci_debug_wrapper.py status
    python scripts/ci_debug_wrapper.py logs --run-id 1234567890
    python scripts/ci_debug_wrapper.py artifacts --latest-failed
    python scripts/ci_debug_wrapper.py report --output ci_debug_report.md
"""

import argparse
import json
import subprocess  # nosec B404 - Only calls trusted 'gh' command
import sys
from datetime import datetime, timezone
from pathlib import Path
from typing import Dict, List, Optional, Any

# Import centralized timestamp utilities
try:
    from src.utils.timestamps import get_utc_display_timestamp
except ImportError:
    # Fallback for when running outside the package
    def get_utc_display_timestamp():
        return datetime.now(timezone.utc).strftime("%Y-%m-%d %H:%M:%S UTC")


class CIDebugWrapper:
    """Wrapper for CI debugging operations."""

    def __init__(
        self,
        repo_owner: str = "theangrygamershowproductions",
        repo_name: str = "DevOnboarder",
    ):
        self.repo_owner = repo_owner
        self.repo_name = repo_name
        self.base_dir = Path(__file__).parent.parent
        # Follow project rules: centralized logging to logs/ directory
        self.output_dir = self.base_dir / "logs"
        self.output_dir.mkdir(exist_ok=True)

    def run_gh_command(
        self, args: List[str], capture_output: bool = True
    ) -> subprocess.CompletedProcess:
        """Run a GitHub CLI command."""
        cmd = ["gh"] + args
        try:
            result = subprocess.run(  # nosec B603 - args come from trusted code
                cmd, capture_output=capture_output, text=True, check=True
            )
            return result
        except subprocess.CalledProcessError as e:
            print(f"GitHub CLI command failed: {' '.join(cmd)}")
            print(f"Error: {e}")
            if e.stdout:
                print(f"stdout: {e.stdout}")
            if e.stderr:
                print(f"stderr: {e.stderr}")
            raise

    def get_workflow_runs(self, limit: int = 10) -> List[Dict[str, Any]]:
        """Get recent workflow runs."""
        result = self.run_gh_command(
            [
                "run",
                "list",
                "--json",
                "status,conclusion,headSha,createdAt,updatedAt,"
                "headBranch,databaseId",
                "--limit",
                str(limit),
            ]
        )

        runs = json.loads(result.stdout)
        return runs

    def get_run_details(self, run_id: str) -> Optional[Dict[str, Any]]:
        """Get run details by ID or commit SHA."""
        # First try to use run_id directly as a run database ID
        try:
            result = self.run_gh_command(
                [
                    "run",
                    "view",
                    run_id,
                    "--json",
                    "databaseId,headSha,status,conclusion,jobs",
                ]
            )
            run_data = json.loads(result.stdout)
            return run_data
        except subprocess.CalledProcessError:
            # If direct lookup fails, try to find run by commit SHA
            runs = self.get_workflow_runs(limit=20)
            for run in runs:
                if run["headSha"].startswith(run_id):
                    # Found matching run, get full details
                    try:
                        result = self.run_gh_command(
                            [
                                "run",
                                "view",
                                str(run["databaseId"]),
                                "--json",
                                "databaseId,headSha,status,conclusion,jobs",
                            ]
                        )
                        run_data = json.loads(result.stdout)
                        return run_data
                    except subprocess.CalledProcessError:
                        continue
            return None

    def get_workflow_jobs(self, run_id: str) -> List[Dict[str, Any]]:
        """Get jobs for a specific workflow run."""
        run_data = self.get_run_details(run_id)
        if not run_data:
            return []
        return run_data.get("jobs", [])

    def download_job_logs(
        self, job_id: int, output_file: Path, run_database_id: str
    ) -> None:
        """Download logs for a specific job."""
        print(f"Downloading logs for job {job_id} to {output_file}")

        result = self.run_gh_command(["run", "view", "--job", str(job_id), "--log"])

        with open(output_file, "w", encoding="utf-8") as f:
            f.write(result.stdout)

    def download_artifacts(self, run_id: str, output_dir: Path) -> None:
        """Download artifacts for a workflow run."""
        run_data = self.get_run_details(run_id)
        if not run_data:
            print(f"Could not find run details for {run_id}")
            return

        actual_run_id = str(run_data["databaseId"])
        print(f"Downloading artifacts for run {actual_run_id} to {output_dir}")

        # List artifacts
        result = self.run_gh_command(
            ["run", "view", actual_run_id, "--json", "artifacts"]
        )

        data = json.loads(result.stdout)
        artifacts = data.get("artifacts", [])

        if not artifacts:
            print("No artifacts found for this run.")
            return

        for artifact in artifacts:
            artifact_name = artifact["name"]
            artifact_id = artifact["databaseId"]

            print(f"Downloading artifact: {artifact_name}")

            # Download artifact
            self.run_gh_command(
                [
                    "run",
                    "download",
                    str(artifact_id),
                    "--dir",
                    str(output_dir / artifact_name),
                ]
            )

    def get_latest_failed_run(self) -> Optional[Dict[str, Any]]:
        """Get the latest failed workflow run."""
        runs = self.get_workflow_runs(limit=20)

        for run in runs:
            if run["conclusion"] == "failure":
                return run

        return None

    def generate_status_report(self) -> str:
        """Generate a status report of recent CI runs."""
        runs = self.get_workflow_runs(limit=10)

        report = ["# CI Status Report", ""]
        report.append(f"Generated: {get_utc_display_timestamp()}")
        report.append("")

        if not runs:
            report.append("No recent workflow runs found.")
            return "\n".join(report)

        report.append("| Status | Branch | Commit | Created | Duration |")
        report.append("|--------|--------|--------|---------|----------|")

        for run in runs:
            status = run["status"]
            conclusion = run.get("conclusion", "")
            branch = run.get("headBranch", "unknown")
            commit = run["headSha"][:8]
            created = run["createdAt"]
            updated = run.get("updatedAt", created)

            # Calculate duration
            try:
                created_dt = datetime.fromisoformat(created.replace("Z", "+00:00"))
                updated_dt = datetime.fromisoformat(updated.replace("Z", "+00:00"))
                duration = updated_dt - created_dt
                duration_str = f"{duration.seconds}s"
            except Exception:
                duration_str = "unknown"

            status_display = f"{status}/{conclusion}" if conclusion else status
            report.append(
                f"| {status_display} | {branch} | {commit} | {created} | "
                f"{duration_str} |"
            )

        return "\n".join(report)

    def generate_failure_analysis(self, run_id: str) -> str:
        """Generate detailed failure analysis for a run."""
        jobs = self.get_workflow_jobs(run_id)

        report = [f"# CI Failure Analysis - Run {run_id}", ""]
        report.append(f"Generated: {get_utc_display_timestamp()}")
        report.append("")

        failed_jobs = [job for job in jobs if job.get("conclusion") == "failure"]

        if not failed_jobs:
            report.append("No failed jobs found in this run.")
            return "\n".join(report)

        report.append(f"Found {len(failed_jobs)} failed job(s):")
        report.append("")

        for job in failed_jobs:
            job_name = job["name"]
            job_id = job["databaseId"]
            started_at = job.get("startedAt", "unknown")
            completed_at = job.get("completedAt", "unknown")

            report.append(f"## Failed Job: {job_name}")
            report.append(f"- Job ID: {job_id}")
            report.append(f"- Started: {started_at}")
            report.append(f"- Completed: {completed_at}")
            report.append("")

            # Try to get some log snippets
            try:
                log_file = self.output_dir / f"job_{job_id}_logs.txt"
                run_data = self.get_run_details(run_id)
                actual_run_id = str(run_data["databaseId"]) if run_data else run_id
                self.download_job_logs(job_id, log_file, actual_run_id)

                # Extract error patterns from logs
                with open(log_file, "r") as f:
                    log_content = f.read()

                # Look for common error patterns
                error_lines = []
                for line in log_content.split("\n")[-100:]:  # Last 100 lines
                    if any(
                        keyword in line.lower()
                        for keyword in [
                            "error",
                            "failed",
                            "failure",
                            "exception",
                            "traceback",
                        ]
                    ):
                        error_lines.append(line.strip())

                if error_lines:
                    report.append("### Recent Errors:")
                    for error in error_lines[-5:]:  # Last 5 errors
                        report.append(f"  - {error}")
                    report.append("")

            except Exception as e:
                report.append(f"Could not download logs: {e}")
                report.append("")

        return "\n".join(report)

    def cmd_status(self, args):
        """Show CI status."""
        report = self.generate_status_report()
        print(report)

        if args.output:
            with open(args.output, "w") as f:
                f.write(report)
            print(f"\nReport saved to: {args.output}")

    def cmd_logs(self, args):
        """Download logs for a run."""
        run_id = args.run_id
        if not run_id:
            failed_run = self.get_latest_failed_run()
            if failed_run:
                run_id = failed_run["headSha"][:8]
                print(f"Using latest failed run: {run_id}")
            else:
                print("No failed runs found.")
                return

        jobs = self.get_workflow_jobs(run_id)

        for job in jobs:
            job_name = job["name"]
            job_id = job["databaseId"]
            conclusion = job.get("conclusion", "")

            if args.failed_only and conclusion != "failure":
                continue

            output_file = (
                self.output_dir / f"{run_id}_{job_name.replace(' ', '_')}_logs.txt"
            )
            try:
                run_data = self.get_run_details(run_id)
                actual_run_id = str(run_data["databaseId"]) if run_data else run_id
                self.download_job_logs(job_id, output_file, actual_run_id)
                print(f"Downloaded: {output_file}")
            except Exception as e:
                print(f"Failed to download logs for {job_name}: {e}")

    def cmd_artifacts(self, args):
        """Download artifacts for a run."""
        run_id = args.run_id
        if not run_id:
            failed_run = self.get_latest_failed_run()
            if failed_run:
                run_id = failed_run["headSha"][:8]
                print(f"Using latest failed run: {run_id}")
            else:
                print("No failed runs found.")
                return

        artifacts_dir = self.output_dir / f"artifacts_{run_id}"
        artifacts_dir.mkdir(exist_ok=True)

        try:
            self.download_artifacts(run_id, artifacts_dir)
            print(f"Artifacts downloaded to: {artifacts_dir}")
        except Exception as e:
            print(f"Failed to download artifacts: {e}")

    def cmd_report(self, args):
        """Generate comprehensive debugging report."""
        print("Generating comprehensive CI debugging report...")

        run_id = args.run_id
        if not run_id:
            # Get latest failed run if no run_id provided
            failed_run = self.get_latest_failed_run()
            if not failed_run:
                print("No failed runs found to analyze.")
                return
            run_id = failed_run["headSha"][:8]
            print(f"Using latest failed run: {run_id}")

        # Generate failure analysis
        analysis = self.generate_failure_analysis(run_id)

        # Download logs and artifacts
        logs_dir = self.output_dir / f"debug_{run_id}"
        logs_dir.mkdir(exist_ok=True)

        print("Downloading logs and artifacts...")
        try:
            self.cmd_logs(argparse.Namespace(run_id=run_id, failed_only=True))
            self.cmd_artifacts(argparse.Namespace(run_id=run_id))
        except Exception as e:
            print(f"Warning: Could not download all logs/artifacts: {e}")

        # Combine everything into a report
        report_file = args.output or f"ci_debug_report_{run_id}.md"

        with open(report_file, "w", encoding="utf-8") as f:
            f.write("# CI Debugging Report\n\n")
            f.write(f"Run ID: {run_id}\n")
            f.write(f"Generated: {get_utc_display_timestamp()}\n\n")
            f.write(analysis)
            f.write("\n\n## Downloaded Files\n\n")
            f.write(f"- Logs: {self.output_dir}\n")
            f.write(f"- Artifacts: {self.output_dir}/artifacts_{run_id}\n")

        print(f"Report generated: {report_file}")

    def cmd_failures(self, args):  # pylint: disable=unused-argument
        """Analyze CI failures."""
        runs = self.get_workflow_runs(limit=20)
        failed_runs = [run for run in runs if run.get("conclusion") == "failure"]

        if not failed_runs:
            print("No failed runs found.")
            return

        print(f"Found {len(failed_runs)} failed runs:")
        print()

        for run in failed_runs[:5]:  # Show last 5 failures
            run_id = run["headSha"][:8]
            branch = run.get("headBranch", "unknown")
            created = run["createdAt"]

            print(f"Run {run_id} ({branch}) - {created}")
            print(
                f"  Command: python scripts/ci_debug_wrapper.py report "
                f"--run-id {run_id}"
            )
            print()


def main():
    parser = argparse.ArgumentParser(description="DevOnboarder CI Debugging Wrapper")
    subparsers = parser.add_subparsers(dest="command", help="Available commands")

    # Status command
    status_parser = subparsers.add_parser("status", help="Show CI status")
    status_parser.add_argument("--output", "-o", help="Save report to file")

    # Logs command
    logs_parser = subparsers.add_parser("logs", help="Download job logs")
    logs_parser.add_argument("--run-id", help="Specific run ID (8 chars)")
    logs_parser.add_argument(
        "--failed-only", action="store_true", help="Only download failed job logs"
    )

    # Artifacts command
    artifacts_parser = subparsers.add_parser("artifacts", help="Download CI artifacts")
    artifacts_parser.add_argument("--run-id", help="Specific run ID (8 chars)")

    # Report command
    report_parser = subparsers.add_parser("report", help="Generate debugging report")
    report_parser.add_argument("--run-id", help="Specific run ID (8 chars)")
    report_parser.add_argument("--output", "-o", help="Output file")

    # Failures command
    subparsers.add_parser("failures", help="Analyze recent failures")

    args = parser.parse_args()

    if not args.command:
        parser.print_help()
        return

    wrapper = CIDebugWrapper()

    try:
        if args.command == "status":
            wrapper.cmd_status(args)
        elif args.command == "logs":
            wrapper.cmd_logs(args)
        elif args.command == "artifacts":
            wrapper.cmd_artifacts(args)
        elif args.command == "report":
            wrapper.cmd_report(args)
        elif args.command == "failures":
            wrapper.cmd_failures(args)
    except Exception as e:
        print(f"Error: {e}")
        sys.exit(1)


if __name__ == "__main__":
    main()
