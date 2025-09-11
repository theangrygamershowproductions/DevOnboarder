#!/usr/bin/env python3
"""DevOnboarder Token Loader System v2.1.

Provides standardized token loading across all DevOnboarder services.
Supports separation of CI/CD automation tokens from application runtime tokens.
Automatically detects environment and loads appropriate .tokens file.
"""

import os
import sys
from pathlib import Path
from typing import Optional, Set


class TokenLoader:
    """Centralized token loading system for DevOnboarder v2.1."""

    # Token type constants
    TOKEN_TYPE_CICD = "cicd"
    TOKEN_TYPE_RUNTIME = "runtime"
    TOKEN_TYPE_ALL = "all"

    # CI/CD automation tokens (go in .tokens files)
    CICD_TOKENS: Set[str] = {
        "AAR_TOKEN",
        "CI_BOT_TOKEN",
        "CI_ISSUE_AUTOMATION_TOKEN",
        "DEV_ORCHESTRATION_BOT_KEY",
        "PROD_ORCHESTRATION_BOT_KEY",
        "STAGING_ORCHESTRATION_BOT_KEY",
    }

    # Application runtime tokens (stay in .env files)
    RUNTIME_TOKENS: Set[str] = {
        "DISCORD_BOT_TOKEN",
        "DISCORD_CLIENT_SECRET",
        "BOT_JWT",
        "CF_DNS_API_TOKEN",
        "TUNNEL_TOKEN",
    }

    def __init__(self):
        """Initialize token loader with environment detection."""
        self.project_root = self._find_project_root()
        self.tokens_file = self._determine_tokens_file()

    def _find_project_root(self) -> Path:
        """Find the project root directory."""
        current = Path.cwd()

        # Look for DevOnboarder indicators
        indicators = ["pyproject.toml", ".env", "Makefile", "README.md"]

        while current != current.parent:
            if all((current / indicator).exists() for indicator in indicators[:2]):
                return current
            current = current.parent

        # Fallback to current directory
        return Path.cwd()

    def _determine_tokens_file(self) -> str:
        """Determine which tokens file to load based on environment."""
        # CI environment takes precedence
        if os.getenv("CI"):
            return ".tokens.ci"

        # Explicit environment specification
        app_env = os.getenv("APP_ENV", "").lower()
        if app_env == "production":
            return ".tokens.prod"
        elif app_env == "development":
            return ".tokens.dev"

        # Default to source of truth
        return ".tokens"

    def _determine_env_file(self) -> str:
        """Determine which .env file to load based on environment."""
        # CI environment takes precedence
        if os.getenv("CI"):
            return ".env.ci"

        # Explicit environment specification
        app_env = os.getenv("APP_ENV", "").lower()
        if app_env == "production":
            return ".env.prod"
        elif app_env == "development":
            return ".env.dev"

        # Default to source of truth
        return ".env"

    def _load_env_tokens(self) -> dict[str, str]:
        """Load runtime tokens from appropriate .env file.

        Returns
        -------
        dict[str, str]
            Dictionary of loaded runtime token variables
        """
        env_file = self._determine_env_file()
        env_path = self.project_root / env_file

        if not env_path.exists():
            return {}

        loaded_tokens = {}

        try:
            with open(env_path, "r", encoding="utf-8") as f:
                for line in f:
                    line = line.strip()

                    # Skip empty lines and comments
                    if not line or line.startswith("#"):
                        continue

                    # Parse key=value pairs
                    if "=" not in line:
                        continue

                    key, value = line.split("=", 1)
                    key = key.strip()
                    value = value.strip()

                    # Remove quotes if present
                    if value.startswith('"') and value.endswith('"'):
                        value = value[1:-1]
                    elif value.startswith("'") and value.endswith("'"):
                        value = value[1:-1]

                    # Only load if it's a runtime token
                    if key in self.RUNTIME_TOKENS:
                        # CI Protection: Don't override GitHub Actions secrets
                        if (
                            os.getenv("CI")
                            and value.startswith("ci_test_")
                            and key in os.environ
                        ):
                            # Skip setting test placeholder if real token already exists
                            print(
                                f"🔒 Protecting CI secret: {key} "
                                "(not overriding with test placeholder)"
                            )
                            loaded_tokens[key] = os.environ[key]  # Use existing value
                            continue

                        os.environ[key] = value
                        loaded_tokens[key] = value

            return loaded_tokens

        except (OSError, IOError):
            return {}

    def load_tokens(self, tokens_file_override: Optional[str] = None) -> dict[str, str]:
        """Load tokens from appropriate file.

        Parameters
        ----------
        tokens_file_override : str, optional
            Override automatic detection with specific file

        Returns
        -------
        dict[str, str]
            Dictionary of loaded token variables
        """
        file_to_load = tokens_file_override or self.tokens_file
        tokens_path = self.project_root / file_to_load

        if not tokens_path.exists():
            print(f"⚠️  Token file not found: {tokens_path}")
            print(f"💡 Creating template: {file_to_load}")
            self._create_tokens_template(tokens_path)
            print(f"✅ Created template token file: {tokens_path}")
            print("📝 Please fill in your actual token values!")
            return {}

        loaded_tokens = {}

        try:
            with open(tokens_path, "r", encoding="utf-8") as f:
                for line in f:
                    line = line.strip()

                    # Skip empty lines and comments
                    if not line or line.startswith("#"):
                        continue

                    # Parse key=value pairs
                    if "=" not in line:
                        continue

                    key, value = line.split("=", 1)
                    key = key.strip()
                    value = value.strip()

                    # Remove quotes if present
                    if value.startswith('"') and value.endswith('"'):
                        value = value[1:-1]
                    elif value.startswith("'") and value.endswith("'"):
                        value = value[1:-1]

                    # CI Protection: Don't override GitHub Actions secrets
                    if (
                        os.getenv("CI")
                        and value.startswith("ci_test_")
                        and key in os.environ
                    ):
                        # Skip setting test placeholder if real token already exists
                        print(
                            f"🔒 Protecting CI secret: {key} "
                            "(not overriding with test placeholder)"
                        )
                        loaded_tokens[key] = os.environ[key]  # Use existing value
                        continue

                    # Set in environment
                    os.environ[key] = value
                    loaded_tokens[key] = value

            print(f"✅ Loaded {len(loaded_tokens)} tokens from {file_to_load}")
            return loaded_tokens

        except (OSError, IOError) as e:
            print(f"❌ Error loading tokens from {tokens_path}: {e}")
            return {}

    def validate_required_tokens(
        self, required_tokens: list[str], notify_missing: bool = True
    ) -> dict[str, bool]:
        """Validate that required tokens are available.

        Parameters
        ----------
        required_tokens : list[str]
            List of required token names
        notify_missing : bool, default True
            Whether to print notifications for missing tokens

        Returns
        -------
        dict[str, bool]
            Status of each required token
        """
        token_status = {}
        missing_tokens = []

        for token_name in required_tokens:
            token_value = os.environ.get(token_name)
            # Check for missing, empty, or placeholder values
            is_placeholder = token_value and (
                token_value.startswith("CHANGE_ME_")
                or token_value.startswith("ci_test_")
                or token_value.endswith("_here")
                or token_value.endswith("_placeholder")
            )
            is_available = bool(
                token_value and token_value.strip() and not is_placeholder
            )
            token_status[token_name] = is_available

            if not is_available:
                missing_tokens.append(token_name)

        # Notify about missing tokens
        if notify_missing and missing_tokens:
            self._notify_missing_tokens(missing_tokens)

        return token_status

    def load_tokens_by_type(self, token_type: str = TOKEN_TYPE_ALL) -> dict[str, str]:
        """Load tokens filtered by type (cicd, runtime, or all).

        Loads CI/CD tokens from .tokens files and runtime tokens from .env files
        for complete token separation and functionality.

        Parameters
        ----------
        token_type : str, default TOKEN_TYPE_ALL
            Type of tokens to load: TOKEN_TYPE_CICD, TOKEN_TYPE_RUNTIME,
            or TOKEN_TYPE_ALL

        Returns
        -------
        dict[str, str]
            Dictionary of loaded token variables of specified type
        """
        all_tokens = {}

        # Load CI/CD tokens from .tokens file
        if token_type in (self.TOKEN_TYPE_CICD, self.TOKEN_TYPE_ALL):
            cicd_tokens = self.load_tokens()  # Loads from .tokens file
            cicd_filtered = {
                k: v for k, v in cicd_tokens.items() if k in self.CICD_TOKENS
            }
            all_tokens.update(cicd_filtered)

        # Load runtime tokens from .env file
        if token_type in (self.TOKEN_TYPE_RUNTIME, self.TOKEN_TYPE_ALL):
            runtime_tokens = self._load_env_tokens()  # Loads from .env file
            runtime_filtered = {
                k: v for k, v in runtime_tokens.items() if k in self.RUNTIME_TOKENS
            }
            all_tokens.update(runtime_filtered)

        return all_tokens

    def get_token_classification(self, token_name: str) -> str:
        """Get the classification of a specific token.

        Parameters
        ----------
        token_name : str
            Name of the token to classify

        Returns
        -------
        str
            Token classification: TOKEN_TYPE_CICD, TOKEN_TYPE_RUNTIME, or "unknown"
        """
        if token_name in self.CICD_TOKENS:
            return self.TOKEN_TYPE_CICD
        elif token_name in self.RUNTIME_TOKENS:
            return self.TOKEN_TYPE_RUNTIME
        else:
            return "unknown"

    def list_tokens_by_type(self) -> dict[str, list[str]]:
        """List all known tokens organized by type.

        Returns
        -------
        dict[str, list[str]]
            Dictionary with "cicd" and "runtime" keys containing token lists
        """
        return {
            "cicd": sorted(list(self.CICD_TOKENS)),
            "runtime": sorted(list(self.RUNTIME_TOKENS)),
        }

    def _create_tokens_template(self, tokens_path: Path) -> None:
        """Create a template tokens file with standard DevOnboarder tokens.

        Parameters
        ----------
        tokens_path : Path
            Path where the tokens file should be created
        """
        # Determine environment for appropriate placeholders
        is_ci = "ci" in tokens_path.name or os.getenv("CI")
        is_prod = "prod" in tokens_path.name
        is_dev = "dev" in tokens_path.name

        if is_ci:
            placeholder_prefix = "ci_test_"
            security_note = "COMMITTED - Test values only, no production secrets"
        elif is_prod:
            placeholder_prefix = "CHANGE_ME_PROD_"
            security_note = "GITIGNORED - Production secrets, never commit"
        elif is_dev:
            placeholder_prefix = "CHANGE_ME_DEV_"
            security_note = "GITIGNORED - Development secrets, never commit"
        else:
            placeholder_prefix = "CHANGE_ME_"
            security_note = "GITIGNORED - Source of truth, never commit"

        template_content = f"""# ===============================================
# DevOnboarder Token Management v2.0
# File: {tokens_path.name}
# Security: {security_note}
# Synchronization: Managed by scripts/sync_tokens.sh
# ===============================================

# GitHub Authentication Tokens
AAR_TOKEN={placeholder_prefix}aar_token_here
CI_ISSUE_AUTOMATION_TOKEN={placeholder_prefix}ci_issue_automation_token_here
CI_BOT_TOKEN={placeholder_prefix}ci_bot_token_here

# Discord Integration Tokens
DISCORD_BOT_TOKEN={placeholder_prefix}discord_bot_token_here
DISCORD_CLIENT_SECRET={placeholder_prefix}discord_client_secret_here

# Service Authentication Tokens
BOT_JWT={placeholder_prefix}bot_jwt_here

# Infrastructure Tokens
TUNNEL_TOKEN={placeholder_prefix}tunnel_token_here
CF_DNS_API_TOKEN={placeholder_prefix}cf_dns_api_token_here

# Orchestration Tokens
DEV_ORCHESTRATION_BOT_KEY={placeholder_prefix}dev_orchestration_bot_key_here
PROD_ORCHESTRATION_BOT_KEY={placeholder_prefix}prod_orchestration_bot_key_here
STAGING_ORCHESTRATION_BOT_KEY={placeholder_prefix}staging_orchestration_bot_key_here

# =============================================================================
# SETUP INSTRUCTIONS:
# 1. Replace all '{placeholder_prefix}*_here' values with actual tokens
# 2. Run: bash scripts/sync_tokens.sh --sync-all
# 3. Test: python scripts/token_loader.py validate <TOKEN_NAMES>
#
# For token acquisition guidance, see:
# - docs/token-setup-guide.md
# - docs/TOKEN_ARCHITECTURE.md
# ===============================================
"""

        try:
            tokens_path.parent.mkdir(parents=True, exist_ok=True)
            with open(tokens_path, "w", encoding="utf-8") as f:
                f.write(template_content)
        except (OSError, IOError) as e:
            print(f"❌ Error creating tokens template: {e}")
            raise

    def _notify_missing_tokens(self, missing_tokens: list[str]) -> None:
        """Provide user notification about missing tokens."""
        print("\n⚠️  MISSING TOKENS DETECTED")
        print("━" * 50)

        for token_name in missing_tokens:
            print(f"❌ {token_name}")

        print("\n💡 TO FIX MISSING TOKENS:")

        # Environment-specific guidance
        if os.getenv("CI"):
            print("   CI Environment: Check .tokens.ci file has test values")
            print(f"   File: {self.project_root}/.tokens.ci")
        else:
            print(
                f"   1. Add missing tokens to: {self.project_root}/{self.tokens_file}"
            )
            print("   2. Run: bash scripts/sync_tokens.sh --sync-all")
            token_test_cmd = (
                f"python scripts/token_loader.py validate "
                f"{' '.join(missing_tokens)}"
            )
            print(f"   3. Test: {token_test_cmd}")

        print("\n📚 For token setup guidance:")
        print("   See: docs/token-setup-guide.md")
        print("   Architecture: docs/TOKEN_ARCHITECTURE.md")

        # Environment variable check
        print("\n🔍 ENVIRONMENT CHECK:")
        print(f"   Current tokens file: {self.tokens_file}")
        print(f"   Project root: {self.project_root}")
        print(f"   APP_ENV: {os.getenv('APP_ENV', 'not set')}")
        print(f"   CI: {os.getenv('CI', 'not set')}")

    def require_tokens(
        self, required_tokens: list[str], service_name: str = "Service"
    ) -> bool:
        """Require specific tokens and exit if missing.

        Parameters
        ----------
        required_tokens : list[str]
            List of required token names
        service_name : str, default "Service"
            Name of the service requiring tokens

        Returns
        -------
        bool
            True if all tokens available, False if any missing
        """
        print(f"🔐 {service_name}: Validating required tokens...")

        # Load tokens first
        self.load_tokens()

        # Validate requirements
        status = self.validate_required_tokens(required_tokens, notify_missing=True)
        missing_tokens = [token for token, available in status.items() if not available]

        if missing_tokens:
            print(f"\n❌ {service_name}: CANNOT START - Missing required tokens")
            print(f"   Missing: {', '.join(missing_tokens)}")
            return False
        else:
            print(f"✅ {service_name}: All required tokens available")
            return True

    def get_token_info(self) -> dict[str, str | bool]:
        """Get information about current token loading configuration."""
        return {
            "project_root": str(self.project_root),
            "tokens_file": self.tokens_file,
            "tokens_path": str(self.project_root / self.tokens_file),
            "file_exists": (self.project_root / self.tokens_file).exists(),
            "environment": os.getenv("APP_ENV", "default"),
            "ci_environment": bool(os.getenv("CI")),
        }


