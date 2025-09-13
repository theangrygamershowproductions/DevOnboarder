#!/usr/bin/env python3
"""
DevOnboarder CI Health Dashboard - AAR System Integration

Connects CI Health Dashboard monitoring data with the existing AAR (After Action Report)
system for automated failure analysis and pattern learning.

Features:
- Automatic AAR generation for predicted failures
- CI health data integration in AAR reports
- Pattern analysis for proactive improvements
- Cost savings tracking and reporting

Architecture: docs/CI_DASHBOARD_INTEGRATION_ARCHITECTURE.md
AAR System: scripts/generate_aar.sh, Makefile aar-* targets
"""

import argparse
import json
import logging
import os
import subprocess
import sys
from datetime import datetime
from pathlib import Path
from typing import Dict, List, Any

# DevOnboarder centralized logging pattern
LOG_DIR = Path(__file__).parent.parent / "logs"
LOG_DIR.mkdir(exist_ok=True)
timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
LOG_FILE = LOG_DIR / f"ci_health_aar_integration_{timestamp}.log"

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s - %(name)s - %(levelname)s - %(message)s",
    handlers=[logging.FileHandler(LOG_FILE), logging.StreamHandler(sys.stdout)],
)
logger = logging.getLogger("ci-health-aar-integration")


