#!/usr/bin/env python3
"""
CI Monitor Agent - Enhanced DevOnboarder CI Analysis

Monitors CI pipeline status and generates structured reports for pull requests.
Enhanced with user-friendly PR number prompting and auto-detection.
"""

import argparse
import json
import subprocess
import sys
from datetime import datetime
from typing import Dict, Any, Optional
from urllib.parse import urlparse


class CIMonitor:
    """Enhanced CI monitoring for DevOnboarder pull requests."""

    def __init__(self, pr_number: int):
        """Initialize CI monitor for specific PR."""
        self.pr_number = pr_number

    def get_failed_workflow_runs(self)  Dict[str, Any]:
        """Fetch recent failed workflow runs for additional context."""
        cmd = [
            "gh",
            "run",
            "list",
            "--limit",
            "10",
            "--json",
            "conclusion,status,workflowName,createdAt,url,displayTitle",
            "--status",
            "failure",
        ]
        try:
            result = subprocess.run(cmd, capture_output=True, text=True, check=True)
            return {"failed_runs": json.loads(result.stdout)}
        except subprocess.CalledProcessError as e:
            print(f"  Failed to fetch failed workflow runs: {e}")
            return {"failed_runs": []}
        except json.JSONDecodeError as e:
            print(f" Error parsing failed workflow runs: {e}")
            return {"failed_runs": []}

    def get_pr_data(self)  Dict[str, Any]:
        """Fetch PR data and CI status from GitHub API."""
        cmd = [
            "gh",
            "pr",
            "view",
            str(self.pr_number),
            "--json",
            "title,state,url,statusCheckRollup",
        ]
        try:
            result = subprocess.run(cmd, capture_output=True, text=True, check=True)
            return json.loads(result.stdout)
        except subprocess.CalledProcessError as e:
            print(f"  GitHub CLI error for PR #{self.pr_number}")
            print(f"   Error: {e}")
            # Try alternative approach with less data
            return self._try_fallback_pr_data()
        except json.JSONDecodeError as e:
            print(f" Error parsing PR data: {e}")
            return self._create_minimal_pr_data()

    def _try_fallback_pr_data(self)  Dict[str, Any]:
        """Try simpler GitHub CLI commands as fallback."""
        try:
            # Try basic PR view without checks
            cmd = ["gh", "pr", "view", str(self.pr_number)]
            result = subprocess.run(cmd, capture_output=True, text=True, check=True)
            # Parse basic text output
            output = result.stdout
            lines = output.split("\n")

            # Extract basic info from text output
            title = "Unknown PR"
            state = "UNKNOWN"
            base_url = "https://github.com/theangrygamershowproductions"
            url = f"{base_url}/DevOnboarder/pull/{self.pr_number}"

            for line in lines:
                line_clean = line.strip()
                line_lower = line.lower()

                # Extract title (look for title or PR name)
                title_conditions = [
                    "title" in line_lower,
                    line_clean.startswith("feat"),
                    line_clean.startswith("fix"),
                    line_clean.startswith("docs"),
                ]
                if ":" in line and any(title_conditions):
                    if ":" in line:
                        title = line.split(":", 1)[-1].strip()
                    else:
                        title = line_clean

                # Extract state
                elif "open" in line_lower and "state" in line_lower:
                    state = "OPEN"
                elif "closed" in line_lower and "state" in line_lower:
                    state = "CLOSED"
                elif "merged" in line_lower:
                    state = "MERGED"

                # Extract clean URL
                elif urlparse(line_clean).hostname == "github.com":
                    url = line_clean
                elif "url:" in line_lower:
                    # Handle "url: https://..." format
                    url_part = line.split("url:", 1)[-1].strip()
                    if url_part.startswith("https://"):
                        # Validate that this is actually a GitHub URL
                        parsed = urlparse(url_part)
                        if parsed.hostname == "github.com":
                            url = url_part

            return {
                "title": title,
                "state": state,
                "url": url,
                "statusCheckRollup": [],  # No check data available
            }
        except subprocess.CalledProcessError:
            return self._create_minimal_pr_data()

    def _create_minimal_pr_data(self)  Dict[str, Any]:
        """Create minimal PR data when GitHub CLI fails."""
        base_url = "https://github.com/theangrygamershowproductions"
        pr_url = f"{base_url}/DevOnboarder/pull/{self.pr_number}"
        return {
            "title": f"PR #{self.pr_number} (GitHub CLI unavailable)",
            "state": "UNKNOWN",
            "url": pr_url,
            "statusCheckRollup": [],
        }

    def categorize_check(self, check_name: str)  str:
        """Categorize CI checks by type."""
        name = check_name.lower()

        # Infrastructure and setup
        install_terms = ["install", "setup", "cache", "docker"]
        if any(term in name for term in install_terms):
            return " Infrastructure"

        # Code quality
        format_terms = ["format", "style", "black", "prettier"]
        if any(term in name for term in format_terms):
            return "🎨 Code Style"

        # Testing and validation
        test_terms = ["test", "lint", "type", "coverage"]
        if any(term in name for term in test_terms):
            return "🧪 Quality Assurance"

        # Build and deployment
        if any(term in name for term in ["build", "compile", "deploy"]):
            return "BUILD: Build"

        # Security
        security_terms = ["security", "audit", "policy", "permissions"]
        if any(term in name for term in security_terms):
            return "🔒 Security"

        return " Other"

    def analyze_ci_status(self, checks: list)  Dict[str, Any]:
        """Analyze CI status and provide insights."""
        if not checks:
            return {"status": "no_checks", "message": "No CI checks found"}

        successful = [c for c in checks if c.get("conclusion") == "SUCCESS"]
        failed_states = ["FAILURE", "CANCELLED"]
        failed = [c for c in checks if c.get("conclusion") in failed_states]
        pending = [c for c in checks if c.get("status") == "IN_PROGRESS"]

        total_checks = len(checks)
        success_rate = (len(successful) / total_checks * 100) if total_checks > 0 else 0

        return {
            "total": total_checks,
            "successful": len(successful),
            "failed": len(failed),
            "pending": len(pending),
            "success_rate": success_rate,
            "status": self._determine_overall_status(successful, failed, pending),
            "checks_by_category": self._group_checks_by_category(checks),
        }

    def _determine_overall_status(self, successful, failed, pending):
        """Determine overall CI status."""
        if failed:
            return "failed"
        elif pending:
            return "pending"
        elif successful:
            return "success"
        else:
            return "unknown"

    def _group_checks_by_category(self, checks):
        """Group checks by category for better organization."""
        categories = {}
        for check in checks:
            category = self.categorize_check(check.get("name", ""))
            if category not in categories:
                categories[category] = []
            categories[category].append(check)
        return categories

    def generate_status_report(self, pr_data: Dict[str, Any])  str:
        """Generate comprehensive status report."""
        title = pr_data.get("title", "Unknown PR")
        state = pr_data.get("state", "UNKNOWN")
        url = pr_data.get("url", "")

        # Handle both old 'checks' and new 'statusCheckRollup' formats
        status_check_rollup = pr_data.get("statusCheckRollup", [])
        if status_check_rollup and isinstance(status_check_rollup, list):
            # statusCheckRollup contains the checks directly
            checks = status_check_rollup
        else:
            # Fallback to old checks format
            checks = pr_data.get("checks", [])

        analysis = self.analyze_ci_status(checks)

        # Get additional failed workflow context
        failed_workflows = self.get_failed_workflow_runs()

        # Header
        timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S UTC")
        report = f"#  CI Status Report - PR #{self.pr_number}\n\n"
        report = f"**Title**: {title}\n"
        report = f"**State**: {state}\n"
        report = f"**URL**: {url}\n"
        report = f"**Generated**: {timestamp}\n\n"

        # Overall status
        status_emoji = {
            "success": "",
            "failed": "",
            "pending": "",
            "no_checks": "⚪",
        }.get(analysis["status"], "❓")

        report = f"## {status_emoji} Overall Status\n\n"

        if analysis["status"] == "no_checks":
            report = "  **No CI checks data available**\n\n"
            report = "This could mean:\n"
            report = "- GitHub CLI authentication issues\n"
            report = "- Repository access permissions\n"
            report = "- CI checks are still being configured\n"
            report = "- No automated checks configured for this PR\n\n"

            # Add manual check suggestions
            report = "##  Manual Status Check Options\n\n"
            report = "Since automated CI data is unavailable, "
            report = "you can check status manually:\n\n"
            report = "1. **Visit PR directly**: "
            report = f"[PR #{self.pr_number}]({url})\n"
            report = "2. **Check GitHub Actions**: "
            repo_base = url.replace(f"/pull/{self.pr_number}", "")
            report = f"[Actions]({repo_base}/actions)\n"
            report = "3. **Run local tests**:\n"
            report = "   ```bash\n"
            report = "   source .venv/bin/activate\n"
            report = "   pip install -e .[test]\n"
            report = "   python -m pytest --cov=src --cov-fail-under=95\n"
            report = "   python -m ruff check src/\n"
            report = "   ```\n\n"
            return report

        # Statistics
        report = f"- **Total Checks**: {analysis['total']}\n"
        report = f"- **Successful**: {analysis['successful']}\n"
        report = f"- **Failed**: {analysis['failed']}\n"
        report = f"- **Pending**: {analysis['pending']}\n"
        report = f"- **Success Rate**: {analysis['success_rate']:.1f}%\n\n"

        # Detailed check results by category
        checks_by_category = analysis["checks_by_category"]
        for category, category_checks in checks_by_category.items():
            report = f"### {category}\n\n"

            for check in category_checks:
                name = check.get("name", "Unknown")
                conclusion = check.get("conclusion", "UNKNOWN")
                status = check.get("status", "UNKNOWN")

                if conclusion == "SUCCESS":
                    icon = ""
                elif conclusion in ["FAILURE", "CANCELLED"]:
                    icon = ""
                elif status == "IN_PROGRESS":
                    icon = ""
                else:
                    icon = "⚪"

                duration = self._format_duration(check)
                report = f"- {icon} **{name}**: {conclusion} {duration}\n"

            report = "\n"

        # Recommendations
        if analysis["status"] == "failed":
            report = "##  Recommended Actions\n\n"
            report = "1. **Review failed checks** above for specific errors\n"
            report = "2. **Run tests locally**: " "Activate virtual environment\n"
            report = "3. **Install dependencies**: `pip install -e .[test]`\n"
            report = "4. **Run quality checks**: " "`python -m pytest --cov=src`\n"
            report = "5. **Check linting**: `python -m ruff check src/`\n\n"

            # Add recent failed workflow context if available
            if failed_workflows.get("failed_runs"):
                report = "### ALERT: Recent Failed Workflow Runs\n\n"
                for run in failed_workflows["failed_runs"][:5]:  # Show top 5
                    workflow_name = run.get("workflowName", "Unknown")
                    display_title = run.get("displayTitle", "No title")
                    url = run.get("url", "")
                    created_at = run.get("createdAt", "")

                    if created_at:
                        try:
                            created = datetime.fromisoformat(
                                created_at.replace("Z", "00:00")
                            )
                            time_ago = (
                                datetime.now().replace(tzinfo=created.tzinfo) - created
                            )
                            time_str = (
                                f" ({time_ago.days}d ago)"
                                if time_ago.days > 0
                                else f" ({time_ago.seconds//3600}h ago)"
                            )
                        except (ValueError, AttributeError):
                            time_str = ""
                    else:
                        time_str = ""

                    report = (
                        f"-  **{workflow_name}**: " f"{display_title}{time_str}\n"
                    )
                    if url:
                        report = f"  [View Run]({url})\n"
                report = "\n"

        elif analysis["status"] == "pending":
            report = "## ⏳ Status: In Progress\n\n"
            report = "CI checks are still running. "
            report = "Check back in a few minutes.\n\n"
        else:
            report = "## 🎉 All Checks Passing!\n\n"
            report = "PR is ready for review and merge.\n\n"

        return report

    def _format_duration(self, check: Dict[str, Any])  str:
        """Format check duration for display."""
        started = check.get("startedAt")
        completed = check.get("completedAt")

        if started and completed:
            try:
                start_time = datetime.fromisoformat(started.replace("Z", "00:00"))
                end_time = datetime.fromisoformat(completed.replace("Z", "00:00"))
                duration = end_time - start_time
                return f"({duration.total_seconds():.0f}s)"
            except (ValueError, AttributeError):
                pass

        return ""

    def post_status_comment(self, report: str)  None:
        """Post status report as PR comment."""
        try:
            cmd = ["gh", "pr", "comment", str(self.pr_number), "--body", report]
            subprocess.run(cmd, check=True)  # nosec B603
            print(f" Posted status comment to PR #{self.pr_number}")
        except subprocess.CalledProcessError as e:
            print(f" Failed to post comment: {e}")