# Global instance for easy imports
_token_loader = TokenLoader()


def load_tokens(tokens_file_override: Optional[str] = None) -> dict[str, str]:
    """Convenience function to load tokens.

    Parameters
    ----------
    tokens_file_override : str, optional
        Override automatic detection with specific file

    Returns
    -------
    dict[str, str]
        Dictionary of loaded token variables
    """
    return _token_loader.load_tokens(tokens_file_override)


def validate_required_tokens(
    required_tokens: list[str], notify_missing: bool = True
) -> dict[str, bool]:
    """Convenience function to validate required tokens.

    Parameters
    ----------
    required_tokens : list[str]
        List of required token names
    notify_missing : bool, default True
        Whether to print notifications for missing tokens

    Returns
    -------
    dict[str, bool]
        Status of each required token
    """
    return _token_loader.validate_required_tokens(required_tokens, notify_missing)


def require_tokens(required_tokens: list[str], service_name: str = "Service") -> bool:
    """Convenience function to require specific tokens and exit if missing.

    Parameters
    ----------
    required_tokens : list[str]
        List of required token names
    service_name : str, default "Service"
        Name of the service requiring tokens

    Returns
    -------
    bool
        True if all tokens available, False if any missing
    """
    return _token_loader.require_tokens(required_tokens, service_name)


