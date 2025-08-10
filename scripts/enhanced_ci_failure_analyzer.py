#!/usr/bin/env python3
"""
Enhanced CI Failure Analyzer v1.0
Part of DevOnboarder Phase 4: CI Triage Guard Enhancement

Intelligent CI failure analysis with pattern recognition and automated
resolution recommendations. Integrates with Enhanced Potato Policy v2.0.
"""

import json
import re
import sys
import os
from datetime import datetime
from pathlib import Path
from typing import Dict, List, Any, Optional
import argparse


class CIFailureAnalyzer:
    """Enhanced CI failure analysis with intelligent pattern recognition."""

    def __init__(self, venv_path: Optional[str] = None):
        """Initialize analyzer with virtual environment validation."""
        self.venv_path = venv_path or os.environ.get("VIRTUAL_ENV")
        self.validate_virtual_environment()

        # Enhanced failure pattern database
        self.failure_patterns: Dict[str, Dict[str, Any]] = {
            "environment": {
                "patterns": [
                    r"\.venv/bin/activate: No such file or directory",
                    r"python: command not found",
                    r"VIRTUAL_ENV.*not set",
                    r"which python.*not found",
                    r"PATH.*does not contain",
                ],
                "severity": "high",
                "auto_fixable": True,
                "resolution": "create_virtual_environment",
            },
            "dependency": {
                "patterns": [
                    r"ModuleNotFoundError.*No module named",
                    r"npm ERR!.*missing.*dependency",
                    r"pip install failed",
                    r"Could not find a version that satisfies",
                    r"ERROR: No matching distribution found",
                ],
                "severity": "high",
                "auto_fixable": True,
                "resolution": "install_dependencies",
            },
            "timeout": {
                "patterns": [
                    r"timeout.*exceeded",
                    r"Process.*killed.*timeout",
                    r"Job.*cancelled.*exceeded.*time limit",
                    r"runner.*terminated.*timeout",
                ],
                "severity": "medium",
                "auto_fixable": True,
                "resolution": "retry_with_timeout",
            },
            "syntax": {
                "patterns": [
                    r"SyntaxError.*invalid syntax",
                    r"eslint.*error.*Parsing error",
                    r"black --check.*failed",
                    r"ruff.*syntax error",
                    r"mypy.*error",
                    # YAML/workflow syntax patterns
                    r"yamllint.*error.*wrong indentation",
                    r"yamllint.*error.*syntax error",
                    r"yamllint.*error.*expected.*but found",
                    r"could not find expected ':'",
                    r"expected <block end>, but found",
                    r"too many spaces inside brackets",
                    r"wrong indentation: expected \d+ but found \d+",
                    r"ParserError.*while parsing",
                    r"did not find expected key",
                ],
                "severity": "high",
                "auto_fixable": True,  # Many YAML issues can be auto-fixed
                "resolution": "fix_yaml_formatting",
            },
            "network": {
                "patterns": [
                    r"connection refused",
                    r"timeout.*connecting",
                    r"DNS resolution.*failed",
                    r"Could not resolve host",
                    r"Network is unreachable",
                ],
                "severity": "medium",
                "auto_fixable": True,
                "resolution": "retry_with_backoff",
            },
            "resource": {
                "patterns": [
                    r"out of memory",
                    r"No space left on device",
                    r"rate limit.*exceeded",
                    r"too many.*requests",
                    r"quota.*exceeded",
                ],
                "severity": "medium",
                "auto_fixable": True,
                "resolution": "resource_optimization",
            },
            "github_cli": {
                "patterns": [
                    r"Command.*'gh'.*returned non-zero exit status",
                    r"gh.*authentication.*failed",
                    r"gh.*permission.*denied",
                    r"gh.*repository not found",
                    r"gh.*rate limit.*exceeded",
                    r"GitHub CLI.*not authenticated",
                    r"gh run list.*failed",
                ],
                "severity": "medium",
                "auto_fixable": True,
                "resolution": "fix_github_cli_auth",
            },
            "pre_commit": {
                "patterns": [
                    r"hook id:.*\n.*exit code: [1-9]",
                    r"shellcheck.*Failed",
                    r"SC\d+.*error.*:",
                    r"files were modified by this hook",
                    r"pre-commit.*failed",
                    r"markdownlint.*Failed",
                    r"black.*Failed",
                    r"ruff.*Failed",
                ],
                "severity": "medium",
                "auto_fixable": True,
                "resolution": "fix_pre_commit_issues",
            },
        }

        # Resolution strategies
        self.resolution_strategies: Dict[str, Dict[str, Any]] = {
            "create_virtual_environment": {
                "command": "python -m venv .venv && source .venv/bin/activate",
                "description": "Create missing virtual environment",
                "success_rate": 0.95,
            },
            "install_dependencies": {
                "command": (
                    "pip install -e .[test] && "
                    "npm ci --prefix frontend && "
                    "npm ci --prefix bot"
                ),
                "description": "Reinstall all project dependencies",
                "success_rate": 0.85,
            },
            "retry_with_timeout": {
                "command": "retry_with_increased_timeout",
                "description": "Retry with 2x timeout",
                "success_rate": 0.70,
            },
            "retry_with_backoff": {
                "command": "retry_with_exponential_backoff",
                "description": "Retry with exponential backoff",
                "success_rate": 0.80,
            },
            "resource_optimization": {
                "command": "optimize_resource_usage",
                "description": "Clear caches and optimize resource usage",
                "success_rate": 0.75,
            },
            "manual_code_review": {
                "command": "create_code_review_issue",
                "description": "Create GitHub issue for manual code review",
                "success_rate": 1.0,  # Always creates issue
            },
            "fix_github_cli_auth": {
                "command": "gh auth status && gh auth refresh",
                "description": "Check and refresh GitHub CLI authentication",
                "success_rate": 0.90,
            },
            "fix_yaml_formatting": {
                "command": (
                    "yamllint -c .github/.yamllint-config "
                    ".github/workflows/**/*.yml && "
                    "yq --yaml-output '.' .github/workflows/*.yml "
                    "> /tmp/formatted.yml && "
                    "mv /tmp/formatted.yml .github/workflows/ci-failure-analyzer.yml"
                ),
                "description": "Fix YAML formatting and indentation issues",
                "success_rate": 0.90,
                "next_steps": [
                    "Check yamllint output for specific issues",
                    "Fix indentation (use 2 spaces for YAML)",
                    "Ensure consistent spacing in lists and mappings",
                    "Validate with: yamllint -c .github/.yamllint-config file.yml",
                    "Test with: yq '.' file.yml to verify syntax",
                ],
            },
            "fix_pre_commit_issues": {
                "command": (
                    "pre-commit run --all-files && "
                    "git add . && "
                    "git commit --amend --no-edit"
                ),
                "description": "Fix pre-commit hooks and update commit",
                "success_rate": 0.85,
            },
        }

    def validate_virtual_environment(self) -> None:
        """Validate virtual environment compliance per DevOnboarder."""
        if not self.venv_path:
            print("FAILED Virtual environment not detected")
            print("IDEA DevOnboarder requires virtual environment isolation")
            print("CONFIG Run: python -m venv .venv && source .venv/bin/activate")
            sys.exit(1)

        venv_python = Path(self.venv_path) / "bin" / "python"
        if not venv_python.exists():
            print(f"FAILED Virtual environment invalid: {self.venv_path}")
            sys.exit(1)

        print(f"SUCCESS Virtual environment validated: {self.venv_path}")

    def analyze_failure_log(self, log_content: str) -> Dict[str, Any]:
        """Analyze CI failure log and classify failure types."""
        analysis: Dict[str, Any] = {
            "timestamp": datetime.now().isoformat(),
            "log_size": len(log_content),
            "detected_failures": [],
            "primary_failure": None,
            "recommended_resolution": None,
            "auto_fixable": False,
            "confidence_score": 0.0,
        }

        # Pattern matching across all failure types
        for failure_type, config in self.failure_patterns.items():
            matches = []
            for pattern in config["patterns"]:
                pattern_matches = re.finditer(
                    pattern, log_content, re.IGNORECASE | re.MULTILINE
                )
                for match in pattern_matches:
                    matches.append(
                        {
                            "pattern": pattern,
                            "match": match.group(),
                            "line_context": self._extract_line_context(
                                log_content, match.start()
                            ),
                        }
                    )

            if matches:
                failure_info = {
                    "type": failure_type,
                    "severity": config["severity"],
                    "auto_fixable": config["auto_fixable"],
                    "resolution": config["resolution"],
                    "matches": matches,
                    "match_count": len(matches),
                }
                analysis["detected_failures"].append(failure_info)

        # Determine primary failure and resolution
        if analysis["detected_failures"]:
            # Sort by severity and match count
            severity_order = {"high": 3, "medium": 2, "low": 1}
            failures = analysis["detected_failures"]
            sorted_failures = sorted(
                failures,
                key=lambda x: (severity_order[x["severity"]], x["match_count"]),
                reverse=True,
            )
            primary = sorted_failures[0]
            analysis["primary_failure"] = primary
            analysis["recommended_resolution"] = self.resolution_strategies[
                primary["resolution"]
            ]
            analysis["auto_fixable"] = primary["auto_fixable"]
            analysis["confidence_score"] = min(
                0.95, 0.3 + (primary["match_count"] * 0.1)
            )

        return analysis

    def _extract_line_context(
        self, content: str, position: int, context_lines: int = 2
    ) -> List[str]:
        """Extract surrounding lines for better failure context."""
        lines = content[:position].split("\n")
        start_line = max(0, len(lines) - context_lines - 1)
        end_line = min(len(content.split("\n")), len(lines) + context_lines)

        all_lines = content.split("\n")
        return all_lines[start_line:end_line]

    def generate_resolution_plan(self, analysis: Dict[str, Any]) -> Dict[str, Any]:
        """Generate automated resolution plan based on failure analysis."""
        if not analysis["primary_failure"]:
            return {
                "status": "no_failures_detected",
                "message": "No recognized failure patterns found",
                "recommended_action": "manual_investigation",
            }

        primary = analysis["primary_failure"]
        resolution = analysis["recommended_resolution"]

        plan = {
            "failure_type": primary["type"],
            "severity": primary["severity"],
            "auto_fixable": primary["auto_fixable"],
            "confidence": analysis["confidence_score"],
            "resolution_strategy": primary["resolution"],
            "estimated_success_rate": resolution["success_rate"],
            "description": resolution["description"],
            "command": resolution["command"],
            "next_steps": [],
        }

        # Add specific next steps based on failure type
        if primary["auto_fixable"] and analysis["confidence_score"] > 0.7:
            plan["next_steps"] = [
                "Automated resolution available",
                f"Execute: {resolution['command']}",
                "Monitor resolution success",
                "Escalate if resolution fails",
            ]
        else:
            plan["next_steps"] = [
                "Manual intervention required",
                "Create GitHub issue with failure analysis",
                "Assign to appropriate team member",
                "Track resolution progress",
            ]

        return plan

    def save_analysis_report(self, analysis: Dict[str, Any], output_path: str) -> None:
        """Save analysis report with DevOnboarder-compliant formatting."""
        report = {
            "enhanced_ci_analysis": {
                "version": "1.0",
                "framework": "Phase 4: CI Triage Guard Enhancement",
                "virtual_env": self.venv_path,
                "analysis": analysis,
                "resolution_plan": self.generate_resolution_plan(analysis),
            }
        }

        with open(output_path, "w", encoding="utf-8") as f:
            json.dump(report, f, indent=2, ensure_ascii=False)

        print(f"STATS Analysis report saved: {output_path}")

    def generate_aar_integration(
        self,
        analysis: Dict[str, Any],
        resolution_plan: Dict[str, Any],
        workflow_run_id: Optional[str] = None,
    ) -> bool:
        """Generate AAR report for significant CI failures.

        Parameters
        ----------
        analysis : Dict[str, Any]
            CI failure analysis results
        resolution_plan : Dict[str, Any]
            Automated resolution plan (used for context)
        workflow_run_id : Optional[str]
            GitHub workflow run ID for context

        Returns
        -------
        bool
            True if AAR generation successful, False otherwise
        """
        try:
            import subprocess  # noqa: S404

            # Check if AAR generator is available
            aar_script = Path("scripts/generate_aar.py")
            if not aar_script.exists():
                print("   WARNING AAR generator script not found")
                return False

            # Prepare AAR data
            primary_failure = analysis.get("primary_failure", {})
            failure_type = primary_failure.get("type", "Unknown")
            aar_title = f"CI Failure Analysis - {failure_type}"

            # Use Python AAR generator with proper arguments
            aar_script = Path("scripts/generate_aar.py")
            if not aar_script.exists():
                print("   WARNING AAR generator script not found")
                return False

            # Create AAR command
            cmd = [sys.executable, str(aar_script)]
            if workflow_run_id:
                cmd.extend(["--workflow-run-id", workflow_run_id])

            # Add create-issue flag for automatic GitHub integration
            cmd.append("--create-issue")

            # Add analysis context as environment variables
            env = os.environ.copy()
            confidence = analysis.get("confidence_score", 0)
            env["CI_ANALYSIS_CONFIDENCE"] = str(confidence)
            auto_fixable = analysis.get("auto_fixable", False)
            env["CI_ANALYSIS_AUTO_FIXABLE"] = str(auto_fixable)
            failure_count = len(analysis.get("detected_failures", []))
            env["CI_ANALYSIS_FAILURE_COUNT"] = str(failure_count)

            # Execute AAR generation with security-aware subprocess
            result = subprocess.run(  # noqa: S603
                cmd,
                env=env,
                capture_output=True,
                text=True,
                timeout=60,
                cwd=Path.cwd(),
                check=False,  # Don't raise on non-zero exit
            )

            if result.returncode == 0:
                print(f"   SYMBOL AAR generated: {aar_title}")
                # Use resolution_plan context for logging
                strategy = resolution_plan.get("resolution_strategy", "unknown")
                print(f"   CONFIG Resolution strategy: {strategy}")
                return True
            else:
                print(f"   FAILED AAR generation failed: {result.stderr}")
                return False

        except (subprocess.TimeoutExpired, subprocess.SubprocessError) as e:
            print(f"   FAILED AAR subprocess error: {e}")
            return False
        except OSError as e:
            print(f"   FAILED AAR file system error: {e}")
            return False


