#!/usr/bin/env python3
"""
DevOnboarder Framework Phase 3 Governance CLI Tool

This tool provides command-line interface for managing extended metadata,
governance policies, and compliance reporting for DevOnboarder scripts.

Usage:
    python governance_cli.py check [script_path]      # Check script compliance
    python governance_cli.py report [directory]       # Generate compliance report
    python governance_cli.py validate [directory]     # Validate all metadata files
    python governance_cli.py create [script_path]     # Create default metadata
    python governance_cli.py approve [script_path]    # Approve script execution
"""

import sys
import argparse
from pathlib import Path
import json
from datetime import datetime

# Add src to path for imports
sys.path.insert(0, str(Path(__file__).parent.parent / "src"))

from src.framework.metadata_yaml import (
    ExtendedMetadataYAMLManager,
)
from src.framework.governance_engine import (
    GovernancePolicyEngine,
    PolicyViolationSeverity,
)


class GovernanceCLI:
    """Command-line interface for Framework Phase 3 governance operations"""

    def __init__(self):
        self.yaml_manager = ExtendedMetadataYAMLManager()
        self.policy_engine = GovernancePolicyEngine()

    def check_script(self, script_path: str) -> int:
        """Check a single script for compliance"""
        script = Path(script_path)

        if not script.exists():
            print(f"❌ Error: Script not found: {script_path}")
            return 1

        print(f"🔍 Checking compliance for: {script.name}")
        print("=" * 60)

        violations = self.policy_engine.check_script_compliance(script)

        if not violations:
            print("✅ Script is fully compliant!")
            return 0

        # Group violations by severity
        critical_violations = [
            v for v in violations if v.severity == PolicyViolationSeverity.CRITICAL
        ]
        high_violations = [
            v for v in violations if v.severity == PolicyViolationSeverity.HIGH
        ]
        medium_violations = [
            v for v in violations if v.severity == PolicyViolationSeverity.MEDIUM
        ]
        low_violations = [
            v for v in violations if v.severity == PolicyViolationSeverity.LOW
        ]

        # Display violations by severity
        for severity, violation_list, emoji in [
            ("CRITICAL", critical_violations, "🚨"),
            ("HIGH", high_violations, "🔴"),
            ("MEDIUM", medium_violations, "🟡"),
            ("LOW", low_violations, "🟢"),
        ]:
            if violation_list:
                print(f"\n{emoji} {severity} VIOLATIONS:")
                for violation in violation_list:
                    print(f"  • {violation.message}")
                    if violation.remediation_hint:
                        print(f"    💡 Fix: {violation.remediation_hint}")
                    if violation.blocking:
                        print("    🚫 This violation blocks execution")
                    print()

        # Summary
        blocking_violations = [v for v in violations if v.blocking]
        print(f"📊 Summary: {len(violations)} total violations")
        print(f"   - {len(blocking_violations)} blocking violations")
        print(
            f"   - {len(violations) - len(blocking_violations)} non-blocking violations"
        )

        if blocking_violations:
            print("\n❌ Script execution BLOCKED due to policy violations")
            return 1
        else:
            print("\n⚠️  Script can execute but has policy violations to address")
            return 0

    def generate_report(self, directory: str = ".") -> int:
        """Generate comprehensive compliance report"""
        dir_path = Path(directory)

        if not dir_path.exists():
            print(f"❌ Error: Directory not found: {directory}")
            return 1

        print(f"📊 Generating compliance report for: {dir_path.absolute()}")
        print("=" * 60)

        report = self.policy_engine.get_compliance_report(dir_path)

        # Display summary
        print("📈 COMPLIANCE SUMMARY")
        print(f"   Total Scripts: {report['total_scripts']}")
        print(f"   Compliant: {report['compliant_scripts']}")
        print(f"   Non-Compliant: {report['non_compliant_scripts']}")
        print(f"   Compliance Rate: {report['compliance_percentage']:.1f}%")

        # Violations by type
        if report["violation_counts"]:
            print("\n🔍 VIOLATIONS BY TYPE:")
            for vtype, count in report["violation_counts"].items():
                print(f"   • {vtype.replace('_', ' ').title()}: {count}")

        # Violations by severity
        if report["severity_counts"]:
            print("\n⚠️  VIOLATIONS BY SEVERITY:")
            for severity, count in report["severity_counts"].items():
                emoji = {
                    "critical": "🚨",
                    "high": "🔴",
                    "medium": "🟡",
                    "low": "🟢",
                }.get(severity, "📋")
                print(f"   {emoji} {severity.upper()}: {count}")

        # Save detailed report to file
        report_file = (
            dir_path
            / f"governance_report_{datetime.now().strftime('%Y%m%d_%H%M%S')}.json"
        )
        with open(report_file, "w") as f:
            json.dump(report, f, indent=2, default=str)

        print(f"\n💾 Detailed report saved to: {report_file}")

        return 0 if report["compliance_percentage"] == 100 else 1

    def validate_metadata(self, directory: str = ".") -> int:
        """Validate all metadata files in directory"""
        dir_path = Path(directory)

        if not dir_path.exists():
            print(f"❌ Error: Directory not found: {directory}")
            return 1

        print(f"✅ Validating metadata files in: {dir_path.absolute()}")
        print("=" * 60)

        validation_results = self.yaml_manager.validate_all_metadata(dir_path)

        valid_count = sum(1 for result in validation_results.values() if result)
        total_count = len(validation_results)

        print("📊 VALIDATION SUMMARY")
        print(f"   Total Metadata Files: {total_count}")
        print(f"   Valid Files: {valid_count}")
        print(f"   Invalid Files: {total_count - valid_count}")
        validation_pct = (valid_count / total_count * 100) if total_count > 0 else 100
        print(f"   Validation Rate: {validation_pct:.1f}%")

        # Show invalid files
        invalid_files = [
            path for path, valid in validation_results.items() if not valid
        ]
        if invalid_files:
            print("\n❌ INVALID METADATA FILES:")
            for file_path in invalid_files:
                print(f"   • {file_path}")

        return 0 if valid_count == total_count else 1

    def create_metadata(
        self, script_path: str, similarity_group: str = "script_automation"
    ) -> int:
        """Create default metadata for a script"""
        script = Path(script_path)

        if not script.exists():
            print(f"❌ Error: Script not found: {script_path}")
            return 1

        # Check if metadata already exists
        existing_metadata = self.yaml_manager.load_metadata(script)
        if existing_metadata:
            print(f"⚠️  Metadata already exists for {script.name}")
            response = input("Overwrite existing metadata? (y/N): ").lower()
            if response != "y":
                print("❌ Operation cancelled")
                return 1

        print(f"📝 Creating metadata for: {script.name}")

        try:
            metadata_file = self.yaml_manager.create_default_metadata_file(
                script, similarity_group
            )
            print(f"✅ Metadata created: {metadata_file}")

            # Show the created metadata
            print("\n📋 Created metadata preview:")
            with open(metadata_file) as f:
                content = f.read()
                # Show first 20 lines
                lines = content.split("\n")[:20]
                print("\n".join(lines))
                if len(content.split("\n")) > 20:
                    print("... (truncated)")

            return 0

        except Exception as e:
            print(f"❌ Error creating metadata: {e}")
            return 1

    def approve_script(self, script_path: str, approved_by: str = "cli_user") -> int:
        """Approve a script for execution"""
        script = Path(script_path)

        if not script.exists():
            print(f"❌ Error: Script not found: {script_path}")
            return 1

        print(f"✍️  Approving script: {script.name}")

        try:
            success = self.policy_engine.approval_manager.approve(
                script, approved_by, "CLI approval"
            )

            if success:
                print(f"✅ Script approved by {approved_by}")
                return 0
            else:
                print(f"❌ No approval request found for {script.name}")
                print(
                    "💡 Hint: Scripts may need approval requests "
                    "before they can be approved"
                )
                return 1

        except Exception as e:
            print(f"❌ Error approving script: {e}")
            return 1


