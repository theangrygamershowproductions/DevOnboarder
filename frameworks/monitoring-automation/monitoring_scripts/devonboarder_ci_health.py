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
import os
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


class PRCommentAnalyzer:
    """
    Integration between PR inline comments and CI health analysis
    Correlates Copilot suggestions with CI failures for targeted recommendations
    """

    def __init__(self, project_root: Path):
        self.project_root = project_root
        self.comments_script = project_root / "scripts" / "check_pr_inline_comments.sh"

    def get_pr_comments(self, pr_number: int) -> Dict[str, Any]:
        """Get PR inline comments using existing DevOnboarder infrastructure"""
        try:
            # Use existing script to get JSON output
            result = subprocess.run(
                ["bash", str(self.comments_script), "--format=json", str(pr_number)],
                capture_output=True,
                text=True,
                cwd=self.project_root,
            )

            if result.returncode == 0:
                comments_data = json.loads(result.stdout)
                return self._process_comments_data(comments_data)
            else:
                logger.warning(f"Failed to get PR comments: {result.stderr}")
                return {
                    "total_comments": 0,
                    "copilot_suggestions": [],
                    "error": result.stderr,
                }

        except Exception as e:
            logger.error(f"Error analyzing PR comments: {e}")
            return {"total_comments": 0, "copilot_suggestions": [], "error": str(e)}

    def _process_comments_data(self, comments_data: List[Dict]) -> Dict[str, Any]:
        """Process raw comments data into structured analysis"""
        copilot_suggestions = []
        suggestion_patterns = []

        for comment in comments_data:
            if comment.get("user", {}).get("login") == "Copilot":
                # Extract code suggestions and patterns
                body = comment.get("body", "")
                if "```suggestion" in body:
                    suggestion = self._extract_suggestion(body)
                    if suggestion:
                        copilot_suggestions.append(
                            {
                                "file": comment.get("path", ""),
                                "line": comment.get("line", 0),
                                "suggestion": suggestion,
                                "original_comment": body,
                                "url": comment.get("html_url", ""),
                                "created_at": comment.get("created_at", ""),
                            }
                        )

                        # Identify patterns that might relate to CI failures
                        patterns = self._identify_failure_patterns(body, suggestion)
                        suggestion_patterns.extend(patterns)

        copilot_count = len(
            [c for c in comments_data if c.get("user", {}).get("login") == "Copilot"]
        )

        return {
            "total_comments": len(comments_data),
            "copilot_comments": copilot_count,
            "copilot_suggestions": copilot_suggestions,
            "failure_patterns": list(set(suggestion_patterns)),
            "analysis_timestamp": datetime.now().isoformat(),
        }

    def _extract_suggestion(self, comment_body: str) -> Optional[str]:
        """Extract code suggestion from comment body"""
        lines = comment_body.split("\n")
        in_suggestion = False
        suggestion_lines = []

        for line in lines:
            if line.strip() == "```suggestion":
                in_suggestion = True
                continue
            elif line.strip() == "```" and in_suggestion:
                break
            elif in_suggestion:
                suggestion_lines.append(line)

        return "\n".join(suggestion_lines) if suggestion_lines else None

    def _identify_failure_patterns(self, comment: str, suggestion: str) -> List[str]:
        """Identify patterns in comments that might correlate with CI failures"""
        patterns = []

        # Check for common CI failure indicators in comments
        failure_indicators = {
            "syntax_error": ["syntax", "parse", "invalid", "malformed"],
            "dependency_issue": ["import", "module", "package", "dependency"],
            "type_error": ["type", "typing", "annotation"],
            "linting": ["lint", "format", "style", "whitespace"],
            "security": ["security", "vulnerability", "unsafe"],
            "performance": ["performance", "efficiency", "optimization"],
            "compatibility": ["compatibility", "version", "deprecated"],
        }

        comment_lower = comment.lower()
        suggestion_lower = suggestion.lower() if suggestion else ""

        for pattern_type, keywords in failure_indicators.items():
            keyword_match = any(
                keyword in comment_lower or keyword in suggestion_lower
                for keyword in keywords
            )
            if keyword_match:
                patterns.append(pattern_type)

        return patterns

    def correlate_with_ci_failures(
        self, pr_comments: Dict[str, Any], ci_status: Dict[str, Any]
    ) -> Dict[str, Any]:
        """Correlate PR comment suggestions with actual CI failures"""
        correlations = []

        # Get failed CI checks
        failed_checks = [
            check
            for check in ci_status.get("checks", [])
            if check.get("conclusion") == "failure"
        ]

        for suggestion in pr_comments.get("copilot_suggestions", []):
            suggestion_file = suggestion.get("file", "")

            # Look for correlations with failed checks
            for failed_check in failed_checks:
                correlation_strength = self._calculate_correlation_strength(
                    suggestion, failed_check, suggestion_file
                )

                if correlation_strength > 0.3:  # 30% correlation threshold
                    correlations.append(
                        {
                            "suggestion": suggestion,
                            "failed_check": failed_check,
                            "correlation_strength": correlation_strength,
                            "recommended_action": self._generate_recommendation(
                                suggestion, failed_check
                            ),
                        }
                    )

        high_confidence_count = len(
            [c for c in correlations if c["correlation_strength"] > 0.7]
        )

        return {
            "correlations": correlations,
            "total_correlations": len(correlations),
            "high_confidence_correlations": high_confidence_count,
        }

    def _calculate_correlation_strength(
        self, suggestion: Dict, failed_check: Dict, file_path: str
    ) -> float:
        """Calculate correlation strength between suggestion and CI failure"""
        strength = 0.0

        check_name = failed_check.get("name", "").lower()
        suggestion_comment = suggestion.get("original_comment", "").lower()

        # File-based correlation
        file_in_check = file_path in check_name
        path_parts_match = any(part in check_name for part in file_path.split("/"))
        if file_in_check or path_parts_match:
            strength += 0.3

        # Pattern-based correlation
        correlation_patterns = {
            "lint": ["format", "style", "whitespace", "ruff", "black"],
            "test": ["test", "pytest", "coverage"],
            "type": ["type", "mypy", "annotation"],
            "syntax": ["syntax", "parse", "compile"],
            "security": ["security", "bandit", "vulnerability"],
        }

        for pattern, keywords in correlation_patterns.items():
            if pattern in check_name:
                if any(keyword in suggestion_comment for keyword in keywords):
                    strength += 0.4

        return min(strength, 1.0)  # Cap at 100%

    def _generate_recommendation(self, suggestion: Dict, failed_check: Dict) -> str:
        """Generate actionable recommendation based on suggestion and failure"""
        file_path = suggestion.get("file", "")
        line_number = suggestion.get("line", 0)
        suggestion_text = suggestion.get("suggestion", "")

        check_name = failed_check.get("name", "check failure")
        suggestion_preview = suggestion_text[:100]

        return (
            f"Apply Copilot suggestion in {file_path}:{line_number} "
            f"to resolve {check_name}: {suggestion_preview}..."
        )


