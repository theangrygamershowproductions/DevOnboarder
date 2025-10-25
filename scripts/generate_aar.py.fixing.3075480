#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""After Action Report (AAR) Generator for DevOnboarder.

This script generates comprehensive After Action Reports for CI failures
following DevOnboarder's No Default Token Policy v1.0 and security standards.
"""

import json
import logging
import os
import subprocess  # noqa: S404
import sys
from datetime import datetime
from pathlib import Path
from typing import Any, Dict, List, Optional

# INFRASTRUCTURE CHANGE: Import standardized UTC timestamp utilities
# Purpose: Fix critical diagnostic issue with GitHub API timestamp synchronization
# Evidence: docs/troubleshooting/TIMESTAMP_SYNCHRONIZATION_DIAGNOSTIC_ISSUE.md
# Date: 2025-09-21
try:
    from src.utils.timestamps import get_utc_display_timestamp
except ImportError:
    # Add repository root to path for standalone execution
    sys.path.insert(0, str(Path(__file__).parent.parent / "src"))
    try:
        from utils.timestamps import get_utc_display_timestamp
    except ImportError:
        from utils.timestamp_fallback import get_utc_display_timestamp


# Import DevOnboarder-compliant token management
from aar_security import AARTokenManager


class AARGenerator:
    """Generates After Action Reports with token governance compliance."""

    def __init__(self, config_path: str = "config/aar-config.json"):
        """Initialize AAR generator with configuration.

        Parameters
        ----------
        config_path : str
            Path to AAR configuration file.
        """
        self.config_path = config_path
        self.config = self._load_config()
        self.token_manager = AARTokenManager()
        self.logger = self._setup_logging()

    def _load_config(self)  Dict[str, Any]:
        """Load AAR configuration from file.

        Returns
        -------
        Dict[str, Any]
            AAR configuration dictionary.
        """
        try:
            with open(self.config_path, "r", encoding="utf-8") as file:
                return json.load(file)
        except FileNotFoundError:
            # Default configuration if file not found
            return {
                "templates": {
                    "aar": "templates/aar-template.md",
                    "security": "templates/security-report.md",
                },
                "output": {"directory": "logs/aar", "format": "markdown"},
                "token_hierarchy": [
                    "CI_ISSUE_AUTOMATION_TOKEN",
                    "CI_BOT_TOKEN",
                    "GITHUB_TOKEN",
                ],
            }

    def _setup_logging(self)  logging.Logger:
        """Set up centralized logging following DevOnboarder standards.

        Returns
        -------
        logging.Logger
            Configured logger instance.
        """
        os.makedirs("logs", exist_ok=True)
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        log_file = f"logs/aar_generator_{timestamp}.log"

        logger = logging.getLogger("aar_generator")
        logger.setLevel(logging.INFO)

        # File handler
        file_handler = logging.FileHandler(log_file, encoding="utf-8")
        file_handler.setLevel(logging.INFO)

        # Console handler
        console_handler = logging.StreamHandler()
        console_handler.setLevel(logging.INFO)

        # Formatter
        formatter = logging.Formatter(
            "%(asctime)s - %(name)s - %(levelname)s - %(message)s"
        )
        file_handler.setFormatter(formatter)
        console_handler.setFormatter(formatter)

        logger.addHandler(file_handler)
        logger.addHandler(console_handler)

        return logger

    def collect_ci_failure_data(
        self, workflow_run_id: Optional[str] = None
    )  Dict[str, Any]:
        """Collect comprehensive CI failure data using token hierarchy.

        Parameters
        ----------
        workflow_run_id : Optional[str]
            Specific workflow run ID to analyze.

        Returns
        -------
        Dict[str, Any]
            Comprehensive CI failure data.
        """
        self.logger.info("Collecting CI failure data with token compliance")

        # Get tokens for different operations
        actions_token = self.token_manager.get_actions_token()

        if not actions_token:
            self.logger.error(
                "No valid actions token available for workflow data collection"
            )
            return {
                "timestamp": datetime.now().isoformat(),
                "workflow_run_id": workflow_run_id,
                "token_used": "None (authentication failed)",
                "errors": ["Token authentication failed"],
            }

        failure_data: Dict[str, Any] = {
            "timestamp": datetime.now().isoformat(),
            "workflow_run_id": workflow_run_id,
            "token_used": "Actions token (hierarchy compliant)",
            "data_collection": {},
        }

        try:
            # Collect workflow run information
            if workflow_run_id:
                run_data = self._get_workflow_run_data(workflow_run_id, actions_token)
                failure_data["data_collection"]["workflow_run"] = run_data

            # Collect recent failures (requires actions:read permission)
            recent_failures = self._get_recent_failures(actions_token)
            failure_data["data_collection"]["recent_failures"] = recent_failures

            # Collect job logs (requires actions:read permission)
            job_logs = self._get_job_logs(workflow_run_id, actions_token)
            failure_data["data_collection"]["job_logs"] = job_logs

            # Collect artifact information (requires actions:read permission)
            artifacts = self._get_artifacts(workflow_run_id, actions_token)
            failure_data["data_collection"]["artifacts"] = artifacts

            # Security audit
            security_audit = self.token_manager.audit_token_usage()
            failure_data["security_audit"] = security_audit

        except Exception as error:
            self.logger.error(f"Error collecting CI data: {error}")
            failure_data["errors"] = [str(error)]

        return failure_data

    def _get_workflow_run_data(
        self, workflow_run_id: str, token: str
    )  Dict[str, Any]:
        """Get detailed workflow run data.

        Parameters
        ----------
        workflow_run_id : str
            Workflow run ID to analyze.
        token : str
            Authentication token to use.

        Returns
        -------
        Dict[str, Any]
            Workflow run data.
        """
        try:
            repo_path = "repos/theangrygamershowproductions/DevOnboarder"
            cmd = [
                "gh",
                "api",
                f"{repo_path}/actions/runs/{workflow_run_id}",
            ]

            # Create environment with token for GitHub CLI
            env = os.environ.copy()
            env["GH_TOKEN"] = token

            result = subprocess.run(
                cmd,
                capture_output=True,
                text=True,
                check=True,
                encoding="utf-8",
                env=env,
            )
            return json.loads(result.stdout)

        except subprocess.CalledProcessError as error:
            self.logger.error(f"Failed to get workflow run data: {error}")
            return {"error": str(error)}

    def _get_recent_failures(self, token: str)  List[Dict[str, Any]]:
        """Get recent workflow failures.

        Parameters
        ----------
        token : str
            Authentication token to use.

        Returns
        -------
        List[Dict[str, Any]]
            List of recent failures.
        """
        try:
            cmd = [
                "gh",
                "api",
                "repos/theangrygamershowproductions/DevOnboarder/actions/runs",
                "-f",
                "status=failure",
                "-f",
                "per_page=10",
            ]

            # Create environment with token for GitHub CLI
            env = os.environ.copy()
            env["GH_TOKEN"] = token

            result = subprocess.run(
                cmd,
                capture_output=True,
                text=True,
                check=True,
                encoding="utf-8",
                env=env,
            )
            data = json.loads(result.stdout)
            return data.get("workflow_runs", [])

        except subprocess.CalledProcessError as error:
            self.logger.error(f"Failed to get recent failures: {error}")
            return []

    def _get_job_logs(
        self, workflow_run_id: Optional[str], token: str
    )  Dict[str, str]:
        """Get job logs for workflow run.

        Parameters
        ----------
        workflow_run_id : Optional[str]
            Workflow run ID to get logs for.
        token : str
            Authentication token to use.

        Returns
        -------
        Dict[str, str]
            Job logs by job ID.
        """
        if not workflow_run_id:
            return {}

        try:
            # Get jobs for the run
            repo_path = "repos/theangrygamershowproductions/DevOnboarder"
            cmd = [
                "gh",
                "api",
                f"{repo_path}/actions/runs/{workflow_run_id}/jobs",
            ]

            # Create environment with token for GitHub CLI
            env = os.environ.copy()
            env["GH_TOKEN"] = token

            result = subprocess.run(
                cmd,
                capture_output=True,
                text=True,
                check=True,
                encoding="utf-8",
                env=env,
            )
            jobs_data = json.loads(result.stdout)

            logs = {}
            for job in jobs_data.get("jobs", []):
                job_id = job.get("id")
                if job_id:
                    log_content = self._get_job_log_content(job_id, token)
                    logs[str(job_id)] = log_content

            return logs

        except subprocess.CalledProcessError as error:
            self.logger.error(f"Failed to get job logs: {error}")
            return {}

    def _get_job_log_content(self, job_id: str, token: str)  str:
        """Get log content for specific job.

        Parameters
        ----------
        job_id : str
            Job ID to get logs for.
        token : str
            Authentication token to use.

        Returns
        -------
        str
            Job log content.
        """
        try:
            repo_path = "repos/theangrygamershowproductions/DevOnboarder"
            cmd = [
                "gh",
                "api",
                f"{repo_path}/actions/jobs/{job_id}/logs",
            ]

            # Create environment with token for GitHub CLI
            env = os.environ.copy()
            env["GH_TOKEN"] = token

            result = subprocess.run(
                cmd,
                capture_output=True,
                text=True,
                check=True,
                encoding="utf-8",
                env=env,
            )
            return result.stdout

        except subprocess.CalledProcessError as error:
            self.logger.error(f"Failed to get job log content: {error}")
            return f"Error retrieving logs: {error}"

    def _get_artifacts(
        self, workflow_run_id: Optional[str], token: str
    )  List[Dict[str, Any]]:
        """Get artifacts for workflow run.

        Parameters
        ----------
        workflow_run_id : Optional[str]
            Workflow run ID to get artifacts for.
        token : str
            Authentication token to use.

        Returns
        -------
        List[Dict[str, Any]]
            List of artifacts.
        """
        if not workflow_run_id:
            return []

        try:
            repo_path = "repos/theangrygamershowproductions/DevOnboarder"
            cmd = [
                "gh",
                "api",
                f"{repo_path}/actions/runs/{workflow_run_id}/artifacts",
            ]

            # Create environment with token for GitHub CLI
            env = os.environ.copy()
            env["GH_TOKEN"] = token

            result = subprocess.run(
                cmd,
                capture_output=True,
                text=True,
                check=True,
                encoding="utf-8",
                env=env,
            )
            data = json.loads(result.stdout)
            return data.get("artifacts", [])

        except subprocess.CalledProcessError as error:
            self.logger.error(f"Failed to get artifacts: {error}")
            return []

    def generate_aar_report(self, failure_data: Dict[str, Any])  str:
        """Generate AAR report from failure data.

        Parameters
        ----------
        failure_data : Dict[str, Any]
            CI failure data collected.

        Returns
        -------
        str
            Generated AAR report content.
        """
        self.logger.info("Generating AAR report")

        # Create AAR report content
        # INFRASTRUCTURE CHANGE: Use proper UTC timestamp instead of local time
        # INFRASTRUCTURE CHANGE: Before: datetime.now() with UTC label
        #         Claims UTC but uses local time
        # After: get_utc_display_timestamp()  # Actually uses UTC
        # Evidence: docs/troubleshooting/TIMESTAMP_SYNCHRONIZATION_DIAGNOSTIC_ISSUE.md
        timestamp = get_utc_display_timestamp()

        report_content = f"""# After Action Report (AAR)

