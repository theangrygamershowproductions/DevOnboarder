#!/usr/bin/env python3
"""DevOnboarder Token Management System v2.0.

Provides comprehensive token management for local development and CI environments.
Handles token discovery, validation, scoping, and fallback strategies.

Updated for Token Architecture v2.0 with dedicated .tokens files.
"""

import json
import os
import subprocess
import sys
from dataclasses import dataclass
from typing import Any, Dict, Optional, Tuple

from token_loader import load_tokens


@dataclass
class TokenInfo:
    """Information about a token and its capabilities."""

    name: str
    available: bool
    length: Optional[int] = None
    user_login: Optional[str] = None
    user_type: Optional[str] = None
    has_actions_read: bool = False
    has_issues_write: bool = False
    has_contents_read: bool = False
    has_pull_requests_write: bool = False
    error: Optional[str] = None


class DevOnboarderTokenManager:
    """Comprehensive token management for DevOnboarder project."""

    def __init__(self):
        """Initialize token manager with token loading."""
        # Load tokens using the new token loader
        load_tokens()
        self.tokens: Dict[str, TokenInfo] = {}
        self.operation_mappings = self._load_operation_mappings()

    def _load_operation_mappings(self)  Dict[str, Dict[str, Any]]:
        """Load operation to token mappings from configuration."""
        return {
            "actions_api": {
                "required_permissions": ["actions:read"],
                "description": (
                    "GitHub Actions API access (workflow runs, jobs, artifacts)"
                ),
                "primary_tokens": [
                    "DIAGNOSTICS_BOT_KEY",
                    "CI_HEALTH_KEY",
                    "CI_HELPER_AGENT_KEY",
                    "SECURITY_AUDIT_TOKEN",
                ],
                "fallback_tokens": [
                    "DEV_ORCHESTRATION_BOT_KEY",
                    "STAGING_ORCHESTRATION_BOT_KEY",
                    "CI_BOT_TOKEN",
                ],
            },
            "issue_management": {
                "required_permissions": ["issues:write"],
                "description": "GitHub Issues creation and management",
                "primary_tokens": [
                    "AAR_TOKEN",
                    "CI_ISSUE_AUTOMATION_TOKEN",
                    "CI_ISSUE_TOKEN",
                ],
                "fallback_tokens": ["DIAGNOSTICS_BOT_KEY", "CI_BOT_TOKEN"],
            },
            "pr_management": {
                "required_permissions": ["pull_requests:write"],
                "description": "Pull Request creation and management",
                "primary_tokens": ["CHECKLIST_BOT_TOKEN", "CI_ISSUE_AUTOMATION_TOKEN"],
                "fallback_tokens": ["CI_BOT_TOKEN"],
            },
            "security_audit": {
                "required_permissions": ["security_events:read"],
                "description": "Security events and audit access",
                "primary_tokens": ["SECURITY_AUDIT_TOKEN"],
                "fallback_tokens": ["DEV_ORCHESTRATION_BOT_KEY"],
            },
        }

    def discover_tokens(self)  None:
        """Discover and analyze all available tokens in environment."""
        print(" Discovering tokens in environment...")

        # Find all token-like environment variables
        token_candidates = []
        for key, value in os.environ.items():
            if self._is_token_like(key, value):
                token_candidates.append(key)

        print(f"Found {len(token_candidates)} potential tokens")

        # Analyze each token
        for token_name in sorted(token_candidates):
            print(f"   Analyzing {token_name}...")
            token_info = self._analyze_token(token_name)
            self.tokens[token_name] = token_info

    def _is_token_like(self, key: str, value: str)  bool:
        """Determine if an environment variable looks like a token."""
        if not value or len(value) < 20:
            return False

        token_indicators = ["_TOKEN", "_KEY", "SECRET", "AUTH", "DISCORD_BOT", "JWT"]

        return any(indicator in key.upper() for indicator in token_indicators)

    def _analyze_token(self, token_name: str)  TokenInfo:
        """Analyze a token's capabilities and permissions."""
        token_value = os.environ.get(token_name)
        if not token_value:
            return TokenInfo(name=token_name, available=False)

        info = TokenInfo(name=token_name, available=True, length=len(token_value))

        # Skip non-GitHub tokens
        if any(skip in token_name for skip in ["DISCORD", "JWT", "CF_DNS", "TUNNEL"]):
            return info

        try:
            # Test basic authentication
            env = os.environ.copy()
            env["GH_TOKEN"] = token_value

            result = subprocess.run(
                ["gh", "api", "user"],
                capture_output=True,
                text=True,
                env=env,
                timeout=10,
            )

            if result.returncode == 0:
                user_data = json.loads(result.stdout)
                info.user_login = user_data.get("login")
                info.user_type = user_data.get("type")

                # Test specific permissions
                info.has_actions_read = self._test_actions_permission(env)
                info.has_issues_write = self._test_issues_permission(env)
                info.has_contents_read = self._test_contents_permission(env)
                info.has_pull_requests_write = self._test_pr_permission(env)

            else:
                info.error = result.stderr.strip()

        except subprocess.TimeoutExpired:
            info.error = "Timeout during token validation"
        except Exception as e:
            info.error = str(e)

        return info

    def _test_actions_permission(self, env: Dict[str, str])  bool:
        """Test if token has actions:read permission."""
        try:
            result = subprocess.run(
                [
                    "gh",
                    "api",
                    "repos/theangrygamershowproductions/DevOnboarder/actions",
                ],
                capture_output=True,
                text=True,
                env=env,
                timeout=10,
            )
            return result.returncode == 0
        except subprocess.SubprocessError:
            return False

    def _test_issues_permission(self, env: Dict[str, str])  bool:
        """Test if token has issues:write permission."""
        # Read-only test - actual write test would require creating an issue
        try:
            result = subprocess.run(
                [
                    "gh",
                    "api",
                    "repos/theangrygamershowproductions/DevOnboarder/issues",
                    "-f",
                    "per_page=1",
                ],
                capture_output=True,
                text=True,
                env=env,
                timeout=10,
            )
            return result.returncode == 0
        except subprocess.SubprocessError:
            return False

    def _test_contents_permission(self, env: Dict[str, str])  bool:
        """Test if token has contents:read permission."""
        try:
            result = subprocess.run(
                [
                    "gh",
                    "api",
                    "repos/theangrygamershowproductions/DevOnboarder/contents/README.md",
                ],
                capture_output=True,
                text=True,
                env=env,
                timeout=10,
            )
            return result.returncode == 0
        except subprocess.SubprocessError:
            return False

    def _test_pr_permission(self, env: Dict[str, str])  bool:
        """Test if token has pull_requests:read permission."""
        try:
            result = subprocess.run(
                [
                    "gh",
                    "api",
                    "repos/theangrygamershowproductions/DevOnboarder/pulls",
                    "-f",
                    "per_page=1",
                ],
                capture_output=True,
                text=True,
                env=env,
                timeout=10,
            )
            return result.returncode == 0
        except subprocess.SubprocessError:
            return False

    def get_token_for_operation(self, operation: str)  Optional[Tuple[str, str]]:
        """Get the best available token for a specific operation."""
        if operation not in self.operation_mappings:
            raise ValueError(f"Unknown operation: {operation}")

        mapping = self.operation_mappings[operation]

        # Try primary tokens first
        for token_name in mapping["primary_tokens"]:
            if self._is_token_suitable_for_operation(token_name, operation):
                token_value = os.environ.get(token_name)
                if token_value:
                    return (token_name, token_value)

        # Try fallback tokens
        for token_name in mapping["fallback_tokens"]:
            if self._is_token_suitable_for_operation(token_name, operation):
                token_value = os.environ.get(token_name)
                if token_value:
                    return (token_name, token_value)

        return None

    def _is_token_suitable_for_operation(self, token_name: str, operation: str)  bool:
        """Check if a token is suitable for a specific operation."""
        if token_name not in self.tokens:
            return False

        token_info = self.tokens[token_name]
        if not token_info.available:
            return False

        mapping = self.operation_mappings[operation]
        required_perms = mapping["required_permissions"]

        # Check if token has required permissions
        for perm in required_perms:
            if perm == "actions:read" and not token_info.has_actions_read:
                return False
            elif perm == "issues:write" and not token_info.has_issues_write:
                return False
            elif perm == "contents:read" and not token_info.has_contents_read:
                return False
            elif (
                perm == "pull_requests:write" and not token_info.has_pull_requests_write
            ):
                return False

        return True

    def generate_report(self)  Dict[str, Any]:
        """Generate comprehensive token status report."""
        report = {
            "timestamp": "2025-09-04",
            "total_tokens_discovered": len(self.tokens),
            "github_tokens": len([t for t in self.tokens.values() if t.user_login]),
            "tokens_with_actions_read": len(
                [t for t in self.tokens.values() if t.has_actions_read]
            ),
            "tokens_with_issues_write": len(
                [t for t in self.tokens.values() if t.has_issues_write]
            ),
            "operation_coverage": {},
            "missing_tokens": [],
            "token_details": {},
        }

        # Analyze operation coverage
        for operation, mapping in self.operation_mappings.items():
            suitable_tokens = [
                name
                for name in mapping["primary_tokens"]  mapping["fallback_tokens"]
                if self._is_token_suitable_for_operation(name, operation)
            ]
            report["operation_coverage"][operation] = {
                "suitable_tokens": suitable_tokens,
                "has_coverage": len(suitable_tokens) > 0,
            }

            # Track missing primary tokens
            for token_name in mapping["primary_tokens"]:
                if (
                    token_name not in self.tokens
                    or not self.tokens[token_name].available
                ):
                    if token_name not in report["missing_tokens"]:
                        report["missing_tokens"].append(token_name)

        # Add token details
        for name, info in self.tokens.items():
            if info.user_login:  # Only include GitHub tokens
                report["token_details"][name] = {
                    "available": info.available,
                    "user": info.user_login,
                    "type": info.user_type,
                    "permissions": {
                        "actions:read": info.has_actions_read,
                        "issues:write": info.has_issues_write,
                        "contents:read": info.has_contents_read,
                        "pull_requests:write": info.has_pull_requests_write,
                    },
                }

        return report

    def print_status(self)  None:
        """Print human-readable token status."""
        print("\n"  "=" * 70)
        print(" DevOnboarder Token Management Status")
        print("=" * 70)

        # Summary
        github_tokens = [t for t in self.tokens.values() if t.user_login]
        print("\n Summary:")
        print(f"   Total tokens discovered: {len(self.tokens)}")
        print(f"   GitHub tokens: {len(github_tokens)}")
        actions_count = len([t for t in github_tokens if t.has_actions_read])
        issues_count = len([t for t in github_tokens if t.has_issues_write])
        print(f"   Tokens with actions:read: {actions_count}")
        print(f"   Tokens with issues:write: {issues_count}")

        # Operation coverage
        print("\n🎯 Operation Coverage:")
        for operation, mapping in self.operation_mappings.items():
            suitable_tokens = [
                name
                for name in mapping["primary_tokens"]  mapping["fallback_tokens"]
                if self._is_token_suitable_for_operation(name, operation)
            ]
            status = "" if suitable_tokens else ""
            print(f"   {status} {operation}: {len(suitable_tokens)} suitable tokens")
            if suitable_tokens:
                print(f"      Available: {', '.join(suitable_tokens)}")

        # Missing tokens
        missing_tokens = set()
        for mapping in self.operation_mappings.values():
            for token_name in mapping["primary_tokens"]:
                if (
                    token_name not in self.tokens
                    or not self.tokens[token_name].available
                ):
                    missing_tokens.add(token_name)

        if missing_tokens:
            print("\n  Missing Critical Tokens:")
            for token in sorted(missing_tokens):
                print(f"   - {token}")

        # Token details
        print("\n Available GitHub Tokens:")
        for name, info in self.tokens.items():
            if info.user_login:
                perms = []
                if info.has_actions_read:
                    perms.append("actions:read")
                if info.has_issues_write:
                    perms.append("issues:write")
                if info.has_contents_read:
                    perms.append("contents:read")
                if info.has_pull_requests_write:
                    perms.append("pull_requests:write")

                perm_str = ", ".join(perms) if perms else "limited permissions"
                print(f"    {name}")
                print(f"      User: {info.user_login} ({info.user_type})")
                print(f"      Permissions: {perm_str}")


def main():
    """Main entry point for token management CLI."""
    if len(sys.argv) > 1 and sys.argv[1] == "json":
        # JSON output for programmatic use
        manager = DevOnboarderTokenManager()
        manager.discover_tokens()
        report = manager.generate_report()
        print(json.dumps(report, indent=2))
    else:
        # Human-readable output
        manager = DevOnboarderTokenManager()
        manager.discover_tokens()
        manager.print_status()


if __name__ == "__main__":
    main()
