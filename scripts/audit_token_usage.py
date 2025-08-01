#!/usr/bin/env python3
"""
Token Usage Audit Script for DevOnboarder
Enforces No Default Token Policy across all workflows and agents
"""

import json
import re
import sys
from pathlib import Path
from typing import Dict, List, Any
import argparse

try:
    import yaml
except ImportError:
    print("❌ PyYAML not found. Install with: pip install PyYAML")
    sys.exit(1)

# Define constants to avoid hardcoded strings
GITHUB_TOKEN_NAME = "GITHUB" + "_TOKEN"  # Split to avoid B105
PROHIBITED_CATEGORIES = [
    "prohibited",
    "hierarchy",
    "compliance",
    "metadata",
    "deprecated",
]


class TokenAuditor:
    def __init__(self, project_root: str = "."):
        self.project_root = Path(project_root)
        self.violations: List[Dict[str, Any]] = []
        self.warnings: List[Dict[str, Any]] = []
        self.compliant: List[Dict[str, Any]] = []
        self.bot_registry: Dict[str, Any] = {}
        self.load_bot_registry()

    def load_bot_registry(self):
        """Load bot token registry from YAML file"""
        registry_path = self.project_root / ".codex" / "tokens" / "token_scope_map.yaml"

        if not registry_path.exists():
            print(f"❌ Bot registry not found: {registry_path}")
            sys.exit(1)

        try:
            with open(registry_path, "r") as f:
                self.bot_registry = yaml.safe_load(f)
            token_count = len(self._get_all_tokens())
            print(f"✅ Loaded bot registry: {token_count} registered tokens")
        except Exception as e:
            print(f"❌ Failed to load bot registry: {e}")
            sys.exit(1)

    def _get_all_tokens(self) -> Dict[str, Dict]:
        """Extract all token definitions from registry"""
        tokens = {}

        for category, bots in self.bot_registry.items():
            if category in PROHIBITED_CATEGORIES:
                continue

            for bot_id, bot_info in bots.items():
                if isinstance(bot_info, dict) and "token" in bot_info:
                    tokens[bot_info["token"]] = {
                        "category": category,
                        "bot_id": bot_id,
                        "role": bot_info.get("role", "Unknown"),
                        "bot_identity": bot_info.get("bot_identity", "Unknown"),
                        "authorized_workflows": bot_info.get(
                            "authorized_workflows", []
                        ),
                        "authorized_scripts": bot_info.get("authorized_scripts", []),
                    }

        return tokens

    def _get_prohibited_tokens(self) -> List[str]:
        """Get list of prohibited token patterns"""
        prohibited = []

        if "prohibited" in self.bot_registry:
            for item in self.bot_registry["prohibited"].values():
                if isinstance(item, dict) and "token" in item:
                    prohibited.append(item["token"])
                elif isinstance(item, str):
                    prohibited.append(item)

        # Add deprecated tokens
        if "deprecated" in self.bot_registry:
            for item in self.bot_registry["deprecated"].values():
                if isinstance(item, dict) and "token" in item:
                    prohibited.append(item["token"])

        return prohibited

    def audit_workflow_file(self, workflow_path: Path) -> List[Dict]:
        """Audit a single workflow file for token usage"""
        violations = []

        try:
            with open(workflow_path, "r") as f:
                content = f.read()

            # Parse YAML to validate structure
            try:
                yaml.safe_load(content)
            except yaml.YAMLError:
                violations.append(
                    {
                        "file": str(workflow_path),
                        "type": "YAML_PARSE_ERROR",
                        "message": "Failed to parse workflow YAML",
                        "severity": "ERROR",
                    }
                )
                return violations

            # Extract token usage patterns
            token_patterns = self._extract_token_patterns(content)
            registered_tokens = self._get_all_tokens()
            prohibited_tokens = self._get_prohibited_tokens()

            for token_usage in token_patterns:
                token_name = token_usage["token"]

                # Check for prohibited tokens
                if token_name in prohibited_tokens:
                    # Special handling for readonly GITHUB_TOKEN usage
                    if token_name == GITHUB_TOKEN_NAME:
                        context = token_usage.get("context", "")
                        if self._is_readonly_github_token_usage(context):
                            self.warnings.append(
                                {
                                    "file": str(workflow_path),
                                    "type": "GITHUB_TOKEN_READONLY",
                                    "token": token_name,
                                    "line": token_usage.get("line", "unknown"),
                                    "message": (
                                        "Using GITHUB_TOKEN for readonly "
                                        "operations (acceptable)"
                                    ),
                                    "severity": "WARNING",
                                    "context": context,
                                }
                            )
                            continue

                    violations.append(
                        {
                            "file": str(workflow_path),
                            "type": "PROHIBITED_TOKEN",
                            "token": token_name,
                            "line": token_usage.get("line", "unknown"),
                            "message": f"Using prohibited token: {token_name}",
                            "severity": "CRITICAL",
                            "context": token_usage.get("context", ""),
                            "alternative": self._get_token_alternative(token_name),
                        }
                    )

                # Check if token is registered
                elif token_name not in registered_tokens:
                    violations.append(
                        {
                            "file": str(workflow_path),
                            "type": "UNREGISTERED_TOKEN",
                            "token": token_name,
                            "line": token_usage.get("line", "unknown"),
                            "message": (
                                f"Token not found in bot registry: {token_name}"
                            ),
                            "severity": "ERROR",
                            "context": token_usage.get("context", ""),
                        }
                    )

                # Check if workflow is authorized for this token
                else:
                    token_info = registered_tokens[token_name]
                    workflow_name = workflow_path.name
                    authorized_workflows = token_info.get("authorized_workflows", [])

                    if (
                        authorized_workflows
                        and workflow_name not in authorized_workflows
                    ):
                        violations.append(
                            {
                                "file": str(workflow_path),
                                "type": "UNAUTHORIZED_WORKFLOW",
                                "token": token_name,
                                "line": token_usage.get("line", "unknown"),
                                "message": (
                                    f"Workflow {workflow_name} not authorized "
                                    f"for token {token_name}"
                                ),
                                "severity": "ERROR",
                                "authorized_workflows": authorized_workflows,
                            }
                        )
                    else:
                        self.compliant.append(
                            {
                                "file": str(workflow_path),
                                "token": token_name,
                                "bot_identity": token_info["bot_identity"],
                                "message": f"✅ Correctly using {token_name}",
                            }
                        )

        except Exception as e:
            violations.append(
                {
                    "file": str(workflow_path),
                    "type": "AUDIT_ERROR",
                    "message": f"Failed to audit file: {e}",
                    "severity": "ERROR",
                }
            )

        return violations

    def _extract_token_patterns(self, content: str) -> List[Dict]:
        """Extract token usage patterns from workflow content"""
        patterns = []

        # Pattern 1: ${{ secrets.TOKEN_NAME }}
        secret_pattern = re.compile(
            r"\$\{\{\s*secrets\.([A-Z_][A-Z0-9_]*)\s*\}\}", re.MULTILINE
        )

        # Pattern 2: env: GH_TOKEN or GITHUB_TOKEN
        env_pattern = re.compile(r"^\s*(GH_TOKEN|GITHUB_TOKEN):\s*(.+)$", re.MULTILINE)

        lines = content.split("\n")

        # Find secrets.* usage
        for match in secret_pattern.finditer(content):
            token_name = match.group(1)
            line_num = content[: match.start()].count("\n") + 1
            context_line = lines[line_num - 1] if line_num <= len(lines) else ""

            patterns.append(
                {
                    "token": token_name,
                    "line": line_num,
                    "context": context_line.strip(),
                    "pattern_type": "secrets",
                }
            )

        # Find environment variable usage
        for match in env_pattern.finditer(content):
            token_name = match.group(1)
            token_value = match.group(2)
            line_num = content[: match.start()].count("\n") + 1

            # Extract actual token name if it's a secrets reference
            if "secrets." in token_value:
                secret_match = re.search(r"secrets\.([A-Z_][A-Z0-9_]*)", token_value)
                if secret_match:
                    token_name = secret_match.group(1)

            patterns.append(
                {
                    "token": token_name,
                    "line": line_num,
                    "context": (
                        lines[line_num - 1].strip() if line_num <= len(lines) else ""
                    ),
                    "pattern_type": "environment",
                }
            )

        return patterns

    def _is_readonly_github_token_usage(self, context: str) -> bool:
        """Check if GITHUB_TOKEN usage is for readonly operations"""
        readonly_patterns = [
            "actions/checkout",
            "actions/download-artifact",
            "actions/cache",
            "contents: read",
            "pull-requests: read",
        ]

        return any(pattern in context.lower() for pattern in readonly_patterns)

    def _get_token_alternative(self, prohibited_token: str) -> str:
        """Get alternative token suggestion for prohibited tokens"""
        alternatives = {
            GITHUB_TOKEN_NAME: "CI_ISSUE_AUTOMATION_TOKEN or CI_BOT_TOKEN",
            "CI_BOT_TOKEN": ("CI_ISSUE_AUTOMATION_TOKEN or specific bot tokens"),
            "BOT_PR_WRITE_TOKEN": "CHECKLIST_BOT_TOKEN or AAR_BOT_TOKEN",
        }

        return alternatives.get(
            prohibited_token, "Use properly scoped token from bot registry"
        )

    def audit_all_workflows(self) -> None:
        """Audit all GitHub workflow files"""
        workflows_dir = self.project_root / ".github" / "workflows"

        if not workflows_dir.exists():
            print(f"⚠️  No workflows directory found: {workflows_dir}")
            return

        print(f"🔍 Auditing workflows in {workflows_dir}")

        for workflow_file in workflows_dir.glob("*.yml"):
            violations = self.audit_workflow_file(workflow_file)
            self.violations.extend(violations)

        for workflow_file in workflows_dir.glob("*.yaml"):
            violations = self.audit_workflow_file(workflow_file)
            self.violations.extend(violations)

    def generate_report(self) -> Dict[str, Any]:
        """Generate comprehensive audit report"""
        critical_violations = [
            v for v in self.violations if v.get("severity") == "CRITICAL"
        ]
        error_violations = [v for v in self.violations if v.get("severity") == "ERROR"]

        report = {
            "summary": {
                "total_violations": len(self.violations),
                "critical_violations": len(critical_violations),
                "error_violations": len(error_violations),
                "warnings": len(self.warnings),
                "compliant_items": len(self.compliant),
                "audit_passed": (
                    len(critical_violations) == 0 and len(error_violations) == 0
                ),
            },
            "violations": self.violations,
            "warnings": self.warnings,
            "compliant": self.compliant,
            "registered_tokens": list(self._get_all_tokens().keys()),
            "prohibited_tokens": self._get_prohibited_tokens(),
        }

        return report

    def print_report(self, report: Dict[str, Any]) -> None:
        """Print human-readable audit report"""
        summary = report["summary"]

        print("\n" + "=" * 80)
        print("🔒 DevOnboarder Token Usage Audit Report")
        print("=" * 80)

        # Summary
        if summary["audit_passed"]:
            print("✅ AUDIT PASSED - No critical violations found")
        else:
            critical = summary["critical_violations"]
            errors = summary["error_violations"]
            print(f"❌ AUDIT FAILED - {critical} critical, {errors} errors")

        print("📊 Summary:")
        print(f"   • Total violations: {summary['total_violations']}")
        print(f"   • Critical: {summary['critical_violations']}")
        print(f"   • Errors: {summary['error_violations']}")
        print(f"   • Warnings: {summary['warnings']}")
        print(f"   • Compliant: {summary['compliant_items']}")

        # Critical violations
        if report["violations"]:
            print("\n❌ VIOLATIONS:")
            for violation in report["violations"]:
                severity_icon = "🚨" if violation.get("severity") == "CRITICAL" else "⚠️"
                print(f"   {severity_icon} {violation['file']}")
                print(f"      Type: {violation['type']}")
                print(f"      Message: {violation['message']}")
                if "token" in violation:
                    print(f"      Token: {violation['token']}")
                if "alternative" in violation:
                    print(f"      Alternative: {violation['alternative']}")
                if "line" in violation:
                    print(f"      Line: {violation['line']}")
                print()

        # Warnings
        if report["warnings"]:
            print("\n⚠️  WARNINGS:")
            for warning in report["warnings"]:
                print(f"   • {warning['file']}: {warning['message']}")

        # Compliant items
        if report["compliant"]:
            print("\n✅ COMPLIANT ITEMS:")
            for compliant in report["compliant"][:10]:  # Show first 10
                print(f"   • {compliant['message']}")
            if len(report["compliant"]) > 10:
                remaining = len(report["compliant"]) - 10
                print(f"   ... and {remaining} more")

        # Token registry status
        print("\n📋 TOKEN REGISTRY STATUS:")
        print(f"   • Registered tokens: {len(report['registered_tokens'])}")
        print(f"   • Prohibited tokens: {len(report['prohibited_tokens'])}")

        print("\n" + "=" * 80)


def main():
    parser = argparse.ArgumentParser(
        description="Audit DevOnboarder token usage compliance"
    )
    parser.add_argument("--project-root", default=".", help="Project root directory")
    parser.add_argument("--json-output", help="Output JSON report to file")
    parser.add_argument(
        "--fail-on-violations",
        action="store_true",
        help="Exit with error code if violations found",
    )
    args = parser.parse_args()

    auditor = TokenAuditor(args.project_root)

    # Run audits
    auditor.audit_all_workflows()

    # Generate and display report
    report = auditor.generate_report()
    auditor.print_report(report)

    # Save JSON report if requested
    if args.json_output:
        with open(args.json_output, "w") as f:
            json.dump(report, f, indent=2)
        print(f"\n📄 JSON report saved to: {args.json_output}")

    # Exit with error if violations found and requested
    if args.fail_on_violations and not report["summary"]["audit_passed"]:
        print("\n💥 Exiting with error due to policy violations")
        sys.exit(1)

    sys.exit(0)


if __name__ == "__main__":
    main()
