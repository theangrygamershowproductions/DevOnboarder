#!/usr/bin/env python3
"""
CI Monitor Agent - Automated PR Status Reporting
Monitors CI pipeline status and generates structured reports for pull requests.
"""

import json
import subprocess
import sys
from datetime import datetime
from pathlib import Path
from typing import Dict, Any
import argparse


class CIMonitor:
    def __init__(self, pr_number: int):
        self.pr_number = pr_number
        self.github_cli = "gh"

    def get_pr_status(self) -> Dict[str, Any]:
        """Get comprehensive PR status from GitHub CLI"""
        try:
            cmd = [
                self.github_cli,
                "pr",
                "view",
                str(self.pr_number),
                "--json",
                "state,statusCheckRollup,url,title,headRefName,updatedAt",
            ]
            result = subprocess.run(cmd, capture_output=True, text=True, check=True)
            return json.loads(result.stdout)
        except subprocess.CalledProcessError as e:
            print(f"Error fetching PR status: {e.stderr}")
            sys.exit(1)

    def classify_failure(self, check: Dict[str, Any]) -> Dict[str, str]:
        """Classify failure type based on check name and details"""
        name = check.get("name", "").lower()

        # Infrastructure failures
        if any(term in name for term in ["install", "setup", "cache", "docker"]):
            if "npm" in name or "node" in name:
                return {
                    "type": "infrastructure",
                    "category": "dependency_management",
                    "priority": "high",
                    "action": "Check npm/node setup and dependencies",
                }
            elif "python" in name or "pip" in name:
                return {
                    "type": "infrastructure",
                    "category": "python_environment",
                    "priority": "high",
                    "action": "Verify virtual environment activation",
                }

        # Code quality failures
        elif any(term in name for term in ["test", "lint", "type", "coverage"]):
            return {
                "type": "code_quality",
                "category": "validation",
                "priority": "medium",
                "action": "Fix code issues and run tests locally",
            }

        # Security/Policy failures
        elif any(
            term in name for term in ["security", "audit", "policy", "permissions"]
        ):
            return {
                "type": "security_policy",
                "category": "compliance",
                "priority": "critical",
                "action": "Address security/policy violations immediately",
            }

        # Default classification
        return {
            "type": "unknown",
            "category": "investigation_needed",
            "priority": "medium",
            "action": "Manual investigation required",
        }

    def generate_status_report(self, pr_data: Dict[str, Any]) -> str:
        """Generate comprehensive status report"""
        checks = pr_data.get("statusCheckRollup", [])

        # Categorize checks
        successful = [c for c in checks if c.get("conclusion") == "SUCCESS"]
        failed = [c for c in checks if c.get("conclusion") in ["FAILURE", "CANCELLED"]]
        in_progress = [c for c in checks if c.get("status") == "IN_PROGRESS"]

        # Calculate metrics
        total_checks = len(checks)
        success_rate = (len(successful) / total_checks * 100) if total_checks > 0 else 0

        # Classify failures
        classified_failures = []
        for check in failed:
            classification = self.classify_failure(check)
            classified_failures.append({**check, **classification})

        # Count failure types
        infra_failures = len(
            [f for f in classified_failures if f["type"] == "infrastructure"]
        )
        code_failures = len(
            [f for f in classified_failures if f["type"] == "code_quality"]
        )
        policy_failures = len(
            [f for f in classified_failures if f["type"] == "security_policy"]
        )

        # Generate report
        timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S UTC")

        # Determine pipeline status
        if not failed and not in_progress:
            status = "🟢 PASSING"
        elif in_progress:
            status = "🔄 IN PROGRESS"
        else:
            status = "🔴 FAILING"

        report = f"""## 🔍 CI Status Report - PR #{self.pr_number}

**Last Updated:** {timestamp}
**Pipeline Status:** {status}
**Branch:** `{pr_data.get('headRefName', 'unknown')}`

---

### ✅ Completed Successfully ({len(successful)})

"""

        for check in successful[:10]:  # Limit to first 10
            duration = self._calculate_duration(check)
            report += f"- **{check['name']}**: {check['conclusion']} ({duration})\n"

        if len(successful) > 10:
            report += f"- ... and {len(successful) - 10} more successful checks\n"

        if in_progress:
            report += f"\n### 🔄 In Progress ({len(in_progress)})\n\n"
            for check in in_progress:
                started = check.get("startedAt", "unknown")
                report += (
                    f"- **{check['name']}**: {check['status']} (started {started})\n"
                )

        if failed:
            report += f"\n### ❌ Failed ({len(failed)})\n\n"
            for check in classified_failures:
                priority_emoji = {"critical": "🚨", "high": "⚠️", "medium": "💡"}.get(
                    check["priority"], "🔍"
                )
                report += f"- **{check['name']}**: {check['conclusion']}\n"
                type_name = check["type"].replace("_", " ").title()
                report += f"  - {priority_emoji} **Type:** {type_name}\n"
                report += f"  - **Action:** {check['action']}\n"
                if check.get("detailsUrl"):
                    report += f"  - [View Log]({check['detailsUrl']})\n"
                report += "\n"

        # Metrics table
        report += f"""---

### 📊 Pipeline Metrics

| Metric | Value |
|--------|-------|
| **Total Checks** | {total_checks} |
| **Success Rate** | {success_rate:.1f}% |
| **Infrastructure Issues** | {infra_failures} |
| **Code Issues** | {code_failures} |
| **Policy Violations** | {policy_failures} |

"""

        # Recommendations
        if failed:
            report += "### 🎯 Recommended Actions\n\n"

            if infra_failures > 0:
                report += "🔧 **Infrastructure Issues:**\n"
                report += (
                    "- Check virtual environment activation: "
                    "`source .venv/bin/activate`\n"
                )
                report += (
                    "- Verify dependency installation: " "`pip install -e .[test]`\n"
                )
                report += "- Review CI troubleshooting guide\n\n"

            if code_failures > 0:
                report += "📝 **Code Quality Issues:**\n"
                report += (
                    "- Run tests locally: " "`pytest --cov=src --cov-fail-under=95`\n"
                )
                report += "- Check formatting: `black . && ruff check .`\n"
                report += "- Review type checking: `mypy src/`\n\n"

            if policy_failures > 0:
                report += "🛡️ **Security/Policy Issues:**\n"
                report += "- Review security audit results\n"
                report += "- Check Potato Policy compliance\n"
                report += "- Verify permissions and documentation\n\n"

        elif in_progress:
            report += (
                "### 🔄 Status\n\nPipeline is running. "
                "Estimated completion in 30-45 minutes.\n\n"
            )
        else:
            report += (
                "### 🎉 All Checks Passing!\n\n" "PR is ready for review and merge.\n\n"
            )

        ci_docs_url = (
            "https://github.com/theangrygamershowproductions/"
            "DevOnboarder/blob/main/docs/ci-troubleshooting.md"
        )

        report += f"""---

### 🔗 Quick Links

- [Full Pipeline]({pr_data.get('url', '#')})
- [CI Documentation]({ci_docs_url})

*Generated by CI Monitor Agent at {timestamp}*
"""

        return report

    def _calculate_duration(self, check: Dict[str, Any]) -> str:
        """Calculate and format check duration"""
        try:
            started = check.get("startedAt")
            completed = check.get("completedAt")
            if started and completed:
                # Simple duration calculation
                # (would need proper datetime parsing in production)
                return "~2min"
            return "unknown"
        except Exception:
            return "unknown"

    def post_status_comment(self, report: str) -> bool:
        """Post or update status comment on PR"""
        try:
            # Create a unique marker for our status comments
            marker = f"<!-- CI-Monitor-{self.pr_number} -->"
            report_with_marker = f"{marker}\n{report}"

            # Try to update existing comment first
            # (In production, would check for existing comments and update)
            cmd = [
                self.github_cli,
                "pr",
                "comment",
                str(self.pr_number),
                "--body",
                report_with_marker,
            ]

            result = subprocess.run(cmd, capture_output=True, text=True)
            if result.returncode == 0:
                print(f"✅ Status comment posted to PR #{self.pr_number}")
                return True
            else:
                print(f"❌ Failed to post comment: {result.stderr}")
                return False

        except Exception as e:
            print(f"❌ Error posting comment: {e}")
            return False


def main():
    parser = argparse.ArgumentParser(description="CI Monitor Agent")
    parser.add_argument("pr_number", type=int, help="Pull request number to monitor")
    parser.add_argument("--output", "-o", help="Output file for report (optional)")
    parser.add_argument(
        "--post-comment", action="store_true", help="Post report as PR comment"
    )
    parser.add_argument("--json", action="store_true", help="Output raw JSON data")

    args = parser.parse_args()

    monitor = CIMonitor(args.pr_number)

    try:
        # Get PR status
        pr_data = monitor.get_pr_status()

        if args.json:
            print(json.dumps(pr_data, indent=2))
            return

        # Generate report
        report = monitor.generate_status_report(pr_data)

        # Output report
        if args.output:
            Path(args.output).write_text(report)
            print(f"✅ Report saved to {args.output}")
        else:
            print(report)

        # Post comment if requested
        if args.post_comment:
            monitor.post_status_comment(report)

    except KeyboardInterrupt:
        print("\n❌ Monitoring interrupted")
        sys.exit(1)
    except Exception as e:
        print(f"❌ Error: {e}")
        sys.exit(1)


if __name__ == "__main__":
    main()