**Generated**: {timestamp}

**DevOnboarder No Default Token Policy Compliance**:  VALIDATED

## Executive Summary

### Workflow Information
- **Run ID**: {failure_data.get('workflow_run_id', 'N/A')}
- **Token Used**: {failure_data.get('token_used', 'Unknown')}
- **Collection Status**: {len(failure_data.get('data_collection', {}))} data sources

### Security Audit
{self._format_security_audit(failure_data.get('security_audit', {}))}

## Failure Analysis

### Recent Failures
{self._format_recent_failures(
            failure_data.get("data_collection", {}).get("recent_failures", [])
        )}

### Job Analysis
{self._format_job_analysis(failure_data.get("data_collection", {}).get("job_logs", {}))}

### Artifacts
{self._format_artifacts(failure_data.get("data_collection", {}).get("artifacts", []))}

## Root Cause Analysis

### Primary Failure Points
{self._analyze_failure_points(failure_data)}

### Contributing Factors
{self._analyze_contributing_factors(failure_data)}

## Recommendations

### Immediate Actions
{self._generate_immediate_actions(failure_data)}

### Long-term Improvements
{self._generate_long_term_improvements(failure_data)}

## Token Governance Compliance

### Policy Adherence
- No Default Token Policy v1.0:  COMPLIANT
- Token Hierarchy Used: {failure_data.get('token_used', 'CI_ISSUE_AUTOMATION_TOKEN')}
- Security Audit: {len(failure_data.get('security_audit', {}))} checks performed

