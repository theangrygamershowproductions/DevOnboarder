#!/usr/bin/env python3
"""
Administrative Triage Analysis Script
Categorizes remaining GitHub issues for systematic labeling and organization.
"""

import json
import os
import sys
from datetime import datetime


def load_issues():
    """Load issues from JSON file."""
    # Use environment variable if set, else default to relative path
    issues_path = os.environ.get(
        "ISSUES_JSON_PATH", os.path.join("logs", "remaining_issues.json")
    )
    try:
        with open(issues_path, "r", encoding="utf-8") as f:
            # Handle JSON objects separated by newlines
            content = f.read().strip()
            issues = []
            for line in content.split("\n}"):
                if line.strip():
                    line = line.strip()
                    if not line.endswith("}"):
                        line = "}"
                    try:
                        issue = json.loads(line)
                        issues.append(issue)
                    except json.JSONDecodeError:
                        print(
                            f"Warning: Could not parse line: {line[:50]}...",
                            file=sys.stderr,
                        )
            return issues
    except FileNotFoundError:
        print(" Issues file not found", file=sys.stderr)
        return []


def categorize_by_type(issues):
    """Categorize issues by type based on title and existing labels."""
    categories = {
        "pr-tracking": [],
        "ci-failure": [],
        "enhancement": [],
        "infrastructure": [],
        "documentation": [],
        "security": [],
        "automation": [],
        "bridge-platform": [],
        "service-discovery": [],
        "bug": [],
        "process-improvement": [],
        "testing": [],
        "other": [],
    }

    for issue in issues:
        title = issue["title"].lower()
        labels = [label.lower() for label in issue["labels"]]

        # Explicit categorization based on existing labels first
        if "pr-tracking" in labels:
            categories["pr-tracking"].append(issue)
        elif "ci-failure" in labels:
            categories["ci-failure"].append(issue)
        elif "bridge" in labels:
            categories["bridge-platform"].append(issue)
        elif "service-discovery" in labels:
            categories["service-discovery"].append(issue)
        elif "security" in labels or "dependabot" in labels:
            categories["security"].append(issue)
        elif "documentation" in labels:
            categories["documentation"].append(issue)
        elif "bug" in labels:
            categories["bug"].append(issue)
        elif "automation" in labels or "automated" in labels:
            categories["automation"].append(issue)
        elif "testing" in labels or "testing-infrastructure" in labels:
            categories["testing"].append(issue)
        elif "process-improvement" in labels:
            categories["process-improvement"].append(issue)
        # Title-based categorization for unlabeled issues
        elif "track pr" in title:
            categories["pr-tracking"].append(issue)
        elif "ci failure" in title or "ci:" in title:
            categories["ci-failure"].append(issue)
        elif "bridge:" in title:
            categories["bridge-platform"].append(issue)
        elif "phase" in title and "service discovery" in title:
            categories["service-discovery"].append(issue)
        elif "security:" in title or "dependabot" in title:
            categories["security"].append(issue)
        elif "doc" in title or "documentation" in title:
            categories["documentation"].append(issue)
        elif "bug:" in title or "critical:" in title:
            categories["bug"].append(issue)
        elif "automation" in title or "automate" in title:
            categories["automation"].append(issue)
        elif "test" in title:
            categories["testing"].append(issue)
        elif "post-mortem" in title or "process" in title:
            categories["process-improvement"].append(issue)
        elif "feat:" in title or "feature:" in title or "enhancement" in labels:
            categories["enhancement"].append(issue)
        elif "infra" in title or "infrastructure" in labels:
            categories["infrastructure"].append(issue)
        else:
            categories["other"].append(issue)

    return categories


def analyze_priority_gaps(issues):
    """Analyze priority labeling gaps."""
    priority_stats = {"high": 0, "medium": 0, "low": 0, "unlabeled": 0}

    unlabeled_priority = []

    for issue in issues:
        labels = [label.lower() for label in issue["labels"]]
        has_priority = False

        for label in labels:
            if "priority-high" in label:
                priority_stats["high"] = 1
                has_priority = True
                break
            elif "priority-medium" in label:
                priority_stats["medium"] = 1
                has_priority = True
                break
            elif "priority-low" in label:
                priority_stats["low"] = 1
                has_priority = True
                break

        if not has_priority:
            priority_stats["unlabeled"] = 1
            unlabeled_priority.append(issue)

    return priority_stats, unlabeled_priority