def get_current_pr_number()  Optional[int]:
    """Try to detect current PR number from git context."""
    try:
        cmd = ["gh", "pr", "view", "--json", "number"]
        result = subprocess.run(  # nosec B603
            cmd, capture_output=True, text=True, check=True
        )
        data = json.loads(result.stdout)
        return data.get("number")
    except (subprocess.CalledProcessError, json.JSONDecodeError, KeyError):
        return None


def prompt_for_pr_number()  int:
    """Prompt user for PR number with helpful suggestions."""
    print(" CI Monitor Agent - Enhanced DevOnboarder CI Analysis")
    print("=" * 60)

    # Try to detect current PR
    current_pr = get_current_pr_number()
    if current_pr:
        print(f"LOCATION: Detected current PR: #{current_pr}")
        print("\nOptions:")
        print(f"  1. Monitor current PR #{current_pr}")
        print("  2. Choose a different PR")
        print("  3. Exit")

        while True:
            try:
                choice = input("\nEnter your choice (1-3) [1]: ").strip()
                if choice == "" or choice == "1":
                    return current_pr
                elif choice == "2":
                    break  # Continue to PR selection
                elif choice == "3":
                    print("👋 Monitoring cancelled")
                    sys.exit(0)
                else:
                    print(" Please enter 1, 2, or 3")
            except KeyboardInterrupt:
                print("\n👋 Monitoring cancelled")
                sys.exit(0)

    # List recent PRs for reference
    print("\n Recent Pull Requests:")
    try:
        cmd = ["gh", "pr", "list", "--limit", "5", "--json", "number,title,state"]
        result = subprocess.run(  # nosec B603
            cmd, capture_output=True, text=True, check=True
        )
        prs = json.loads(result.stdout)
        if prs:
            for pr in prs:
                state_emoji = "" if pr["state"] == "OPEN" else ""
                title = pr["title"][:50]
                print(f"   {state_emoji} #{pr['number']}: {title}...")
        else:
            print("   (No recent PRs found)")
    except (subprocess.CalledProcessError, json.JSONDecodeError):
        print("   (Unable to fetch recent PRs)")

    # Prompt for PR number with better guidance
    print("\n Tip: You can also run this script with:")
    print("   python ci-monitor.py <PR_NUMBER>")
    while True:
        try:
            pr_input = input("\nTARGET: Enter PR number to monitor: ").strip()
            if not pr_input:
                print(" PR number is required")
                continue
            pr_number = int(pr_input)
            if pr_number <= 0:
                print(" PR number must be positive")
                continue
            return pr_number
        except ValueError:
            print(" Please enter a valid number")
        except KeyboardInterrupt:
            print("\n👋 Monitoring cancelled")
            sys.exit(0)