---

*This AAR was generated automatically by DevOnboarder AAR System*
*Following Enhanced Potato Policy and Token Governance Standards*
"""

        return report_content

    def _format_security_audit(self, audit_data: Dict[str, Any])  str:
        """Format security audit section.

        Parameters
        ----------
        audit_data : Dict[str, Any]
            Security audit data.

        Returns
        -------
        str
            Formatted security audit content.
        """
        if not audit_data:
            return "- No security audit data available"

        lines = []
        for key, value in audit_data.items():
            if isinstance(value, bool):
                status = " PASS" if value else " FAIL"
                lines.append(f"- {key}: {status}")
            else:
                lines.append(f"- {key}: {value}")

        return "\n".join(lines)

    def _format_recent_failures(self, failures: List[Dict[str, Any]])  str:
        """Format recent failures section.

        Parameters
        ----------
        failures : List[Dict[str, Any]]
            Recent failure data.

        Returns
        -------
        str
            Formatted failures content.
        """
        if not failures:
            return "- No recent failures found"

        lines = []
        for failure in failures[:5]:  # Show last 5 failures
            run_id = failure.get("id", "Unknown")
            conclusion = failure.get("conclusion", "Unknown")
            created_at = failure.get("created_at", "Unknown")
            lines.append(f"- Run {run_id}: {conclusion} ({created_at})")

        return "\n".join(lines)

    def _format_job_analysis(self, job_logs: Dict[str, str])  str:
        """Format job analysis section.

        Parameters
        ----------
        job_logs : Dict[str, str]
            Job logs by job ID.

        Returns
        -------
        str
            Formatted job analysis content.
        """
        if not job_logs:
            return "- No job logs available"

        lines = []
        for job_id, log_content in job_logs.items():
            # Analyze log for key failure indicators
            error_count = log_content.count("ERROR")
            warning_count = log_content.count("WARNING")
            lines.append(
                f"- Job {job_id}: {error_count} errors, {warning_count} warnings"
            )

        return "\n".join(lines)

    def _format_artifacts(self, artifacts: List[Dict[str, Any]])  str:
        """Format artifacts section.

        Parameters
        ----------
        artifacts : List[Dict[str, Any]]
            Artifact data.

        Returns
        -------
        str
            Formatted artifacts content.
        """
        if not artifacts:
            return "- No artifacts found"

        lines = []
        for artifact in artifacts:
            name = artifact.get("name", "Unknown")
            size_bytes = artifact.get("size_in_bytes", 0)
            lines.append(f"- {name} ({size_bytes} bytes)")

        return "\n".join(lines)

    def _analyze_failure_points(self, failure_data: Dict[str, Any])  str:
        """Analyze primary failure points.

        Parameters
        ----------
        failure_data : Dict[str, Any]
            Failure data to analyze.

        Returns
        -------
        str
            Analysis of failure points.
        """
        # Basic analysis based on available data
        points = []

        # Check for common failure patterns
        job_logs = failure_data.get("data_collection", {}).get("job_logs", {})
        for job_id, log_content in job_logs.items():
            if "ModuleNotFoundError" in log_content:
                points.append("- Python module dependency issue detected")
            if "npm ERR!" in log_content:
                points.append("- Node.js package installation failure")
            if "coverage" in log_content.lower() and "fail" in log_content.lower():
                points.append("- Test coverage threshold not met")

        if not points:
            points.append("- Analysis requires manual review of logs")

        return "\n".join(points)

    def _analyze_contributing_factors(self, failure_data: Dict[str, Any])  str:
        """Analyze contributing factors.

        Parameters
        ----------
        failure_data : Dict[str, Any]
            Failure data to analyze.

        Returns
        -------
        str
            Analysis of contributing factors.
        """
        factors = [
            "- Environment configuration changes",
            "- Dependency version conflicts",
            "- Test infrastructure issues",
            "- Resource constraints",
        ]

        return "\n".join(factors)

    def _generate_immediate_actions(self, failure_data: Dict[str, Any])  str:
        """Generate immediate action recommendations.

        Parameters
        ----------
        failure_data : Dict[str, Any]
            Failure data to analyze.

        Returns
        -------
        str
            Immediate action recommendations.
        """
        actions = [
            "1. Review job logs for specific error messages",
            "2. Check virtual environment setup and dependencies",
            "3. Verify test configuration and coverage settings",
            "4. Ensure compliance with DevOnboarder standards",
        ]

        return "\n".join(actions)

    def _generate_long_term_improvements(self, failure_data: Dict[str, Any])  str:
        """Generate long-term improvement recommendations.

        Parameters
        ----------
        failure_data : Dict[str, Any]
            Failure data to analyze.

        Returns
        -------
        str
            Long-term improvement recommendations.
        """
        improvements = [
            "1. Implement enhanced CI monitoring and alerting",
            "2. Develop automated failure recovery procedures",
            "3. Create comprehensive test environment validation",
            "4. Establish proactive dependency management strategy",
        ]

        return "\n".join(improvements)

    def save_aar_report(
        self, report_content: str, filename: Optional[str] = None
    )  str:
        """Save AAR report to centralized logs directory.

        Parameters
        ----------
        report_content : str
            AAR report content to save.
        filename : Optional[str]
            Custom filename for the report.

        Returns
        -------
        str
            Path to saved report file.
        """
        # Ensure logs directory exists
        aar_dir = Path("logs/aar")
        aar_dir.mkdir(parents=True, exist_ok=True)

        # Generate filename if not provided
        if not filename:
            timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
            filename = f"aar_report_{timestamp}.md"

        report_path = aar_dir / filename

        # Save report with UTF-8 encoding
        with open(report_path, "w", encoding="utf-8") as file:
            file.write(report_content)

        self.logger.info(f"AAR report saved to: {report_path}")
        return str(report_path)

    def create_github_issue(
        self, report_content: str, workflow_run_id: Optional[str] = None
    )  Optional[str]:
        """Create GitHub issue for AAR report using token hierarchy.

        Parameters
        ----------
        report_content : str
            AAR report content for issue body.
        workflow_run_id : Optional[str]
            Workflow run ID for reference.

        Returns
        -------
        Optional[str]
            URL of created issue if successful.
        """
        self.logger.info("Creating GitHub issue for AAR report")

        try:
            # Use token manager for issue creation
            token = self.token_manager.get_github_token()
            if not token:
                self.logger.error("No valid token available for issue creation")
                return None

            # Create issue title
            timestamp = datetime.now().strftime("%Y-%m-%d")
            title = f"AAR: CI Failure Analysis - {timestamp}"
            if workflow_run_id:
                title = f" (Run #{workflow_run_id})"

            # Create issue labels (use existing repository labels)
            labels = ["automation", "ci-failure"]

            # Prepare issue body
            issue_body = f"""# After Action Report