def get_token_info() -> dict[str, str | bool]:
    """Convenience function to get token loading info."""
    return _token_loader.get_token_info()


if __name__ == "__main__":
    # CLI usage for token loading and validation
    import json

    if len(sys.argv) > 1:
        command = sys.argv[1]

        if command == "info":
            info = get_token_info()
            print(json.dumps(info, indent=2))

        elif command == "load":
            override_file = sys.argv[2] if len(sys.argv) > 2 else None
            tokens = load_tokens(override_file)
            print(f"Loaded {len(tokens)} tokens")

        elif command == "validate":
            if len(sys.argv) < 3:
                print("Usage: python token_loader.py validate TOKEN1 [TOKEN2 ...]")
                sys.exit(1)

            token_list = sys.argv[2:]
            # First load tokens
            load_tokens()
            # Then validate
            validation_status = validate_required_tokens(token_list)

            print("Token Validation Results:")
            for token, available in validation_status.items():
                status_icon = "✅" if available else "❌"
                print(f"  {status_icon} {token}")

            # Exit with error if any tokens missing
            if not all(validation_status.values()):
                sys.exit(1)

        else:
            print("DevOnboarder Token Loader - Auto-Creation System")
            print("=" * 50)
            print("Usage: python token_loader.py [command] [options]")
            print()
            print("Commands:")
            print("  info                    Show token configuration details")
            print("  load [file]             Load tokens (auto-creates if missing)")
            print("  validate TOKEN1 TOKEN2  Validate specific tokens")
            print()
            print("Features:")
            print("  🤖 Auto-Creation      Missing .tokens files created automatically")
            print("  🌍 Environment-Aware   Different templates per environment")
            print("  🔔 Smart Validation    Detects placeholder values")
            print("  🔒 Security Boundaries Separates tokens from configuration")
            print()
            print("Examples:")
            print("  python token_loader.py info")
            print("  python token_loader.py load")
            print("  python token_loader.py validate AAR_TOKEN DISCORD_BOT_TOKEN")
            print("  CI=true python token_loader.py load  # Creates CI template")
            print()
            print("Documentation:")
            print("  docs/TOKEN_AUTO_CREATION.md     - Auto-creation system")
            print("  docs/TOKEN_ARCHITECTURE.md      - Complete architecture")
            print("  docs/TOKEN_NOTIFICATION_SYSTEM.md - User guidance system")
            sys.exit(1)

    else:
        # Default: load tokens and show info
        tokens = load_tokens()
        info = get_token_info()
        print(f"✅ Loaded {len(tokens)} tokens from {info['tokens_file']}")