class CIHealthAARIntegrator:
    """
    Integrates CI Health Dashboard monitoring data with AAR system
    Follows DevOnboarder Token Architecture v2.1 for secure token management
    """

    def __init__(self):
        self.project_root = Path(__file__).parent.parent
        self.aar_reports_dir = self.project_root / "logs" / "aar-reports"
        self.aar_reports_dir.mkdir(exist_ok=True)

        # Token Architecture v2.1 compliance
        self._setup_token_environment()

    def _setup_token_environment(self):
        """
        Setup token environment following Token Architecture v2.1 hierarchy
        CI_ISSUE_AUTOMATION_TOKEN → CI_BOT_TOKEN → GITHUB_TOKEN
        """
        # Check for CI_ISSUE_AUTOMATION_TOKEN first
        token = os.getenv("CI_ISSUE_AUTOMATION_TOKEN")
        if token:
            os.environ["GITHUB_TOKEN"] = token
            print("Using CI_ISSUE_AUTOMATION_TOKEN for GitHub operations")
            return

        token = os.getenv("CI_BOT_TOKEN")
        if token:
            os.environ["GITHUB_TOKEN"] = token
            print("Using CI_BOT_TOKEN for GitHub operations")
            return

        if os.getenv("GITHUB_TOKEN"):
            print("Using GITHUB_TOKEN for GitHub operations")
        else:
            print("WARNING: No GitHub token available - AAR generation may fail")

    def get_ci_health_logs(
        self, workflow_id: str | None = None
    ) -> List[Dict[str, Any]]:
        """Get CI health monitoring logs for analysis"""
        ci_logs = []
        logs_dir = self.project_root / "logs"

        # Find CI health monitoring logs
        log_pattern = "ci_health_monitor_*.log"
        for log_file in logs_dir.glob(log_pattern):
            try:
                with open(log_file, "r") as f:
                    content = f.read()

                # Parse log content for structured data
                log_data = self._parse_ci_health_log(content, log_file.name)
                if workflow_id and workflow_id in content:
                    ci_logs.append(log_data)
                elif not workflow_id:
                    ci_logs.append(log_data)

            except Exception as e:
                logger.warning(f"Failed to parse CI health log {log_file}: {e}")

        return ci_logs

    def _parse_ci_health_log(self, content: str, filename: str) -> Dict[str, Any]:
        """Parse CI health log content into structured data"""
        log_data = {
            "filename": filename,
            "timestamp": None,
            "workflow": None,
            "job": None,
            "run_id": None,
            "prediction_results": {
                "failure_predicted": False,
                "confidence": 0.0,
                "failure_type": "none",
                "cost_savings": 0,
            },
            "git_context": {},
            "patterns_detected": [],
        }

        lines = content.split("\n")

        for line in lines:
            line = line.strip()

            # Parse timestamp
            if line.startswith("Timestamp:"):
                log_data["timestamp"] = line.split(":", 1)[1].strip()

            # Parse workflow info
            elif line.startswith("Workflow:"):
                log_data["workflow"] = line.split(":", 1)[1].strip()
            elif line.startswith("Job:"):
                log_data["job"] = line.split(":", 1)[1].strip()
            elif line.startswith("Run ID:"):
                log_data["run_id"] = line.split(":", 1)[1].strip()

            # Parse prediction results
            elif line.startswith("Failure Predicted:"):
                is_true = "true" in line.lower()
                log_data["prediction_results"]["failure_predicted"] = is_true
            elif line.startswith("Confidence:"):
                try:
                    confidence_str = line.split(":", 1)[1].strip()
                    log_data["prediction_results"]["confidence"] = float(confidence_str)
                except ValueError:
                    pass
            elif line.startswith("Failure Type:"):
                failure_type = line.split(":", 1)[1].strip()
                log_data["prediction_results"]["failure_type"] = failure_type
            elif line.startswith("Estimated Cost Savings:"):
                try:
                    cost_str = line.split(":", 1)[1].strip().split()[0]
                    log_data["prediction_results"]["cost_savings"] = int(cost_str)
                except (ValueError, IndexError):
                    pass

            # Detect pattern indicators
            elif "detached head" in line.lower():
                log_data["patterns_detected"].append("detached_head")
            elif "signature verification failed" in line.lower():
                log_data["patterns_detected"].append("signature_verification")

        return log_data

    def generate_enhanced_aar(
        self, workflow_id: str, create_issue: bool = False
    ) -> Dict[str, Any]:
        """Generate AAR with integrated CI health data"""
        logger.info(f"Generating enhanced AAR for workflow {workflow_id}")

        # Get CI health monitoring data
        ci_health_logs = self.get_ci_health_logs(workflow_id)

        # Analyze CI health patterns
        analysis = self._analyze_ci_health_patterns(ci_health_logs)

        # Generate base AAR using existing system
        aar_result = self._generate_base_aar(workflow_id, create_issue)

        # Enhance AAR with CI health data
        enhanced_aar = self._enhance_aar_with_ci_health(aar_result, analysis)

        # Save enhanced AAR
        filename = f"enhanced_aar_{workflow_id}_{timestamp}.md"
        enhanced_aar_file = self.aar_reports_dir / filename
        self._save_enhanced_aar(enhanced_aar, enhanced_aar_file)

        logger.info(f"Enhanced AAR generated: {enhanced_aar_file}")
        return enhanced_aar

    def _analyze_ci_health_patterns(
        self, ci_logs: List[Dict[str, Any]]
    ) -> Dict[str, Any]:
        """Analyze CI health patterns for AAR insights"""
        analysis = {
            "total_predictions": len(ci_logs),
            "failure_predictions": 0,
            "high_confidence_predictions": 0,
            "pattern_frequency": {},
            "total_cost_savings_potential": 0,
            "average_confidence": 0.0,
            "recommendations": [],
        }

        confidence_sum = 0.0
        patterns_found = []

        for log in ci_logs:
            pred = log["prediction_results"]

            if pred["failure_predicted"]:
                analysis["failure_predictions"] += 1

            if pred["confidence"] > 0.8:
                analysis["high_confidence_predictions"] += 1

            confidence_sum += pred["confidence"]
            analysis["total_cost_savings_potential"] += pred["cost_savings"]

            # Track pattern frequency
            failure_type = pred["failure_type"]
            if failure_type != "none":
                analysis["pattern_frequency"][failure_type] = (
                    analysis["pattern_frequency"].get(failure_type, 0) + 1
                )

            patterns_found.extend(log["patterns_detected"])

        if analysis["total_predictions"] > 0:
            total = analysis["total_predictions"]
            analysis["average_confidence"] = confidence_sum / total

        # Generate recommendations based on patterns
        if analysis["pattern_frequency"].get("detached_head", 0) > 0:
            analysis["recommendations"].append(
                "Consider adding branch protection rules "
                "to prevent detached HEAD issues"
            )

        if analysis["pattern_frequency"].get("signature_verification", 0) > 0:
            analysis["recommendations"].append(
                "Review commit signing setup and key availability in CI environment"
            )

        if analysis["total_cost_savings_potential"] > 10:
            savings = analysis["total_cost_savings_potential"]
            analysis["recommendations"].append(
                f"Implement auto-cancellation for high-confidence predictions "
                f"(potential savings: {savings} minutes)"
            )

        return analysis

    def _generate_base_aar(
        self, workflow_id: str, create_issue: bool
    ) -> Dict[str, Any]:
        """Generate base AAR using existing DevOnboarder AAR system"""
        try:
            # Use make command to generate AAR
            cmd = ["make", "aar-generate", f"WORKFLOW_ID={workflow_id}"]
            if create_issue:
                cmd.append("CREATE_ISSUE=true")

            result = subprocess.run(
                cmd, cwd=self.project_root, capture_output=True, text=True
            )

            return {
                "success": result.returncode == 0,
                "stdout": result.stdout,
                "stderr": result.stderr,
                "workflow_id": workflow_id,
            }

        except Exception as e:
            logger.error(f"Failed to generate base AAR: {e}")
            return {"success": False, "error": str(e), "workflow_id": workflow_id}

    def _enhance_aar_with_ci_health(
        self, aar_result: Dict[str, Any], analysis: Dict[str, Any]
    ) -> Dict[str, Any]:
        """Enhance AAR with CI health analysis data"""
        enhanced = {
            "workflow_id": aar_result["workflow_id"],
            "timestamp": datetime.now().isoformat(),
            "base_aar": aar_result,
            "ci_health_analysis": analysis,
            "integration_summary": self._generate_integration_summary(analysis),
        }

        return enhanced

    def _generate_integration_summary(self, analysis: Dict[str, Any]) -> str:
        """Generate human-readable integration summary"""
        summary_lines = [
            "# CI Health Dashboard Integration Summary",
            "",
            f"**Analysis Timestamp**: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}",
            "",
            "## Prediction Analysis",
            f"- Total Predictions: {analysis['total_predictions']}",
            f"- Failure Predictions: {analysis['failure_predictions']}",
            f"- High Confidence (>80%): {analysis['high_confidence_predictions']}",
            f"- Average Confidence: {analysis['average_confidence']:.1%}",
            "",
            "## Cost Optimization",
            f"- Total Potential Savings: "
            f"{analysis['total_cost_savings_potential']} minutes",
            f"- Estimated Monthly Savings: "
            f"{analysis['total_cost_savings_potential'] * 4} minutes",
            "",
            "## Pattern Analysis",
        ]

        if analysis["pattern_frequency"]:
            for pattern, count in analysis["pattern_frequency"].items():
                summary_lines.append(
                    f"- {pattern.replace('_', ' ').title()}: {count} occurrences"
                )
        else:
            summary_lines.append("- No failure patterns detected")

        summary_lines.extend(["", "## Recommendations"])

        if analysis["recommendations"]:
            for rec in analysis["recommendations"]:
                summary_lines.append(f"- {rec}")
        else:
            summary_lines.append("- No specific recommendations at this time")

        return "\n".join(summary_lines)

    def _save_enhanced_aar(self, enhanced_aar: Dict[str, Any], filepath: Path):
        """Save enhanced AAR to file"""
        try:
            with open(filepath, "w") as f:
                # Write enhanced AAR in markdown format
                f.write("# Enhanced After Action Report with CI Health Integration\n\n")
                f.write(f"**Workflow ID**: {enhanced_aar['workflow_id']}\n")
                f.write(f"**Generated**: {enhanced_aar['timestamp']}\n\n")

                # Write CI health integration summary
                f.write(enhanced_aar["integration_summary"])
                f.write("\n\n")

                # Write base AAR information
                f.write("## Base AAR Results\n\n")
                if enhanced_aar["base_aar"]["success"]:
                    f.write("✅ Base AAR generated successfully\n\n")
                    f.write("```\n")
                    f.write(enhanced_aar["base_aar"]["stdout"])
                    f.write("\n```\n")
                else:
                    f.write("❌ Base AAR generation failed\n\n")
                    f.write("```\n")
                    f.write(enhanced_aar["base_aar"].get("stderr", "Unknown error"))
                    f.write("\n```\n")

                # Write detailed analysis
                f.write("\n## Detailed CI Health Analysis\n\n")
                f.write("```json\n")
                f.write(json.dumps(enhanced_aar["ci_health_analysis"], indent=2))
                f.write("\n```\n")

        except Exception as e:
            logger.error(f"Failed to save enhanced AAR: {e}")
            raise


