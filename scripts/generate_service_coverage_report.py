#!/usr/bin/env python3
"""Generate comprehensive per-service coverage report for DevOnboarder."""

import re
import sys
from pathlib import Path
from typing import Dict, Tuple


def extract_coverage_from_log(log_path: Path) -> Tuple[float, str]:
    """Extract coverage percentage from pytest log file.

    Parameters
    ----------
    log_path : Path
        Path to pytest log file.

    Returns
    -------
    Tuple[float, str]
        Coverage percentage and status emoji.
    """
    if not log_path.exists():
        return 0.0, "❌"

    try:
        with open(log_path, "r", encoding="utf-8") as f:
            content = f.read()

        # Look for coverage percentage in various formats
        patterns = [
            r"TOTAL\s+\d+\s+\d+\s+(\d+)%",  # Standard pytest-cov output
            r"coverage:\s*(\d+(?:\.\d+)?)%",  # Alternative format
            r"(\d+(?:\.\d+)?)%\s+coverage",  # Another format
        ]

        for pattern in patterns:
            match = re.search(pattern, content)
            if match:
                coverage = float(match.group(1))
                if coverage >= 95:
                    return coverage, "🟢"
                elif coverage >= 90:
                    return coverage, "🟡"
                elif coverage >= 85:
                    return coverage, "🟠"
                else:
                    return coverage, "🔴"

    except Exception as e:
        print(f"Error reading {log_path}: {e}", file=sys.stderr)

    return 0.0, "❌"


def get_service_info() -> Dict[str, Dict[str, any]]:
    """Get service configuration and expected thresholds.

    Returns
    -------
    Dict[str, Dict[str, any]]
        Service configuration with thresholds and descriptions.
    """
    return {
        "devonboarder": {
            "threshold": 95,
            "description": "Core auth service",
            "priority": "critical",
        },
        "utils": {
            "threshold": 95,
            "description": "Shared utilities",
            "priority": "critical",
        },
        "xp": {"threshold": 90, "description": "XP/gamification", "priority": "high"},
        "discord_integration": {
            "threshold": 90,
            "description": "Discord OAuth/roles",
            "priority": "high",
        },
        "feedback_service": {
            "threshold": 85,
            "description": "User feedback",
            "priority": "moderate",
        },
        "routes": {
            "threshold": 85,
            "description": "API routes",
            "priority": "moderate",
        },
        "llama2_agile_helper": {
            "threshold": 85,
            "description": "LLM integration",
            "priority": "moderate",
        },
    }


def generate_markdown_report() -> str:
    """Generate markdown coverage report.

    Returns
    -------
    str
        Formatted markdown report.
    """
    services = get_service_info()
    logs_dir = Path("logs")

    # Header
    report = "# 📊 DevOnboarder Per-Service Coverage Report\n\n"
    report += "## Service Quality Overview\n\n"

    # Table header
    report += "| Service | Coverage | Threshold | Status | Description | Priority |\n"
    report += "|---------|----------|-----------|--------|-------------|----------|\n"

    total_coverage = 0.0
    services_count = 0
    failed_services = []

    # Process each service
    for service_name, config in services.items():
        log_file = logs_dir / f"pytest_{service_name.replace('_', '')}.log"
        if service_name == "llama2_agile_helper":
            log_file = logs_dir / "pytest_llama.log"
        elif service_name == "discord_integration":
            log_file = logs_dir / "pytest_discord.log"

        coverage, emoji = extract_coverage_from_log(log_file)
        threshold = config["threshold"]

        # Status determination
        if coverage >= threshold:
            status = f"{emoji} PASS"
        else:
            status = f"{emoji} FAIL"
            failed_services.append(
                {
                    "name": service_name,
                    "coverage": coverage,
                    "threshold": threshold,
                    "gap": threshold - coverage,
                }
            )

        service_desc = config["description"]
        service_priority = config["priority"]
        report += (
            f"| {service_name} | {coverage:.1f}% | {threshold}% | "
            f"{status} | {service_desc} | {service_priority} |\n"
        )

        total_coverage += coverage
        services_count += 1

    # Overall metrics
    avg_coverage = total_coverage / services_count if services_count > 0 else 0

    report += "\n## Overall Metrics\n\n"
    report += f"- **Average Coverage**: {avg_coverage:.1f}%\n"
    report += f"- **Services Tested**: {services_count}\n"
    report += f"- **Services Passing**: {services_count - len(failed_services)}\n"
    report += f"- **Services Failing**: {len(failed_services)}\n"

    # Failure analysis
    if failed_services:
        report += "\n## 🎯 Strategic Improvement Opportunities\n\n"
        report += "Focus testing efforts on these services for maximum ROI:\n\n"

        # Sort by gap size for strategic prioritization
        failed_services.sort(key=lambda x: x["gap"], reverse=True)

        for i, service in enumerate(failed_services, 1):
            gap = service["gap"]
            svc_name = service["name"]
            svc_coverage = service["coverage"]
            svc_threshold = service["threshold"]
            report += (
                f"{i}. **{svc_name}**: {svc_coverage:.1f}% "
                f"(needs +{gap:.1f}% to reach {svc_threshold}%)\n"
            )

        report += (
            "\n💡 **Recommendation**: Start with services having the "
            "largest coverage gaps for maximum improvement impact.\n"
        )
    else:
        report += "\n## 🎉 Excellent Quality Achievement!\n\n"
        all_services_msg = (
            "All services are meeting or exceeding their "
            "coverage thresholds. DevOnboarder maintains "
            "high quality across all components.\n"
        )
        report += all_services_msg

    # Quality insights
    report += "\n## 🔍 Quality Insights\n\n"
    critical_services = [s for s, c in services.items() if c["priority"] == "critical"]
    high_services = [s for s, c in services.items() if c["priority"] == "high"]

    failed_names = [f["name"] for f in failed_services]
    critical_passing = sum(1 for s in critical_services if s not in failed_names)
    high_passing = sum(1 for s in high_services if s not in failed_names)

    crit_count = len(critical_services)
    high_count = len(high_services)
    report += (
        f"- **Critical Services**: {critical_passing}/{crit_count} "
        f"passing (95% threshold)\n"
    )
    report += (
        f"- **High Priority Services**: {high_passing}/{high_count} "
        f"passing (90% threshold)\n"
    )

    return report


def main() -> None:
    """Generate and save coverage report."""
    report = generate_markdown_report()

    # Save to file
    output_file = Path("coverage-summary.md")
    with open(output_file, "w", encoding="utf-8") as f:
        f.write(report)

    print(f"Per-service coverage report generated: {output_file}")

    # Also print to stdout for CI visibility
    print("\n" + report)


if __name__ == "__main__":
    main()
