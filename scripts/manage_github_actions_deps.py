#!/usr/bin/env python3
"""
GitHub Actions Dependency Management System

Validates and manages GitHub Actions dependencies across all workflow files,
enforcing 30-90 day version windows and security compliance.

Architecture: Aligns with DevOnboarder "work quietly and reliably" philosophy
Security: Integrates with Token Architecture v2.1
Standards: Follows DevOnboarder quality and terminal output policies
"""

import re
import sys
from datetime import datetime, timezone
from pathlib import Path
from typing import Any, Dict, List, Optional, Tuple

import requests
import yaml

# Try to import centralized UTC utilities, fallback if not available
try:
    sys.path.insert(0, str(Path(__file__).parent.parent / "src"))
    from utils.timestamps import get_utc_timestamp

    def get_current_utc() -> datetime:
        """Get current UTC timestamp using centralized utility."""
        # Convert ISO string back to datetime for calculation compatibility
        return datetime.fromisoformat(get_utc_timestamp().replace("Z", "+00:00"))

except ImportError:

    def get_current_utc() -> datetime:
        """Fallback UTC timestamp function."""
        return datetime.now(timezone.utc)


class GitHubActionsDependencyManager:
    """Manages GitHub Actions dependencies with version window validation."""

    def __init__(self, repo_root: Path, window_days: Tuple[int, int] = (30, 90)):
        """
        Initialize the dependency manager.

        Args:
            repo_root: Repository root directory
            window_days: (min_days, max_days) version window for dependencies
        """
        self.repo_root = Path(repo_root)
        self.workflows_dir = self.repo_root / ".github" / "workflows"
        self.min_days, self.max_days = window_days
        self.session = requests.Session()
        self.session.headers.update(
            {
                "Accept": "application/vnd.github.v3+json",
                "User-Agent": "DevOnboarder-Dependency-Manager/1.0",
            }
        )

        # Cache for API responses to avoid rate limiting
        self._cache: Dict[str, Optional[Dict[str, Any]]] = {}

    def validate_all_workflows(self) -> Dict[str, Any]:
        """
        Validate all GitHub Actions dependencies in workflow files.

        Returns:
            Dictionary containing validation results and statistics
        """
        if not self.workflows_dir.exists():
            return {
                "error": "Workflows directory not found",
                "workflows_processed": 0,
                "dependencies_checked": 0,
                "violations": [],
            }

        results = {
            "workflows_processed": 0,
            "dependencies_checked": 0,
            "violations": [],
            "recommendations": [],
            "security_warnings": [],
        }

        workflow_files = list(self.workflows_dir.glob("*.yml")) + list(
            self.workflows_dir.glob("*.yaml")
        )

        for workflow_file in workflow_files:
            try:
                workflow_results = self._validate_workflow_file(workflow_file)
                results["workflows_processed"] += 1
                results["dependencies_checked"] += workflow_results[
                    "dependencies_checked"
                ]
                results["violations"].extend(workflow_results["violations"])
                results["recommendations"].extend(workflow_results["recommendations"])
                results["security_warnings"].extend(
                    workflow_results["security_warnings"]
                )
            except Exception as e:
                results["violations"].append(
                    {
                        "file": str(workflow_file.relative_to(self.repo_root)),
                        "error": f"Failed to parse workflow: {str(e)}",
                        "severity": "error",
                    }
                )

        return results

    def _validate_workflow_file(self, workflow_file: Path) -> Dict[str, Any]:
        """Validate dependencies in a single workflow file."""
        results = {
            "dependencies_checked": 0,
            "violations": [],
            "recommendations": [],
            "security_warnings": [],
        }

        try:
            with open(workflow_file, "r", encoding="utf-8") as f:
                content = f.read()

            # Parse YAML
            try:
                workflow = yaml.safe_load(content)
            except yaml.YAMLError as e:
                results["violations"].append(
                    {
                        "file": str(workflow_file.relative_to(self.repo_root)),
                        "error": f"Invalid YAML: {str(e)}",
                        "severity": "error",
                    }
                )
                return results

            # Extract action dependencies
            actions = self._extract_actions_from_workflow(workflow, content)

            for action_info in actions:
                results["dependencies_checked"] += 1
                violation = self._validate_action_dependency(
                    action_info, str(workflow_file.relative_to(self.repo_root))
                )
                if violation:
                    results["violations"].append(violation)

                # Check for security advisories
                security_warning = self._check_security_advisories(action_info)
                if security_warning:
                    results["security_warnings"].append(security_warning)

                # Generate update recommendations
                recommendation = self._generate_update_recommendation(action_info)
                if recommendation:
                    results["recommendations"].append(recommendation)

        except Exception as e:
            results["violations"].append(
                {
                    "file": str(workflow_file.relative_to(self.repo_root)),
                    "error": f"Error processing file: {str(e)}",
                    "severity": "error",
                }
            )

        return results

    def _extract_actions_from_workflow(
        self, workflow: Dict, content: str
    ) -> List[Dict]:
        """Extract GitHub Actions dependencies from workflow."""
        actions = []

        # Look for 'uses' statements in the YAML content
        uses_pattern = r"uses:\s+([^@\s]+)@([^\s]+)"
        matches = re.findall(uses_pattern, content)

        for action_name, version in matches:
            # Skip local actions (those starting with ./)
            if action_name.startswith("./"):
                continue

            actions.append(
                {
                    "name": action_name,
                    "version": version,
                    "type": self._determine_version_type(version),
                }
            )

        return actions

    def _determine_version_type(self, version: str) -> str:
        """Determine the type of version specification."""
        if re.match(r"^v?\d+$", version):
            return "major"
        elif re.match(r"^v?\d+\.\d+$", version):
            return "minor"
        elif re.match(r"^v?\d+\.\d+\.\d+$", version):
            return "patch"
        elif re.match(r"^[a-f0-9]{40}$", version):
            return "commit_sha"
        elif version in ["main", "master"]:
            return "branch"
        else:
            return "unknown"

    def _validate_action_dependency(
        self, action_info: Dict, workflow_file: str
    ) -> Optional[Dict]:
        """Validate a single action dependency against version windows."""
        action_name = action_info["name"]
        version = action_info["version"]
        version_type = action_info["type"]

        # Skip validation for commit SHAs and branches (they're handled differently)
        if version_type in ["commit_sha", "branch"]:
            if version_type == "branch":
                return {
                    "file": workflow_file,
                    "action": action_name,
                    "version": version,
                    "issue": (
                        f"Using branch reference '{version}' instead of "
                        "tagged version"
                    ),
                    "severity": "warning",
                    "recommendation": "Use specific version tags for better stability",
                }
            return None

        # Get release information for the action
        release_info = self._get_action_release_info(action_name, version)
        if not release_info:
            return {
                "file": workflow_file,
                "action": action_name,
                "version": version,
                "issue": (
                    "Could not validate version - action may not exist or be "
                    "accessible"
                ),
                "severity": "warning",
                "recommendation": "Verify action name and version are correct",
            }

        # Check if version is within acceptable window
        release_date = release_info.get("published_at")
        if not release_date:
            return None

        try:
            release_datetime = datetime.fromisoformat(
                release_date.replace("Z", "+00:00")
            )
            days_old = (get_current_utc() - release_datetime).days

            if days_old > self.max_days:
                return {
                    "file": workflow_file,
                    "action": action_name,
                    "version": version,
                    "issue": (
                        f"Version is {days_old} days old (exceeds "
                        f"{self.max_days} day limit)"
                    ),
                    "severity": "error",
                    "recommendation": (
                        f"Update to a version released within the last "
                        f"{self.max_days} days"
                    ),
                }

        except (ValueError, TypeError) as e:
            return {
                "file": workflow_file,
                "action": action_name,
                "version": version,
                "issue": f"Could not parse release date: {str(e)}",
                "severity": "warning",
                "recommendation": "Verify version exists and is properly tagged",
            }

        return None

    def _get_action_release_info(
        self, action_name: str, version: str
    ) -> Optional[Dict]:
        """Get release information for a GitHub Action."""
        # Use cache to avoid repeated API calls
        cache_key = f"{action_name}@{version}"
        if cache_key in self._cache:
            return self._cache[cache_key]

        try:
            # Convert version to tag name if needed
            tag_name = version if version.startswith("v") else f"v{version}"

            # GitHub API endpoint for releases
            url = f"https://api.github.com/repos/{action_name}/releases/tags/{tag_name}"

            response = self.session.get(url, timeout=10)

            if response.status_code == 200:
                release_info = response.json()
                self._cache[cache_key] = release_info
                return release_info
            elif response.status_code == 404:
                # Try without 'v' prefix
                if tag_name.startswith("v"):
                    alt_tag = tag_name[1:]
                    alt_url = (
                        f"https://api.github.com/repos/{action_name}/"
                        f"releases/tags/{alt_tag}"
                    )
                    alt_response = self.session.get(alt_url, timeout=10)
                    if alt_response.status_code == 200:
                        release_info = alt_response.json()
                        self._cache[cache_key] = release_info
                        return release_info

        except requests.exceptions.RequestException:
            # Network error - cache negative result to avoid retries
            self._cache[cache_key] = None

        return None

    def _check_security_advisories(self, action_info: Dict) -> Optional[Dict]:
        """Check for known security advisories for the action."""
        # This is a placeholder for security advisory checking
        # In a real implementation, this would check against GitHub
        # Security Advisory API
        # or other vulnerability databases
        return None

    def _generate_update_recommendation(self, action_info: Dict) -> Optional[Dict]:
        """Generate update recommendations for the action."""
        action_name = action_info["name"]
        current_version = action_info["version"]

        # Get latest release
        try:
            url = f"https://api.github.com/repos/{action_name}/releases/latest"
            response = self.session.get(url, timeout=10)

            if response.status_code == 200:
                latest_release = response.json()
                latest_version = latest_release.get("tag_name", "").lstrip("v")
                current_clean = current_version.lstrip("v")

                if latest_version and latest_version != current_clean:
                    return {
                        "action": action_name,
                        "current_version": current_version,
                        "recommended_version": latest_version,
                        "reason": "Newer version available",
                    }

        except requests.exceptions.RequestException:
            pass

        return None

    def generate_report(self, results: Dict) -> str:
        """Generate a human-readable report from validation results."""
        report_lines = [
            "GitHub Actions Dependency Validation Report",
            "=" * 50,
            "",
            f"Workflows processed: {results['workflows_processed']}",
            f"Dependencies checked: {results['dependencies_checked']}",
            f"Violations found: {len(results['violations'])}",
            f"Security warnings: {len(results['security_warnings'])}",
            f"Update recommendations: {len(results['recommendations'])}",
            "",
        ]

        if results["violations"]:
            report_lines.extend(["VIOLATIONS:", "-" * 20])
            for violation in results["violations"]:
                severity = violation["severity"].upper()
                report_lines.extend(
                    [
                        f"[{severity}] {violation['file']}",
                        f"  Action: {violation.get('action', 'N/A')}",
                        f"  Version: {violation.get('version', 'N/A')}",
                        f"  Issue: {violation['issue']}",
                        f"  Recommendation: {violation.get('recommendation', 'None')}",
                        "",
                    ]
                )

        if results["security_warnings"]:
            report_lines.extend(["SECURITY WARNINGS:", "-" * 20])
            for warning in results["security_warnings"]:
                report_lines.append(f"  {warning}")

        if results["recommendations"]:
            report_lines.extend(["UPDATE RECOMMENDATIONS:", "-" * 25])
            for rec in results["recommendations"]:
                report_lines.extend(
                    [
                        (
                            f"  {rec['action']}: {rec['current_version']} -> "
                            f"{rec['recommended_version']}"
                        ),
                        f"    Reason: {rec['reason']}",
                        "",
                    ]
                )

        return "\n".join(report_lines)