def main():
    """Main CLI entry point"""
    parser = argparse.ArgumentParser(
        description="DevOnboarder Framework Phase 3 Governance CLI",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  python governance_cli.py check scripts/safe_commit.sh
  python governance_cli.py report scripts/
  python governance_cli.py validate .
  python governance_cli.py create scripts/new_script.sh
  python governance_cli.py approve scripts/safe_commit.sh
        """,
    )

    subparsers = parser.add_subparsers(dest="command", help="Available commands")

    # Check command
    check_parser = subparsers.add_parser("check", help="Check script compliance")
    check_parser.add_argument("script_path", help="Path to script to check")

    # Report command
    report_parser = subparsers.add_parser("report", help="Generate compliance report")
    report_parser.add_argument(
        "directory", nargs="?", default=".", help="Directory to scan"
    )

    # Validate command
    validate_parser = subparsers.add_parser("validate", help="Validate metadata files")
    validate_parser.add_argument(
        "directory", nargs="?", default=".", help="Directory to scan"
    )

    # Create command
    create_parser = subparsers.add_parser("create", help="Create default metadata")
    create_parser.add_argument("script_path", help="Path to script")
    create_parser.add_argument(
        "--similarity-group",
        default="script_automation",
        choices=["script_automation", "ci_cd", "quality_assurance", "documentation"],
        help="Priority Matrix Bot similarity group",
    )

    # Approve command
    approve_parser = subparsers.add_parser("approve", help="Approve script execution")
    approve_parser.add_argument("script_path", help="Path to script to approve")
    approve_parser.add_argument(
        "--approved-by", default="cli_user", help="Approver name"
    )

    args = parser.parse_args()

    if not args.command:
        parser.print_help()
        return 1

    cli = GovernanceCLI()

    try:
        if args.command == "check":
            return cli.check_script(args.script_path)
        elif args.command == "report":
            return cli.generate_report(args.directory)
        elif args.command == "validate":
            return cli.validate_metadata(args.directory)
        elif args.command == "create":
            return cli.create_metadata(args.script_path, args.similarity_group)
        elif args.command == "approve":
            return cli.approve_script(args.script_path, args.approved_by)
        else:
            parser.print_help()
            return 1

    except KeyboardInterrupt:
        print("\n❌ Operation cancelled by user")
        return 1
    except Exception as e:
        print(f"❌ Unexpected error: {e}")
        return 1


if __name__ == "__main__":
    sys.exit(main())