def suggest_priorities(issue):
    """Suggest priority based on issue content."""
    title = issue["title"].lower()
    labels = [label.lower() for label in issue["labels"]]

    # High priority indicators
    if any(
        word in title
        for word in ["critical", "security", "bug", "urgent", "post-mortem"]
    ):
        return "priority-high"

    # Bridge platform and service discovery are strategic
    if "bridge" in labels or "service-discovery" in labels:
        return "priority-medium"

    # Infrastructure and process improvements
    if any(word in title for word in ["infrastructure", "process", "framework"]):
        return "priority-medium"

    # Documentation and automation
    if any(word in title for word in ["documentation", "automation", "training"]):
        return "priority-low"

    # PR tracking and CI failures are operational
    if "pr-tracking" in labels or "ci-failure" in labels:
        return "priority-low"

    return "priority-medium"  # Default for unclear cases


def generate_triage_report(categories, priority_stats, unlabeled_priority, issues):
    """Generate comprehensive triage report."""
    print("# Administrative Triage Analysis Report")
    print(f"**Analysis Date**: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    print(f"**Total Issues Analyzed**: {len(issues)}")
    print()

    print("## Issue Distribution by Category")
    print()
    for category, category_issues in categories.items():
        if category_issues:
            category_title = category.replace("-", " ").title()
            print(f"### {category_title} ({len(category_issues)} issues)")
            print()
            for issue in category_issues[:5]:  # Show first 5
                assignee = (
                    issue["assignee"]
                    if issue["assignee"] != "unassigned"
                    else "Unassigned"
                )
                print(f"- **#{issue['number']}** - {issue['title']} ({assignee})")
            if len(category_issues) > 5:
                print(f"- ... and {len(category_issues) - 5} more")
            print()

    print("## Priority Analysis")
    print()
    total = sum(priority_stats.values())
    for priority, count in priority_stats.items():
        percentage = (count / total * 100) if total > 0 else 0
        print(f"- **{priority.title()}**: {count} issues ({percentage:.1f}%)")
    print()

    print("## Critical Gaps Requiring Immediate Attention")
    print()
    unlabeled_count = priority_stats["unlabeled"]
    if unlabeled_count > 0:
        print(f"### Priority Labeling Gap: {unlabeled_count} issues")
        print()
        print("Issues requiring priority classification:")
        print()
        for issue in unlabeled_priority[:10]:  # Show first 10
            suggested = suggest_priorities(issue)
            print(f"- **#{issue['number']}** - {issue['title']}")
            print(f"  - **Suggested Priority**: {suggested}")
            labels_str = ", ".join(issue["labels"]) if issue["labels"] else "None"
            print(f"  - **Current Labels**: {labels_str}")
            print()
        if len(unlabeled_priority) > 10:
            print(f"... and {len(unlabeled_priority) - 10} more requiring triage")
        print()

    print("## Recommended Next Actions")
    print()
    print("### 1. Priority Labeling")
    print("- Add priority labels to all unlabeled issues")
    print("- Focus on critical/security issues first")
    print("- Use suggested priorities as starting point")
    print()

    print("### 2. Component Labeling")
    print("- Add component labels (frontend, backend, bot, docs, etc.)")
    print("- Add effort estimation labels (effort-small, effort-medium, effort-large)")
    print("- Add milestone assignments for strategic issues")
    print()

    print("### 3. Assignment Strategy")
    high_priority_unassigned = [
        issue
        for issue in issues
        if issue["assignee"] == "unassigned"
        and any("priority-high" in label.lower() for label in issue["labels"])
    ]
    print(
        f"- Assign owners to {len(high_priority_unassigned)} "
        "high-priority unassigned issues"
    )
    print("- Consider team capacity for bridge platform and service discovery work")
    print("- Distribute infrastructure work across team members")
    print()


def main():
    """Main analysis function."""
    issues = load_issues()
    if not issues:
        print("No issues to analyze.")
        return

    categories = categorize_by_type(issues)
    priority_stats, unlabeled_priority = analyze_priority_gaps(issues)

    generate_triage_report(categories, priority_stats, unlabeled_priority, issues)


if __name__ == "__main__":
    main()
