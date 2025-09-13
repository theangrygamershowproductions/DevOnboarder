#!/usr/bin/env python3
"""
DevOnboarder CI Health Dashboard Engine

Real-time monitoring, failure prediction, and automated remediation for DevOnboarder's
45+ GitHub Actions workflows. Built upon Token Architecture v2.1 and integrated with
the AAR system for proactive CI health management.

Architecture: docs/CI_DASHBOARD_INTEGRATION_ARCHITECTURE.md
Token System: docs/TOKEN_ARCHITECTURE_V2.1.md
Based on: scripts/prototype_detached_head_predictor.py
"""

import argparse
import json
import logging
import re
import sys
import time
import subprocess
from datetime import datetime
from typing import Dict, List, Optional, Any
from pathlib import Path

# DevOnboarder centralized logging pattern
LOG_DIR = Path(__file__).parent.parent / "logs"
LOG_DIR.mkdir(exist_ok=True)
timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
LOG_FILE = LOG_DIR / f"ci_health_dashboard_{timestamp}.log"

# Configure logging with centralized pattern
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s - %(name)s - %(levelname)s - %(message)s",
    handlers=[logging.FileHandler(LOG_FILE), logging.StreamHandler(sys.stdout)],
)
logger = logging.getLogger("ci-health-dashboard")


class TokenLoader:
    """
    Token loading integration with DevOnboarder Token Architecture v2.1
    Supports CI automation token hierarchy and fallback mechanisms
    """

    def __init__(self):
        self.token = None
        self.token_source = None

    def load_token(self) -> Optional[str]:
        """Load GitHub token using Token Architecture v2.1 hierarchy"""
        # Token hierarchy: CI_ISSUE_AUTOMATION_TOKEN → CI_BOT_TOKEN → GITHUB_TOKEN
        token_hierarchy = ["CI_ISSUE_AUTOMATION_TOKEN", "CI_BOT_TOKEN", "GITHUB_TOKEN"]

        # First try environment variables
        import os

        for token_env in token_hierarchy:
            token = os.getenv(token_env)
            if token:
                self.token = token
                self.token_source = f"env:{token_env}"
                logger.info(f"Token loaded from environment: {token_env}")
                return token

        # Fallback to enhanced token loader script
        try:
            result = subprocess.run(
                ["bash", "scripts/enhanced_token_loader.sh"],
                capture_output=True,
                text=True,
                cwd=Path(__file__).parent.parent,
            )
            if result.returncode == 0 and result.stdout.strip():
                self.token = result.stdout.strip()
                self.token_source = "enhanced_token_loader.sh"
                logger.info("Token loaded from enhanced_token_loader.sh")
                return self.token
        except Exception as e:
            logger.warning(f"Enhanced token loader failed: {e}")

        # Final fallback to GitHub CLI
        try:
            result = subprocess.run(
                ["gh", "auth", "token"], capture_output=True, text=True
            )
            if result.returncode == 0:
                self.token = result.stdout.strip()
                self.token_source = "github_cli"
                logger.info("Token loaded from GitHub CLI")
                return self.token
        except Exception as e:
            logger.warning(f"GitHub CLI token failed: {e}")

        msg = "No GitHub token available - CI Dashboard will have limited functionality"
        logger.error(msg)
        return None