def main():
    """Main entry point for CI monitor."""
    parser = argparse.ArgumentParser(
        description="CI Monitor Agent - Enhanced DevOnboarder CI Analysis"
    )
    parser.add_argument(
        "pr_number",
        type=int,
        nargs="?",
        help=(
            "Pull request number to monitor " "(optional - will prompt if not provided)"
        ),
    )
    parser.add_argument("--output", "-o", help="Output file for report (optional)")
    parser.add_argument(
        "--post-comment", action="store_true", help="Post report as PR comment"
    )
    parser.add_argument("--json", action="store_true", help="Output raw JSON data")

    args = parser.parse_args()

    try:
        # Get PR number from args or prompt user
        pr_number = args.pr_number
        if pr_number is None:
            pr_number = prompt_for_pr_number()

        monitor = CIMonitor(pr_number)
        pr_data = monitor.get_pr_data()

        # Output raw JSON if requested
        if args.json:
            print(json.dumps(pr_data, indent=2))
            return

        # Generate report
        report = monitor.generate_status_report(pr_data)

        # Output report
        if args.output:
            with open(args.output, "w", encoding="utf-8") as f:
                f.write(report)
            print(f" Report saved to {args.output}")
        else:
            print(report)

        # Post comment if requested
        if args.post_comment:
            monitor.post_status_comment(report)

    except KeyboardInterrupt:
        print("\n Monitoring interrupted")
        sys.exit(1)
    except (subprocess.CalledProcessError, FileNotFoundError) as e:
        print(f" Error: {e}")
        sys.exit(1)


if __name__ == "__main__":
    main()