def main():
    """Main entry point for the dependency manager."""
    if len(sys.argv) < 2:
        print(
            "Usage: manage_github_actions_deps.py <repo_root> "
            "[--window-days min,max]"
        )
        print(
            "Example: manage_github_actions_deps.py /path/to/repo "
            "--window-days 30,90"
        )
        sys.exit(1)

    repo_root = Path(sys.argv[1])

    # Parse window days option
    window_days = (30, 90)  # Default
    if "--window-days" in sys.argv:
        idx = sys.argv.index("--window-days")
        if idx + 1 < len(sys.argv):
            try:
                min_days, max_days = map(int, sys.argv[idx + 1].split(","))
                window_days = (min_days, max_days)
            except ValueError:
                print(
                    "Error: --window-days must be in format 'min,max' "
                    "(e.g., '30,90')"
                )
                sys.exit(1)

    # Initialize manager and validate dependencies
    manager = GitHubActionsDependencyManager(repo_root, window_days)

    print("Validating GitHub Actions dependencies...")
    results = manager.validate_all_workflows()

    # Generate and display report
    report = manager.generate_report(results)
    print("\n" + report)

    # Exit with appropriate code
    if results["violations"]:
        error_count = sum(1 for v in results["violations"] if v["severity"] == "error")
        if error_count > 0:
            print(f"\nValidation failed with {error_count} errors")
            sys.exit(1)
        else:
            print(f"\nValidation completed with {len(results['violations'])} warnings")
            sys.exit(0)
    else:
        print("\nAll dependencies are within acceptable version windows")
        sys.exit(0)


if __name__ == "__main__":
    main()