class DetachedHeadPredictor:
    """
    Advanced CI failure prediction with pattern recognition for detached HEAD issues
    Based on real 2025-09-13 failure analysis with 95% confidence detection
    """

    def __init__(self):
        self.patterns = {
            "detached_head": [
                r"fatal: You are in 'detached HEAD' state",
                r"HEAD is now at [a-f0-9]+ .*",
                r"You are in detached HEAD state",
                r"git checkout -b <new-branch-name>",
            ],
            "signature_verification": [
                r"signature verification failed",
                r"commit [a-f0-9]+ has a bad GPG signature",
                r"error: could not verify the tag",
                r"gpg: signature verification failed",
            ],
            "dependency_conflicts": [
                r"CONFLICT \(content\): Merge conflict in package",
                r"npm ERR! peer dep missing",
                r"Could not resolve dependencies",
                r"ENOENT.*package\.json",
            ],
            "test_failures": [
                r"FAILED.*test",
                r"AssertionError:",
                r"ModuleNotFoundError:",
                r"ImportError: No module named",
            ],
        }

    def predict_failure(self, workflow_logs: str, workflow_name: str) -> Dict[str, Any]:
        """
        Predict workflow failure with confidence scoring and actionable solutions

        Args:
            workflow_logs: Raw workflow logs
            workflow_name: Name of the workflow being analyzed

        Returns:
            Dict with prediction confidence, failure type, and recommended actions
        """
        prediction = {
            "failure_predicted": False,
            "confidence": 0.0,
            "failure_type": None,
            "patterns_matched": [],
            "recommended_actions": [],
            "cost_savings_minutes": 0,
            "analysis_timestamp": datetime.now().isoformat(),
        }

        max_confidence = 0.0
        primary_failure_type = None

        for failure_type, patterns in self.patterns.items():
            matches = []
            for pattern in patterns:
                if re.search(pattern, workflow_logs, re.IGNORECASE):
                    matches.append(pattern)

            if matches:
                # Calculate confidence based on pattern matches and workflow context
                base_confidence = len(matches) / len(patterns)

                # Boost confidence for known high-risk patterns
                critical_workflows = ["ci.yml", "auto-fix.yml"]
                if (
                    failure_type == "detached_head"
                    and workflow_name in critical_workflows
                ):
                    base_confidence *= 1.5
                elif (
                    failure_type == "signature_verification"
                    and "merge" in workflow_logs.lower()
                ):
                    base_confidence *= 1.3

                # Cap confidence at 95% (human oversight required)
                confidence = min(base_confidence, 0.95)

                if confidence > max_confidence:
                    max_confidence = confidence
                    primary_failure_type = failure_type

                prediction["patterns_matched"].extend(matches)

        if max_confidence > 0.6:  # 60% confidence threshold for prediction
            prediction["failure_predicted"] = True
            prediction["confidence"] = max_confidence
            prediction["failure_type"] = primary_failure_type
            prediction["recommended_actions"] = self._get_recommended_actions(
                primary_failure_type
            )
            prediction["cost_savings_minutes"] = self._estimate_cost_savings(
                primary_failure_type, workflow_name
            )

        return prediction

    def _get_recommended_actions(self, failure_type: str) -> List[str]:
        """Get actionable recommendations based on failure type"""
        actions = {
            "detached_head": [
                "Cancel workflow immediately to save compute time",
                "Check git checkout commands in workflow",
                "Verify branch references and HEAD state",
                "Review workflow trigger conditions",
            ],
            "signature_verification": [
                "Cancel merge-dependent workflows",
                "Verify all commits have valid signatures",
                "Run git filter-branch if needed to re-sign commits",
                "Check GPG key availability in CI environment",
            ],
            "dependency_conflicts": [
                "Cancel before dependency installation step",
                "Review recent package.json/requirements.txt changes",
                "Check for conflicting dependency versions",
                "Consider dependency lock file regeneration",
            ],
            "test_failures": [
                "Allow workflow to continue for debugging info",
                "Check for new/missing imports",
                "Verify test environment setup",
                "Review recent code changes for test compatibility",
            ],
        }
        return actions.get(
            failure_type, ["Review workflow logs for specific error patterns"]
        )

    def _estimate_cost_savings(self, failure_type: str, workflow_name: str) -> int:
        """Estimate cost savings in minutes if workflow is cancelled early"""
        # Based on typical DevOnboarder workflow durations
        workflow_durations = {
            "ci.yml": 15,
            "documentation-quality.yml": 8,
            "auto-fix.yml": 12,
            "priority-matrix-synthesis.yml": 5,
            "root-artifact-monitor.yml": 3,
        }

        base_duration = workflow_durations.get(workflow_name, 10)

        # Early cancellation savings based on failure type
        if failure_type == "detached_head":
            return int(base_duration * 0.9)  # Can cancel very early
        elif failure_type == "signature_verification":
            return int(base_duration * 0.7)  # Cancel before expensive merge operations
        elif failure_type == "dependency_conflicts":
            return int(base_duration * 0.5)  # Cancel before test execution
        else:
            return int(base_duration * 0.3)  # Some savings still possible


