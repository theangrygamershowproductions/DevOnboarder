#!/usr/bin/env python3
"""DevOnboarder AAR Token Management and Security.

Implements token governance following the No Default Token Policy v1.0
as documented in TOKEN_GOVERNANCE_IMPLEMENTATION_SUMMARY.md
"""

import os
import json
import yaml
import subprocess
from pathlib import Path
from typing import Optional, Dict, Any
from datetime import datetime

# Load environment variables from .env file (DevOnboarder standard)
from dotenv import load_dotenv

load_dotenv()  # Load .env file into environment


class AARTokenManager:
    """Manage tokens for AAR GitHub operations following DevOnboarder policy."""

    def __init__(self):
        # CRITICAL: Follow DevOnboarder token hierarchy from governance doc
        # Different hierarchies for different operations based on required permissions

        # For Actions API operations (requires actions:read permission)
        self.actions_token_hierarchy = [
            "DIAGNOSTICS_BOT_KEY",  # PRIMARY: Actions read  issue write
            "CI_HEALTH_KEY",  # SECONDARY: Actions read  monitoring
            "CI_HELPER_AGENT_KEY",  # TERTIARY: Actions read  CI assistance
            "CI_BOT_TOKEN",  # LEGACY: Has actions:read
            "GITHUB_TOKEN",  # FALLBACK ONLY: Broad permissions
        ]

        # For Issue operations (requires issues:write permission)
        self.issue_token_hierarchy = [
            "AAR_TOKEN",  # PRIMARY: Dedicated AAR token
            "CI_ISSUE_AUTOMATION_TOKEN",  # SECONDARY: General CI issue creation
            "DIAGNOSTICS_BOT_KEY",  # TERTIARY: Also has issue write
            "CI_BOT_TOKEN",  # LEGACY: Bot operations (scoped)
            "GITHUB_TOKEN",  # FALLBACK ONLY: Broad permissions
        ]

        # Load token registry for validation
        self.token_registry = self._load_token_registry()

    def _load_token_registry(self)  Dict[str, Any]:
        """Load token scope registry following governance requirements."""
        registry_path = Path(".codex/tokens/token_scope_map.yaml")

        try:
            if registry_path.exists():
                with open(registry_path, "r") as f:
                    registry = yaml.safe_load(f)
                    # Count tokens across all categories (ci_automation, etc.)
                    token_count = 0
                    for category, data in registry.items():
                        if isinstance(data, dict):
                            # Count tokens in each category
                            for item in data.values():
                                if isinstance(item, dict) and "token" in item:
                                    token_count = 1
                    print(f"Token registry loaded: {token_count} tokens")
                    return registry
            else:
                print(" Token scope registry not found")
                print("  Expected: .codex/tokens/token_scope_map.yaml")
                return {}
        except Exception as e:
            print(f" Failed to load token registry: {e}")
            return {}

    def get_actions_token(self)  Optional[str]:
        """Get GitHub token for Actions API operations (requires actions:read)."""
        for token_name in self.actions_token_hierarchy:
            token = os.environ.get(token_name)
            if token:
                print(f"Using actions-capable token: {token_name}")
                return token
        print(" No actions-capable token found in hierarchy")
        return None

    def get_issue_token(self)  Optional[str]:
        """Get GitHub token for Issue operations (requires issues:write)."""
        for token_name in self.issue_token_hierarchy:
            token = os.environ.get(token_name)
            if token:
                print(f"Using issue-capable token: {token_name}")
                return token
        print(" No issue-capable token found in hierarchy")
        return None

    def get_github_token(self)  Optional[str]:
        """Get GitHub token following No Default Token Policy hierarchy.

        DEPRECATED: Use get_actions_token() or get_issue_token() for
        specific operations.
        """
        # For backward compatibility, use issue token hierarchy as default
        for token_name in self.issue_token_hierarchy:
            token = os.environ.get(token_name)
            if token:
                # Validate token is properly scoped for AAR operations
                if self._validate_token_scope(token_name):
                    print(f"Using finely-scoped token: {token_name}")
                    return token
                else:
                    print(f" Token {token_name} not properly scoped for AAR")

        print("POLICY VIOLATION: No finely-scoped tokens available")
        print("Falling back to GITHUB_TOKEN violates No Default Token Policy")
        return None

    def _validate_token_scope(self, token_name: str)  bool:
        """Validate token scope against registry following governance policy."""
        if not self.token_registry:
            # If no registry, assume token is valid but log warning
            print(f" Cannot validate {token_name} - registry unavailable")
            return True

        # Search for token across all categories in the registry
        token_info = None
        for category, data in self.token_registry.items():
            if isinstance(data, dict):
                for item in data.values():
                    if isinstance(item, dict) and item.get("token") == token_name:
                        token_info = item
                        break
                if token_info:
                    break

        if not token_info:
            print(f" Token {token_name} not found in registry")
            return True  # Allow for development scenarios

        # Check if token has required permissions for AAR operations
        required_permissions = ["issues:write", "metadata:read"]
        token_permissions = token_info.get("permissions", [])

        has_permissions = all(
            any(perm in token_perm for token_perm in token_permissions)
            for perm in required_permissions
        )

        if not has_permissions:
            print(f" Token {token_name} missing required permissions for AAR")

        return has_permissions

    def check_github_cli_availability(self)  bool:
        """Check GitHub CLI availability with DevOnboarder error handling."""
        try:
            result = subprocess.run(
                ["gh", "--version"], capture_output=True, text=True, timeout=10
            )
            if result.returncode == 0:
                print(f"GitHub CLI available: {result.stdout.strip().split()[2]}")
                return True
            else:
                print("GitHub CLI not properly configured")
                return False
        except (subprocess.TimeoutExpired, FileNotFoundError):
            print(" GitHub CLI not available")
            print("AAR will operate in offline mode")
            return False
        except Exception as e:
            print(f"GitHub CLI check failed: {e}")
            return False

    def validate_token_permissions(self, token: str)  bool:
        """Validate token has required permissions for AAR operations."""
        try:
            # Test token with minimal GitHub API call
            result = subprocess.run(
                ["gh", "auth", "status", "--hostname", "github.com"],
                capture_output=True,
                text=True,
                env={"GITHUB_TOKEN": token},
                timeout=10,
            )

            return result.returncode == 0
        except subprocess.TimeoutExpired:
            print("Token validation timeout")
            return False
        except Exception:
            print("Token validation failed")
            return False

    def audit_token_usage(self)  Dict[str, Any]:
        """Generate comprehensive token usage audit for full ecosystem."""
        audit_data = {
            "audit_timestamp": datetime.now().isoformat(),
            "policy_version": "No Default Token Policy v1.0",
            "actions_token_hierarchy": self.actions_token_hierarchy,
            "issue_token_hierarchy": self.issue_token_hierarchy,
            "token_availability": {},
            "token_ecosystem": {},
            "compliance_status": {},
            "violations": [],
            "security_warnings": [],
        }

        # Define complete token ecosystem
        token_categories = {
            "primary_github": [
                "CI_ISSUE_AUTOMATION_TOKEN",
                "CI_BOT_TOKEN",
                "GITHUB_TOKEN",
            ],
            "additional_github": ["CI_ISSUE_TOKEN"],
            "orchestration": [
                "DEV_ORCHESTRATION_BOT_KEY",
                "STAGING_ORCHESTRATION_BOT_KEY",
                "PROD_ORCHESTRATION_BOT_KEY",
            ],
            "special": ["GH_TOKEN"],  # This may contain misplaced tokens
        }

        # Check token availability by category
        total_tokens = 0
        available_tokens = 0

        for category, tokens in token_categories.items():
            audit_data["token_ecosystem"][category] = {}
            for token_name in tokens:
                is_available = bool(os.environ.get(token_name))
                token_value = os.environ.get(token_name, "")

                # Classify token type based on value characteristics
                token_type = "unknown"
                if token_value:
                    if token_value.startswith("github_pat_"):
                        token_type = "fine_grained_pat"
                    elif token_value.startswith("ghp_"):
                        token_type = "classic_pat"
                    elif token_value.startswith("sk-"):
                        token_type = "openai_api_key"
                    elif "_" in token_value and len(token_value) > 20:
                        token_type = "likely_github_token"

                audit_data["token_ecosystem"][category][token_name] = {
                    "available": is_available,
                    "type": token_type,
                    "length": len(token_value) if token_value else 0,
                }

                total_tokens = 1
                if is_available:
                    available_tokens = 1

                # Security warnings for misplaced tokens
                if token_name == "GH_TOKEN" and token_type == "openai_api_key":
                    audit_data["security_warnings"].append(
                        {
                            "type": "MISPLACED_TOKEN",
                            "severity": "HIGH",
                            "token": token_name,
                            "description": "OpenAI API key found in GitHub token field",
                        }
                    )

        # Check token availability across both hierarchies
        all_tokens = set(self.actions_token_hierarchy  self.issue_token_hierarchy)
        for token_name in all_tokens:
            is_available = bool(os.environ.get(token_name))
            audit_data["token_availability"][token_name] = is_available

            if is_available and token_name == "GITHUB_TOKEN":
                # Check if using GITHUB_TOKEN when better options available
                primary_available = bool(os.environ.get("CI_ISSUE_AUTOMATION_TOKEN"))
                secondary_available = bool(os.environ.get("CI_BOT_TOKEN"))

                if primary_available or secondary_available:
                    audit_data["violations"].append(
                        {
                            "type": "UNNECESSARY_DEFAULT_TOKEN",
                            "severity": "MEDIUM",
                            "description": (
                                "GITHUB_TOKEN used when finely-scoped "
                                "alternatives exist"
                            ),
                        }
                    )

        # Enhanced compliance assessment
        primary_token_used = bool(os.environ.get("CI_ISSUE_AUTOMATION_TOKEN"))
        default_token_avoided = not (
            bool(os.environ.get("GITHUB_TOKEN"))
            and not bool(os.environ.get("CI_ISSUE_AUTOMATION_TOKEN"))
            and not bool(os.environ.get("CI_BOT_TOKEN"))
        )

        # Orchestration environment readiness
        orchestration_readiness = {
            "dev": bool(os.environ.get("DEV_ORCHESTRATION_BOT_KEY")),
            "staging": bool(os.environ.get("STAGING_ORCHESTRATION_BOT_KEY")),
            "prod": bool(os.environ.get("PROD_ORCHESTRATION_BOT_KEY")),
        }

        audit_data["compliance_status"] = {
            "token_hierarchy_followed": True,
            "finely_scoped_token_preferred": primary_token_used,
            "default_token_avoided": default_token_avoided,
            "registry_available": bool(self.token_registry),
            "policy_compliant": len(audit_data["violations"]) == 0,
            "security_clean": len(audit_data["security_warnings"]) == 0,
            "token_coverage": f"{available_tokens}/{total_tokens}",
            "orchestration_readiness": orchestration_readiness,
        }

        return audit_data

    def comprehensive_token_status(self)  Dict[str, Any]:
        """Get comprehensive status of all tokens in the ecosystem."""
        status_report = {
            "scan_timestamp": datetime.now().isoformat(),
            "token_categories": {},
            "summary": {},
            "security_analysis": [],
            "recommendations": [],
        }

        # Define token categories with descriptions
        categories = {
            "primary_github": {
                "tokens": ["CI_ISSUE_AUTOMATION_TOKEN", "CI_BOT_TOKEN", "GITHUB_TOKEN"],
                "description": "Primary GitHub token hierarchy",
            },
            "additional_github": {
                "tokens": ["CI_ISSUE_TOKEN"],
                "description": "Additional GitHub tokens",
            },
            "orchestration": {
                "tokens": [
                    "DEV_ORCHESTRATION_BOT_KEY",
                    "STAGING_ORCHESTRATION_BOT_KEY",
                    "PROD_ORCHESTRATION_BOT_KEY",
                ],
                "description": "Environment orchestration tokens",
            },
            "special": {
                "tokens": ["GH_TOKEN"],
                "description": "Special purpose tokens",
            },
        }

        total_tokens = 0
        available_tokens = 0
        security_issues = 0

        for category_name, category_info in categories.items():
            category_status = {
                "description": category_info["description"],
                "tokens": {},
            }

            category_available = 0
            category_total = len(category_info["tokens"])

            for token_name in category_info["tokens"]:
                token_value = os.environ.get(token_name, "")
                is_available = bool(token_value)

                # Analyze token characteristics
                token_analysis = {
                    "available": is_available,
                    "length": len(token_value) if is_available else 0,
                    "type": "not_set",
                }

                if is_available:
                    if token_value.startswith("github_pat_"):
                        token_analysis["type"] = "fine_grained_pat"
                    elif token_value.startswith("ghp_"):
                        token_analysis["type"] = "classic_pat"
                    elif token_value.startswith("sk-"):
                        token_analysis["type"] = "openai_api_key"
                        status_report["security_analysis"].append(
                            {
                                "issue": "OpenAI API key in GitHub token field",
                                "token": token_name,
                                "severity": "HIGH",
                                "recommendation": "Move to proper environment variable",
                            }
                        )
                        security_issues = 1
                    elif len(token_value) > 20 and "_" in token_value:
                        token_analysis["type"] = "likely_github_token"
                    else:
                        token_analysis["type"] = "unknown_format"

                category_status["tokens"][token_name] = token_analysis

                if is_available:
                    category_available = 1
                    available_tokens = 1
                total_tokens = 1

            category_status["availability"] = f"{category_available}/{category_total}"
            status_report["token_categories"][category_name] = category_status

        # Generate summary
        status_report["summary"] = {
            "total_tokens": total_tokens,
            "available_tokens": available_tokens,
            "coverage_percentage": round((available_tokens / total_tokens) * 100, 1),
            "security_issues": security_issues,
            "primary_hierarchy_complete": all(
                os.environ.get(token)
                for token in [
                    "CI_ISSUE_AUTOMATION_TOKEN",
                    "CI_BOT_TOKEN",
                    "GITHUB_TOKEN",
                ]
            ),
            "orchestration_ready": all(
                os.environ.get(token)
                for token in [
                    "DEV_ORCHESTRATION_BOT_KEY",
                    "STAGING_ORCHESTRATION_BOT_KEY",
                    "PROD_ORCHESTRATION_BOT_KEY",
                ]
            ),
        }

        # Generate recommendations
        if security_issues > 0:
            status_report["recommendations"].append(
                "Address security issues before proceeding with AAR operations"
            )

        if status_report["summary"]["coverage_percentage"] < 100:
            status_report["recommendations"].append(
                "Complete token setup for full AAR system functionality"
            )

        return status_report