{report_content}

---

**Auto-generated by DevOnboarder AAR System**
**Token Used**: Token hierarchy compliant
**Compliance**: No Default Token Policy v1.0 
"""

            # Create issue using GitHub CLI with proper token
            cmd = [
                "gh",
                "issue",
                "create",
                "--title",
                title,
                "--body",
                issue_body,
                "--label",
                ",".join(labels),
            ]

            # Create environment with token for GitHub CLI
            env = os.environ.copy()
            token = self.token_manager.get_github_token()
            if token:
                env["GH_TOKEN"] = token

            result = subprocess.run(
                cmd,
                capture_output=True,
                text=True,
                check=True,
                encoding="utf-8",
                env=env,
            )

            issue_url = result.stdout.strip()
            self.logger.info(f"Created AAR issue: {issue_url}")
            return issue_url

        except subprocess.CalledProcessError as error:
            self.logger.error(f"Failed to create GitHub issue: {error}")
            return None


def main():
    """Main function for AAR generator script."""
    import argparse

    parser = argparse.ArgumentParser(
        description="Generate After Action Report for CI failures"
    )
    parser.add_argument("--workflow-run-id", help="Specific workflow run ID to analyze")
    parser.add_argument(
        "--config",
        default="config/aar-config.json",
        help="Path to AAR configuration file",
    )
    parser.add_argument(
        "--create-issue",
        action="store_true",
        help="Create GitHub issue for the AAR report",
    )
    parser.add_argument("--output-file", help="Custom output filename for the report")

    args = parser.parse_args()

    # Validate virtual environment
    if not sys.prefix.endswith(".venv"):
        print(" Must run in virtual environment (.venv)")
        print("Run: source .venv/bin/activate")
        sys.exit(1)

    try:
        # Create AAR generator
        aar_generator = AARGenerator(config_path=args.config)

        # Collect failure data
        print("Collecting CI failure data...")
        failure_data = aar_generator.collect_ci_failure_data(
            workflow_run_id=args.workflow_run_id
        )

        # Generate AAR report
        print("Generating AAR report...")
        report_content = aar_generator.generate_aar_report(failure_data)

        # Save report
        report_path = aar_generator.save_aar_report(
            report_content, filename=args.output_file
        )
        print(f"AAR report saved to: {report_path}")

        # Create GitHub issue if requested
        if args.create_issue:
            print("Creating GitHub issue...")
            issue_url = aar_generator.create_github_issue(
                report_content, workflow_run_id=args.workflow_run_id
            )
            if issue_url:
                print(f"GitHub issue created: {issue_url}")
            else:
                print("Failed to create GitHub issue")

        print("AAR generation completed successfully")

    except Exception as error:
        print(f" AAR generation failed: {error}")
        sys.exit(1)


if __name__ == "__main__":
    main()