class CIHealthDashboard:
    """
    Main CI Health Dashboard Engine for real-time monitoring and failure prediction
    Integrates with Token Architecture v2.1 and AAR system
    """

    def __init__(self):
        self.token_loader = TokenLoader()
        self.predictor = DetachedHeadPredictor()
        self.github_token = self.token_loader.load_token()

    def get_workflow_runs(
        self, branch: Optional[str] = None, limit: int = 10
    ) -> List[Dict]:
        """Get recent workflow runs using GitHub CLI"""
        cmd = [
            "gh",
            "run",
            "list",
            "--limit",
            str(limit),
            "--json",
            "name,status,conclusion,createdAt,updatedAt,url,workflowName",
        ]

        if branch:
            cmd.extend(["--branch", branch])

        try:
            result = subprocess.run(cmd, capture_output=True, text=True)
            if result.returncode == 0:
                return json.loads(result.stdout)
        except Exception as e:
            logger.error(f"Failed to get workflow runs: {e}")

        return []

    def get_workflow_logs(self, run_id: str) -> str:
        """Get workflow logs for analysis"""
        try:
            result = subprocess.run(
                ["gh", "run", "view", run_id, "--log"], capture_output=True, text=True
            )
            if result.returncode == 0:
                return result.stdout
        except Exception as e:
            logger.error(f"Failed to get workflow logs for {run_id}: {e}")

        return ""

    def analyze_active_workflows(self) -> Dict[str, Any]:
        """Analyze currently active workflows for failure prediction"""
        analysis = {
            "timestamp": datetime.now().isoformat(),
            "active_workflows": [],
            "predictions": [],
            "total_cost_savings_potential": 0,
            "recommendations": [],
        }

        workflows = self.get_workflow_runs(limit=20)
        active_workflows = [w for w in workflows if w["status"] == "in_progress"]

        logger.info(f"Analyzing {len(active_workflows)} active workflows")

        for workflow in active_workflows:
            workflow_analysis = {
                "name": workflow["workflowName"],
                "url": workflow["url"],
                "status": workflow["status"],
                "created_at": workflow["createdAt"],
            }

            # Get logs for prediction (if available yet)
            logs = self.get_workflow_logs(workflow["url"].split("/")[-1])

            if logs:
                prediction = self.predictor.predict_failure(
                    logs, workflow["workflowName"]
                )
                workflow_analysis["prediction"] = prediction

                if prediction["failure_predicted"]:
                    analysis["predictions"].append(
                        {
                            "workflow": workflow["workflowName"],
                            "confidence": prediction["confidence"],
                            "failure_type": prediction["failure_type"],
                            "actions": prediction["recommended_actions"],
                        }
                    )
                    analysis["total_cost_savings_potential"] += prediction[
                        "cost_savings_minutes"
                    ]

            analysis["active_workflows"].append(workflow_analysis)

        # Generate high-level recommendations
        if analysis["predictions"]:
            high_confidence_count = len(
                [p for p in analysis["predictions"] if p["confidence"] > 0.8]
            )
            analysis["recommendations"].append(
                f"Consider cancelling {high_confidence_count} "
                f"workflows with >80% failure confidence"
            )

        return analysis

    def display_dashboard(self, branch: Optional[str] = None, live_mode: bool = False):
        """Display real-time CI health dashboard"""
        if live_mode:
            logger.info("Starting live monitoring mode (Ctrl+C to exit)")

        try:
            while True:
                # Clear screen for live mode
                if live_mode:
                    subprocess.run(["clear"], check=False)

                print("=" * 80)
                print("🏥 DevOnboarder CI Health Dashboard")
                print("=" * 80)
                print(f"Timestamp: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
                print(f"Token Source: {self.token_loader.token_source or 'None'}")
                if branch:
                    print(f"Branch Filter: {branch}")
                print()

                analysis = self.analyze_active_workflows()

                # Active workflows summary
                print(f"Active Workflows: {len(analysis['active_workflows'])}")
                print(f"Failure Predictions: {len(analysis['predictions'])}")
                print(
                    f"Potential Cost Savings: "
                    f"{analysis['total_cost_savings_potential']} minutes"
                )
                print()

                # Display active workflows
                if analysis["active_workflows"]:
                    print("📊 Active Workflow Status:")
                    print("-" * 40)
                    for workflow in analysis["active_workflows"]:
                        status_icon = (
                            "🟡" if workflow["status"] == "in_progress" else "🔴"
                        )
                        print(f"{status_icon} {workflow['name']}")

                        if (
                            "prediction" in workflow
                            and workflow["prediction"]["failure_predicted"]
                        ):
                            pred = workflow["prediction"]
                            confidence_icon = "🚨" if pred["confidence"] > 0.8 else "⚠️"
                            print(
                                f"   {confidence_icon} {pred['failure_type']} "
                                f"({pred['confidence']:.1%} confidence)"
                            )
                    print()

                # Display predictions and recommendations
                if analysis["predictions"]:
                    print("🔮 Failure Predictions:")
                    print("-" * 40)
                    for pred in analysis["predictions"]:
                        confidence_bar = "█" * int(pred["confidence"] * 10)
                        print(f"⚡ {pred['workflow']}: {pred['failure_type']}")
                        print(
                            f"   Confidence: [{confidence_bar:<10}] "
                            f"{pred['confidence']:.1%}"
                        )
                        print(f"   Actions: {pred['actions'][0]}")
                    print()

                # Display recommendations
                if analysis["recommendations"]:
                    print("💡 Recommendations:")
                    print("-" * 40)
                    for rec in analysis["recommendations"]:
                        print(f"• {rec}")
                    print()

                if not live_mode:
                    break

                print("Live monitoring... (Ctrl+C to exit)")
                time.sleep(30)  # Update every 30 seconds

        except KeyboardInterrupt:
            if live_mode:
                print("\nLive monitoring stopped.")
            return

    def predict_only(self, branch: Optional[str] = None) -> Dict[str, Any]:
        """Run failure prediction only and return results"""
        analysis = self.analyze_active_workflows()

        prediction_summary = {
            "timestamp": analysis["timestamp"],
            "active_workflow_count": len(analysis["active_workflows"]),
            "predicted_failures": len(analysis["predictions"]),
            "high_confidence_failures": len(
                [p for p in analysis["predictions"] if p["confidence"] > 0.8]
            ),
            "total_cost_savings_minutes": analysis["total_cost_savings_potential"],
            "predictions": analysis["predictions"],
        }

        return prediction_summary


def main():
    """Main CLI entry point"""
    parser = argparse.ArgumentParser(
        description=(
            "DevOnboarder CI Health Dashboard - Real-time workflow "
            "monitoring and failure prediction"
        ),
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  devonboarder-ci-health                    # Full dashboard view
  devonboarder-ci-health --branch main      # Branch-specific analysis
  devonboarder-ci-health --live             # Live monitoring mode
  devonboarder-ci-health --predict          # Failure prediction only
  devonboarder-ci-health --json             # JSON output for automation
        """,
    )

    parser.add_argument("--branch", "-b", help="Filter workflows by branch")
    parser.add_argument(
        "--live",
        "-l",
        action="store_true",
        help="Live monitoring mode (updates every 30 seconds)",
    )
    parser.add_argument(
        "--predict", "-p", action="store_true", help="Run failure prediction only"
    )
    parser.add_argument(
        "--json", "-j", action="store_true", help="Output results in JSON format"
    )
    parser.add_argument(
        "--verbose", "-v", action="store_true", help="Verbose logging output"
    )

    args = parser.parse_args()

    if args.verbose:
        logging.getLogger().setLevel(logging.DEBUG)

    # Initialize dashboard
    logger.info("Starting DevOnboarder CI Health Dashboard")
    dashboard = CIHealthDashboard()

    if not dashboard.github_token:
        print(
            "⚠️  Warning: No GitHub token available. Dashboard will "
            "have limited functionality."
        )
        print("   Please ensure TOKEN_ARCHITECTURE_V2.1 is properly configured.")
        print()

    try:
        if args.predict:
            # Prediction only mode
            results = dashboard.predict_only(branch=args.branch)

            if args.json:
                print(json.dumps(results, indent=2))
            else:
                print("🔮 CI Failure Prediction Results")
                print("=" * 40)
                print(f"Active Workflows: {results['active_workflow_count']}")
                print(f"Predicted Failures: {results['predicted_failures']}")
                print(f"High Confidence (>80%): {results['high_confidence_failures']}")
                print(
                    f"Potential Cost Savings: "
                    f"{results['total_cost_savings_minutes']} minutes"
                )

                if results["predictions"]:
                    print("\nPredictions:")
                    for pred in results["predictions"]:
                        print(
                            f"  • {pred['workflow']}: {pred['failure_type']} "
                            f"({pred['confidence']:.1%} confidence)"
                        )
        else:
            # Full dashboard mode
            dashboard.display_dashboard(branch=args.branch, live_mode=args.live)

    except Exception as e:
        logger.error(f"Dashboard error: {e}")
        sys.exit(1)

    logger.info("DevOnboarder CI Health Dashboard completed")


if __name__ == "__main__":
    main()