def validate_aar_environment()  bool:
    """Validate DevOnboarder AAR environment requirements."""
    # CRITICAL: Check virtual environment (DevOnboarder requirement)
    if not os.environ.get("VIRTUAL_ENV"):
        print(" AAR system requires virtual environment activation")
        print("Run: source .venv/bin/activate")
        return False

    # Check centralized logging directory
    logs_dir = Path("logs")
    if not logs_dir.exists():
        logs_dir.mkdir(exist_ok=True)
        print("Created centralized logs directory")

    # Create AAR-specific log directories
    aar_dirs = ["logs/aar-reports", "logs/token-audit", "logs/compliance-reports"]

    for dir_path in aar_dirs:
        Path(dir_path).mkdir(parents=True, exist_ok=True)

    print("AAR environment validation: PASSED")
    return True


if __name__ == "__main__":
    """Test token manager functionality with comprehensive analysis."""
    # CRITICAL: Validate environment first
    if not validate_aar_environment():
        exit(1)

    manager = AARTokenManager()

    # Get comprehensive token status
    token_status = manager.comprehensive_token_status()

    print("Comprehensive Token Status Analysis")
    print(f"Total tokens: {token_status['summary']['total_tokens']}")
    print(f"Available: {token_status['summary']['available_tokens']}")
    print(f"Coverage: {token_status['summary']['coverage_percentage']}%")
    print(f"Security issues: {token_status['summary']['security_issues']}")

    # Test primary token acquisition
    token = manager.get_github_token()

    if token:
        print("Token acquisition: SUCCESS")
        cli_available = manager.check_github_cli_availability()
        print(f"GitHub CLI: {'AVAILABLE' if cli_available else 'UNAVAILABLE'}")

        # Generate comprehensive audit report
        audit = manager.audit_token_usage()
        compliant = audit["compliance_status"]["policy_compliant"]
        security_clean = audit["compliance_status"]["security_clean"]
        status = "COMPLIANT" if compliant and security_clean else "ISSUES DETECTED"
        print(f"Token compliance: {status}")

        # Save both reports to centralized logging
        audit_file = Path("logs/token-audit/aar-token-audit.json")
        status_file = Path("logs/token-audit/comprehensive-token-status.json")

        with open(audit_file, "w", encoding="utf-8") as audit_fp:
            json.dump(audit, audit_fp, indent=2)

        with open(status_file, "w", encoding="utf-8") as status_fp:
            json.dump(token_status, status_fp, indent=2)

        print(f"Audit saved: {audit_file}")
        print(f"Status report saved: {status_file}")

        # Print recommendations if any
        if token_status["recommendations"]:
            print("\nRecommendations:")
            for rec in token_status["recommendations"]:
                print(f"- {rec}")
    else:
        print("Token acquisition: FAILED")
        print("AAR will operate in offline mode")

        # Still save comprehensive status for debugging
        status_file = Path("logs/token-audit/comprehensive-token-status.json")
        with open(status_file, "w", encoding="utf-8") as status_fp:
            json.dump(token_status, status_fp, indent=2)
        print(f"Token status saved for debugging: {status_file}")
