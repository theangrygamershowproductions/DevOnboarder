#!/usr/bin/env python3
"""Example DevOnboarder service with automatic token validation.

This example shows how to integrate the token notification system
into DevOnboarder services for automatic startup validation.
"""

import sys
from pathlib import Path

# Add scripts directory to path for token loader import
sys.path.insert(0, str(Path(__file__).parent.parent / "scripts"))

try:
    from token_loader import require_tokens
except ImportError:
    print("ERROR: Cannot import token_loader - ensure you're in DevOnboarder root")
    sys.exit(1)


class ExampleService:
    """Example service with token validation."""

    # Define required tokens for this service
    REQUIRED_TOKENS = ["AAR_TOKEN", "CI_ISSUE_AUTOMATION_TOKEN"]

    def __init__(self):
        """Initialize service with token validation."""
        self.service_name = "Example DevOnboarder Service"

    def start(self) -> bool:
        """Start the service with token validation."""
        print(f"Starting {self.service_name}...")

        # Validate required tokens with automatic notifications
        if not require_tokens(self.REQUIRED_TOKENS, self.service_name):
            print(f"ERROR: {self.service_name}: Startup failed due to missing tokens")
            return False

        # Service-specific initialization would go here
        print(f"SUCCESS: {self.service_name}: Started successfully")
        return True


def main():
    """Main entry point."""
    service = ExampleService()

    if not service.start():
        print("\nTO FIX: Set up your tokens as described above")
        sys.exit(1)

    print(f"\n{service.service_name} is running...")


if __name__ == "__main__":
    main()