class DetachedHeadPredictor:
    """
    Advanced CI failure prediction with pattern recognition for detached HEAD issues
    Based on real 2025-09-13 failure analysis with 95% confidence detection
    """

    def __init__(self, config_file: Optional[Path] = None):
        # Load configurable critical workflows
        self.critical_workflows = self._load_critical_workflows(config_file)

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

    def _load_critical_workflows(self, config_file: Optional[Path] = None) -> List[str]:
        """Load critical workflows from configuration file or environment variable"""
        # Try environment variable first
        env_workflows = os.getenv("DEVONBOARDER_CRITICAL_WORKFLOWS")
        if env_workflows:
            return [w.strip() for w in env_workflows.split(",")]

        # Try configuration file
        if config_file and config_file.exists():
            try:
                with open(config_file, "r") as f:
                    config = json.load(f)
                    return config.get("critical_workflows", ["ci.yml", "auto-fix.yml"])
            except Exception as e:
                logger.warning(f"Failed to load config from {config_file}: {e}")

        # Default fallback
        return ["ci.yml", "auto-fix.yml"]

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
                if (
                    failure_type == "detached_head"
                    and workflow_name in self.critical_workflows
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

            # Only call helper functions if we have a valid failure type
            if primary_failure_type is not None:
                prediction["recommended_actions"] = self._get_recommended_actions(
                    primary_failure_type
                )
                prediction["cost_savings_minutes"] = self._estimate_cost_savings(
                    primary_failure_type, workflow_name
                )
            else:
                prediction["recommended_actions"] = [
                    "Review workflow logs for specific error patterns"
                ]
                prediction["cost_savings_minutes"] = 0

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
        self.project_root = Path(__file__).parent.parent
        self.pr_analyzer = PRCommentAnalyzer(self.project_root)

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
            "name,status,conclusion,createdAt,updatedAt,url,workflowName,databaseId",
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
            logs = self.get_workflow_logs(str(workflow["databaseId"]))

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

    def analyze_pr_with_ci_integration(self, pr_number: int) -> Dict[str, Any]:
        """
        Integrated PR analysis combining comment review with CI health diagnosis
        This is the main integration point between PR comments and CI failures
        """
        logger.info(f"Starting integrated analysis for PR #{pr_number}")

        # Step 1: Get PR comments and suggestions
        pr_comments = self.pr_analyzer.get_pr_comments(pr_number)
        logger.info(
            f"Found {pr_comments.get('total_comments', 0)} comments, "
            f"{len(pr_comments.get('copilot_suggestions', []))} suggestions"
        )

        # Step 2: Get current CI status for the PR
        ci_status = self._get_pr_ci_status(pr_number)

        # Step 3: Correlate comments with CI failures
        correlations = self.pr_analyzer.correlate_with_ci_failures(
            pr_comments, ci_status
        )

        # Step 4: Generate integrated analysis
        analysis = {
            "pr_number": pr_number,
            "timestamp": datetime.now().isoformat(),
            "pr_comments": pr_comments,
            "ci_status": ci_status,
            "correlations": correlations,
            "recommendations": self._generate_integrated_recommendations(
                pr_comments, ci_status, correlations
            ),
            "priority_score": self._calculate_priority_score(
                pr_comments, ci_status, correlations
            ),
        }

        logger.info(
            f"Analysis complete: {correlations.get('total_correlations', 0)} "
            f"correlations found, priority score: {analysis['priority_score']}"
        )

        return analysis

    def _get_pr_ci_status(self, pr_number: int) -> Dict[str, Any]:
        """Get CI status for a specific PR"""
        try:
            # Fields for pr checks command
            json_fields = (
                "bucket,completedAt,description,event,link,"
                "name,startedAt,state,workflow"
            )
            result = subprocess.run(
                ["gh", "pr", "checks", str(pr_number), "--json", json_fields],
                capture_output=True,
                text=True,
                cwd=self.project_root,
            )

            if result.returncode == 0:
                checks_data = json.loads(result.stdout)

                # Process checks data into structured format
                failed_checks = []
                passed_checks = []
                pending_checks = []

                for check in checks_data:
                    if check.get("conclusion") == "failure":
                        failed_checks.append(check)
                    elif check.get("conclusion") == "success":
                        passed_checks.append(check)
                    elif check.get("state") == "pending":
                        pending_checks.append(check)

                return {
                    "total_checks": len(checks_data),
                    "failed_checks": failed_checks,
                    "passed_checks": passed_checks,
                    "pending_checks": pending_checks,
                    "checks": checks_data,
                }
            else:
                logger.warning(
                    f"Failed to get CI status for PR {pr_number}: {result.stderr}"
                )
                return {"error": result.stderr, "checks": []}

        except Exception as e:
            logger.error(f"Error getting CI status for PR {pr_number}: {e}")
            return {"error": str(e), "checks": []}

    def _generate_integrated_recommendations(
        self, pr_comments: Dict, ci_status: Dict, correlations: Dict
    ) -> List[str]:
        """Generate integrated recommendations based on PR comments + CI status"""
        recommendations = []

        # High-confidence correlations get priority
        high_conf_correlations = correlations.get("high_confidence_correlations", 0)
        if high_conf_correlations > 0:
            recommendations.append(
                f"TARGET: HIGH PRIORITY: {high_conf_correlations} Copilot suggestions "
                f"directly address current CI failures"
            )

        # Copilot suggestions for pending checks
        copilot_suggestions = len(pr_comments.get("copilot_suggestions", []))
        pending_checks = len(ci_status.get("pending_checks", []))
        if copilot_suggestions > 0 and pending_checks > 0:
            recommendations.append(
                f"🔄 PROACTIVE: Apply {copilot_suggestions} Copilot suggestions "
                f"before {pending_checks} checks complete"
            )

        # Pattern-based recommendations
        failure_patterns = pr_comments.get("failure_patterns", [])
        if "linting" in failure_patterns:
            recommendations.append(
                "🔧 QUICK FIX: Copilot identified linting issues - "
                "apply suggestions to prevent CI failures"
            )

        if "security" in failure_patterns:
            recommendations.append(
                "SECURITY: SECURITY: Address security-related suggestions immediately"
            )

        # Failed check recommendations
        failed_checks = len(ci_status.get("failed_checks", []))
        if failed_checks > 0:
            recommendations.append(
                f"ERROR: FAILURES: {failed_checks} CI checks failed - "
                f"review correlations with comments"
            )

        if not recommendations:
            recommendations.append(
                "SUCCESS: STATUS: No immediate issues detected - "
                "PR appears ready for review"
            )

        return recommendations

    def _calculate_priority_score(
        self, pr_comments: Dict, ci_status: Dict, correlations: Dict
    ) -> float:
        """Calculate priority score (0-1) for the PR based on integrated analysis"""
        score = 0.0

        # High-confidence correlations significantly increase priority
        high_conf = correlations.get("high_confidence_correlations", 0)
        score += min(high_conf * 0.3, 0.6)  # Max 0.6 from correlations

        # Failed CI checks increase priority
        failed_checks = len(ci_status.get("failed_checks", []))
        score += min(failed_checks * 0.1, 0.3)  # Max 0.3 from failures

        # Security-related patterns increase priority
        patterns = pr_comments.get("failure_patterns", [])
        if "security" in patterns:
            score += 0.2
        if "syntax_error" in patterns:
            score += 0.15

        # Multiple Copilot suggestions increase urgency
        suggestions_count = len(pr_comments.get("copilot_suggestions", []))
        score += min(suggestions_count * 0.05, 0.2)  # Max 0.2

        return min(score, 1.0)  # Cap at 1.0

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
                    print("STATS: Active Workflow Status:")
                    print("-" * 40)
                    for workflow in analysis["active_workflows"]:
                        status_icon = (
                            "WARNING:"
                            if workflow["status"] == "in_progress"
                            else "ERROR:"
                        )
                        print(f"{status_icon} {workflow['name']}")

                        if (
                            "prediction" in workflow
                            and workflow["prediction"]["failure_predicted"]
                        ):
                            pred = workflow["prediction"]
                            confidence_icon = (
                                "ALERT:" if pred["confidence"] > 0.8 else "WARNING:"
                            )
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
                        print(f"QUICK: {pred['workflow']}: {pred['failure_type']}")
                        print(
                            f"   Confidence: [{confidence_bar:<10}] "
                            f"{pred['confidence']:.1%}"
                        )
                        print(f"   Actions: {pred['actions'][0]}")
                    print()

                # Display recommendations
                if analysis["recommendations"]:
                    print("TIP: Recommendations:")
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
    parser.add_argument(
        "--diagnose-pr",
        type=int,
        metavar="PR_NUMBER",
        help="Integrated PR diagnosis: analyze comments + CI failures for specific PR",
    )

    args = parser.parse_args()

    if args.verbose:
        logging.getLogger().setLevel(logging.DEBUG)

    # Initialize dashboard
    logger.info("Starting DevOnboarder CI Health Dashboard")
    dashboard = CIHealthDashboard()

    if not dashboard.github_token:
        print(
            "WARNING:  Warning: No GitHub token available. Dashboard will "
            "have limited functionality."
        )
        print("   Please ensure TOKEN_ARCHITECTURE_V2.1 is properly configured.")
        print()

    try:
        if args.diagnose_pr:
            # Integrated PR diagnosis mode
            results = dashboard.analyze_pr_with_ci_integration(args.diagnose_pr)

            if args.json:
                print(json.dumps(results, indent=2))
            else:
                print(f"INFO: Integrated PR Analysis: #{results['pr_number']}")
                print("=" * 60)

                # PR Comments Summary
                pr_comments = results["pr_comments"]
                print(
                    f"NOTE: PR Comments: {pr_comments.get('total_comments', 0)} total"
                )
                print(
                    f"BOT: Copilot Comments: {pr_comments.get('copilot_comments', 0)}"
                )
                suggestions_count = len(pr_comments.get("copilot_suggestions", []))
                print(f"TIP: Code Suggestions: {suggestions_count}")
                print()

                # CI Status Summary
                ci_status = results["ci_status"]
                print(
                    f"BUILD: CI Status: {ci_status.get('total_checks', 0)} total checks"
                )
                print(f"SUCCESS: Passed: {len(ci_status.get('passed_checks', []))}")
                print(f"ERROR: Failed: {len(ci_status.get('failed_checks', []))}")
                print(f"⏳ Pending: {len(ci_status.get('pending_checks', []))}")
                print()

                # Correlations
                correlations = results["correlations"]
                total_corr = correlations.get("total_correlations", 0)
                high_conf_corr = correlations.get("high_confidence_correlations", 0)
                print(f"LINK: Comment-CI Correlations: {total_corr} found")
                print(f"TARGET: High Confidence: {high_conf_corr}")
                print(f"ALERT: Priority Score: {results['priority_score']:.2f}/1.0")
                print()

                # Recommendations
                print("TIP: Integrated Recommendations:")
                print("-" * 40)
                for i, rec in enumerate(results["recommendations"], 1):
                    print(f"{i}. {rec}")

                # Show high-confidence correlations
                if high_conf_corr > 0:
                    print("\nINFO: High-Confidence Correlations:")
                    print("-" * 40)
                    for corr in correlations.get("correlations", []):
                        if corr["correlation_strength"] > 0.7:
                            suggestion = corr["suggestion"]
                            print(f"📁 {suggestion.get('file', 'Unknown')}")
                            print(f"📍 Line {suggestion.get('line', 'Unknown')}")
                            print(
                                f"LINK: {corr['correlation_strength']:.1%} correlation"
                            )
                            print(f"💬 {corr['recommended_action']}")
                            print()

        elif args.predict:
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