def main():
    """Main CLI entry point"""
    parser = argparse.ArgumentParser(
        description="DevOnboarder CI Health Dashboard - AAR System Integration",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  ci-health-aar-integration --workflow-id 12345
  ci-health-aar-integration --workflow-id 12345 --create-issue
  ci-health-aar-integration --analyze-patterns
        """,
    )

    parser.add_argument(
        "--workflow-id", "-w", help="Workflow run ID for AAR generation"
    )
    parser.add_argument(
        "--create-issue", "-i", action="store_true", help="Create GitHub issue for AAR"
    )
    parser.add_argument(
        "--analyze-patterns",
        "-p",
        action="store_true",
        help="Analyze CI health patterns across all logs",
    )
    parser.add_argument(
        "--verbose", "-v", action="store_true", help="Verbose logging output"
    )

    args = parser.parse_args()

    if args.verbose:
        logging.getLogger().setLevel(logging.DEBUG)

    integrator = CIHealthAARIntegrator()

    try:
        if args.workflow_id:
            # Generate enhanced AAR for specific workflow
            logger.info(f"Generating enhanced AAR for workflow {args.workflow_id}")
            result = integrator.generate_enhanced_aar(
                args.workflow_id, args.create_issue
            )

            print("✅ Enhanced AAR generated successfully")
            print(f"Workflow ID: {result['workflow_id']}")
            print(
                f"CI Health Predictions: "
                f"{result['ci_health_analysis']['total_predictions']}"
            )
            print(
                f"Failure Predictions: "
                f"{result['ci_health_analysis']['failure_predictions']}"
            )
            print(
                f"Cost Savings Potential: "
                f"{result['ci_health_analysis']['total_cost_savings_potential']} "
                f"minutes"
            )

        elif args.analyze_patterns:
            # Analyze patterns across all CI health logs
            logger.info("Analyzing CI health patterns across all logs")
            ci_logs = integrator.get_ci_health_logs()
            analysis = integrator._analyze_ci_health_patterns(ci_logs)

            print("📊 CI Health Pattern Analysis")
            print("=" * 40)
            print(f"Total Logs Analyzed: {analysis['total_predictions']}")
            print(f"Failure Predictions: {analysis['failure_predictions']}")
            print(
                f"High Confidence Predictions: "
                f"{analysis['high_confidence_predictions']}"
            )
            print(f"Average Confidence: {analysis['average_confidence']:.1%}")
            print(
                f"Total Cost Savings Potential: "
                f"{analysis['total_cost_savings_potential']} minutes"
            )

            if analysis["pattern_frequency"]:
                print("\nPattern Frequency:")
                for pattern, count in analysis["pattern_frequency"].items():
                    print(f"  {pattern.replace('_', ' ').title()}: {count}")

            if analysis["recommendations"]:
                print("\nRecommendations:")
                for rec in analysis["recommendations"]:
                    print(f"  • {rec}")
        else:
            parser.print_help()
            sys.exit(1)

    except Exception as e:
        logger.error(f"AAR integration error: {e}")
        sys.exit(1)

    logger.info("CI Health AAR integration completed")


if __name__ == "__main__":
    main()