def main():
    """Main execution function with virtual environment compliance."""
    parser = argparse.ArgumentParser(
        description="Enhanced CI Failure Analyzer - Phase 4: CI Triage Guard"
    )
    parser.add_argument("log_files", nargs="+", help="CI log files to analyze")
    parser.add_argument(
        "--output",
        default="ci_failure_analysis.json",
        help="Output file for analysis report",
    )
    parser.add_argument(
        "--auto-resolve",
        action="store_true",
        help="Attempt automatic resolution for high-confidence failures",
    )
    parser.add_argument(
        "--generate-aar",
        action="store_true",
        help="Generate After Action Report for significant failures",
    )
    parser.add_argument(
        "--workflow-run-id",
        help="GitHub workflow run ID for AAR generation",
    )

    args = parser.parse_args()

    # Initialize analyzer with virtual environment validation
    analyzer = CIFailureAnalyzer()

    # Process all log files
    combined_log = ""
    for log_file in args.log_files:
        if Path(log_file).exists():
            with open(log_file, "r", encoding="utf-8", errors="ignore") as f:
                combined_log += f"\n--- {log_file} ---\n"
                combined_log += f.read()
        else:
            print(f"WARNING  Log file not found: {log_file}")

    if not combined_log.strip():
        print("FAILED No valid log content found")
        sys.exit(1)

    # Analyze failures
    print("SEARCH Analyzing CI failures with enhanced pattern recognition...")
    analysis = analyzer.analyze_failure_log(combined_log)

    # Generate resolution plan
    resolution_plan = analyzer.generate_resolution_plan(analysis)

    # Output results
    print("\nSTATS Analysis Results:")
    print(f"   Detected failures: {len(analysis['detected_failures'])}")
    if analysis["primary_failure"]:
        primary = analysis["primary_failure"]
        # Type safety: ensure primary is dict before accessing
        if primary and isinstance(primary, dict):
            primary_type = str(primary.get("type", "unknown"))
            primary_severity = str(primary.get("severity", "unknown"))
            print(f"   Primary failure: {primary_type} (severity: {primary_severity})")
            print(f"   Auto-fixable: {primary.get('auto_fixable', False)}")
            print(f"   Confidence: {analysis['confidence_score']:.1%}")

    print("\nCONFIG Resolution Plan:")
    strategy = resolution_plan.get("resolution_strategy", "manual_investigation")
    print(f"   Strategy: {strategy}")
    success_rate = resolution_plan.get("estimated_success_rate", 0)
    print(f"   Success rate: {success_rate:.1%}")
    description = resolution_plan.get("description", "Manual investigation required")
    print(f"   Description: {description}")

    # Save analysis report
    analyzer.save_analysis_report(analysis, args.output)

    # Auto-resolution if requested and high confidence
    auto_conditions = (
        args.auto_resolve
        and analysis["auto_fixable"]
        and analysis["confidence_score"] > 0.8
    )
    if auto_conditions:
        print("\nBot Attempting auto-resolution...")
        print(f"   Command: {resolution_plan.get('command', 'N/A')}")
        # Note: Actual auto-resolution would be implemented here
        print("   Auto-resolution framework ready for implementation")

    # AAR Integration: Generate AAR for significant failures
    aar_conditions = (
        args.generate_aar
        or (analysis["confidence_score"] > 0.7 and not analysis["auto_fixable"])
        or len(analysis["detected_failures"]) > 2
    )
    if aar_conditions:
        print("\nSYMBOL Generating After Action Report...")
        aar_success = analyzer.generate_aar_integration(
            analysis, resolution_plan, args.workflow_run_id
        )
        if aar_success:
            print("   SUCCESS AAR generated successfully")
        else:
            print("   WARNING AAR generation encountered issues")

    print("\nSUCCESS Enhanced CI failure analysis complete")


if __name__ == "__main__":
    main()
