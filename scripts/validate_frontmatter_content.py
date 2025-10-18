#!/usr/bin/env python3
"""
DevOnboarder Frontmatter Content Validation Script
Validates that frontmatter metadata accurately reflects document content
"""

import os
import re
import yaml
import argparse
from pathlib import Path
from typing import Dict, Tuple, Any
from datetime import datetime


class FrontmatterContentValidator:
    """Validates frontmatter metadata against document content"""

    def __init__(self, log_dir: str = "logs"):
        self.log_dir = Path(log_dir)
        self.log_dir.mkdir(exist_ok=True)
        self.issues = []
        self.stats = {
            "files_processed": 0,
            "issues_found": 0,
            "critical_issues": 0,
            "warnings": 0,
        }

    def parse_frontmatter(self, file_path: Path)  Tuple[Dict[str, Any], str]:
        """Extract frontmatter and content from markdown file"""
        try:
            with open(file_path, "r", encoding="utf-8") as f:
                content = f.read()

            # Check for frontmatter
            if not content.startswith("---\n"):
                return {}, content

            # Find end of frontmatter
            end_match = re.search(r"\n---\n", content[4:])
            if not end_match:
                return {}, content

            frontmatter_content = content[4 : end_match.start()  4]
            document_content = content[end_match.end()  4 :]

            try:
                frontmatter = yaml.safe_load(frontmatter_content)
                return frontmatter or {}, document_content
            except yaml.YAMLError as e:
                self.add_issue(file_path, "CRITICAL", f"Invalid YAML frontmatter: {e}")
                return {}, document_content

        except Exception as e:
            self.add_issue(file_path, "CRITICAL", f"Failed to read file: {e}")
            return {}, ""

    def add_issue(self, file_path: Path, severity: str, message: str):
        """Add validation issue"""
        self.issues.append(
            {"file": str(file_path), "severity": severity, "message": message}
        )
        if severity == "CRITICAL":
            self.stats["critical_issues"] = 1
        elif severity == "WARNING":
            self.stats["warnings"] = 1
        self.stats["issues_found"] = 1

    def validate_title_consistency(
        self, file_path: Path, frontmatter: Dict, content: str
    ):
        """Validate title consistency between frontmatter and content"""
        fm_title = frontmatter.get("title", "").strip()
        if not fm_title:
            self.add_issue(file_path, "WARNING", "Missing title in frontmatter")
            return

        # Extract H1 title from content
        h1_match = re.search(r"^#\s(.?)$", content, re.MULTILINE)
        if h1_match:
            content_title = h1_match.group(1).strip()

            # Check for reasonable similarity
            if fm_title.lower() != content_title.lower():
                # Allow for reasonable variations
                fm_words = set(fm_title.lower().split())
                content_words = set(content_title.lower().split())

                # If less than 50% word overlap, flag as issue
                if (
                    len(fm_words & content_words)
                    / max(len(fm_words), len(content_words))
                    < 0.5
                ):
                    self.add_issue(
                        file_path,
                        "WARNING",
                        f"Title mismatch - Frontmatter: '{fm_title}', "
                        f"Content: '{content_title}'",
                    )
        else:
            self.add_issue(file_path, "WARNING", "No H1 title found in content")

    def validate_description_relevance(
        self, file_path: Path, frontmatter: Dict, content: str
    ):
        """Validate description relevance to content"""
        description = frontmatter.get("description", "").strip()
        if not description:
            self.add_issue(file_path, "WARNING", "Missing description in frontmatter")
            return

        # Extract key terms from description
        desc_words = set(re.findall(r"\b\w{4,}\b", description.lower()))

        # Extract key terms from content (first 500 words)
        content_sample = " ".join(content.split()[:500])
        content_words = set(re.findall(r"\b\w{4,}\b", content_sample.lower()))

        # Check for reasonable overlap
        if desc_words and content_words:
            overlap = len(desc_words & content_words) / len(desc_words)
            if overlap < 0.3:  # Less than 30% overlap
                self.add_issue(
                    file_path,
                    "WARNING",
                    f"Description may not reflect content well "
                    f"(overlap: {overlap:.1%})",
                )

    def validate_tags_relevance(self, file_path: Path, frontmatter: Dict, content: str):
        """Validate tags relevance to content"""
        tags = frontmatter.get("tags", [])
        if not tags:
            self.add_issue(file_path, "WARNING", "No tags specified")
            return

        if not isinstance(tags, list):
            self.add_issue(file_path, "WARNING", "Tags should be a list")
            return

        # Check if tags appear in content
        content_lower = content.lower()
        missing_tags = []

        for tag in tags:
            if isinstance(tag, str) and len(tag) > 2:
                # Allow for tag variations
                tag_patterns = [
                    tag.lower(),
                    tag.lower().replace("-", " "),
                    tag.lower().replace("_", " "),
                ]
                if not any(pattern in content_lower for pattern in tag_patterns):
                    missing_tags.append(tag)

        if missing_tags and len(missing_tags) > len(tags) / 2:
            self.add_issue(
                file_path, "WARNING", f"Many tags not found in content: {missing_tags}"
            )

    def validate_document_type(self, file_path: Path, frontmatter: Dict, content: str):
        """Validate document type classification"""
        doc_type = frontmatter.get("document_type", "").strip()
        if not doc_type:
            self.add_issue(file_path, "WARNING", "Missing document_type")
            return

        # Check if document type makes sense based on content structure
        content_indicators = {
            "policy": [
                "policy",
                "requirement",
                "must",
                "shall",
                "forbidden",
                "mandatory",
            ],
            "guide": ["step", "how to", "tutorial", "walkthrough", "instructions"],
            "troubleshooting": [
                "error",
                "issue",
                "problem",
                "solution",
                "fix",
                "troubleshoot",
            ],
            "standards": ["standard", "convention", "format", "specification", "rule"],
            "documentation": ["document", "reference", "overview", "summary"],
            "aar": ["after action", "report", "analysis", "incident", "postmortem"],
            "template": ["template", "example", "sample", "placeholder"],
            "agent": ["agent", "bot", "automation", "orchestrat"],
        }

        content_lower = content.lower()
        suggested_types = []

        for dtype, indicators in content_indicators.items():
            if any(indicator in content_lower for indicator in indicators):
                suggested_types.append(dtype)

        if doc_type.lower() not in suggested_types and suggested_types:
            self.add_issue(
                file_path,
                "WARNING",
                f"Document type '{doc_type}' may not match content. "
                f"Suggested: {suggested_types}",
            )

    def validate_project_consistency(self, file_path: Path, frontmatter: Dict):
        """Validate project field consistency"""
        project = frontmatter.get("project", "").strip()

        # Check project based on file path
        path_str = str(file_path)

        expected_projects = {
            "policies/": "core-policies",
            "development/": "core-development",
            "troubleshooting/": "core-troubleshooting",
            "quick-reference/": "core-reference",
            "agents/": "core-agents",
            ".aar/": "core-aar",
            "copilot-refactor/": "refactoring",
            "sessions/": "core-sessions",
        }

        for path_pattern, expected_project in expected_projects.items():
            if path_pattern in path_str:
                if project and project != expected_project:
                    self.add_issue(
                        file_path,
                        "WARNING",
                        f"Project '{project}' doesn't match expected "
                        f"'{expected_project}' for path",
                    )
                break

    def validate_date_fields(self, file_path: Path, frontmatter: Dict):
        """Validate date field formats"""
        date_fields = ["created_at", "updated_at"]

        for field in date_fields:
            if field in frontmatter:
                date_value = frontmatter[field]
                if isinstance(date_value, str):
                    # Check common date formats
                    valid_formats = [
                        r"^\d{4}-\d{2}-\d{2}$",  # YYYY-MM-DD
                        r"^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}Z?$",  # ISO format
                    ]

                    if not any(re.match(fmt, date_value) for fmt in valid_formats):
                        self.add_issue(
                            file_path,
                            "WARNING",
                            f"Invalid date format in {field}: '{date_value}'",
                        )

    def validate_required_fields(self, file_path: Path, frontmatter: Dict):
        """Validate presence of required fields"""
        required_fields = ["title", "description", "document_type"]

        for field in required_fields:
            if field not in frontmatter or not str(frontmatter[field]).strip():
                self.add_issue(file_path, "WARNING", f"Missing required field: {field}")

    def validate_file(self, file_path: Path)  bool:
        """Validate a single markdown file"""
        self.stats["files_processed"] = 1

        frontmatter, content = self.parse_frontmatter(file_path)

        if not frontmatter:
            self.add_issue(file_path, "WARNING", "No frontmatter found")
            return False

        # Run all validation checks
        self.validate_required_fields(file_path, frontmatter)
        self.validate_title_consistency(file_path, frontmatter, content)
        self.validate_description_relevance(file_path, frontmatter, content)
        self.validate_tags_relevance(file_path, frontmatter, content)
        self.validate_document_type(file_path, frontmatter, content)
        self.validate_project_consistency(file_path, frontmatter)
        self.validate_date_fields(file_path, frontmatter)

        return True

    def generate_report(self)  str:
        """Generate validation report"""
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        report_file = self.log_dir / f"frontmatter_validation_report_{timestamp}.md"

        with open(report_file, "w", encoding="utf-8") as f:
            f.write("# DevOnboarder Frontmatter Content Validation Report\n\n")
            f.write(f"**Generated**: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n")
            f.write(f"**Files Processed**: {self.stats['files_processed']}\n")
            f.write(f"**Issues Found**: {self.stats['issues_found']}\n")
            f.write(f"**Critical Issues**: {self.stats['critical_issues']}\n")
            f.write(f"**Warnings**: {self.stats['warnings']}\n\n")

            if self.stats["issues_found"] == 0:
                f.write(" **No validation issues found!**\n\n")
            else:
                f.write("## Validation Issues\n\n")

                # Group issues by severity
                critical_issues = [
                    i for i in self.issues if i["severity"] == "CRITICAL"
                ]
                warnings = [i for i in self.issues if i["severity"] == "WARNING"]

                if critical_issues:
                    f.write("### 🔴 Critical Issues\n\n")
                    for issue in critical_issues:
                        f.write(f"- **{issue['file']}**: {issue['message']}\n")
                    f.write("\n")

                if warnings:
                    f.write("### 🟡 Warnings\n\n")
                    for issue in warnings:
                        f.write(f"- **{issue['file']}**: {issue['message']}\n")
                    f.write("\n")

            f.write("## Summary\n\n")
            if self.stats["critical_issues"] > 0:
                f.write(
                    f" **Validation failed** with "
                    f"{self.stats['critical_issues']} critical issues.\n\n"
                )
            elif self.stats["warnings"] > 0:
                f.write(
                    f" **Validation completed** with "
                    f"{self.stats['warnings']} warnings.\n\n"
                )
            else:
                f.write(" **All validations passed successfully!**\n\n")

            f.write("## Recommendations\n\n")
            f.write(
                "1. **Address Critical Issues**: Fix YAML syntax errors "
                "and missing required fields\n"
            )
            f.write(
                "2. **Review Warnings**: Ensure metadata accurately "
                "reflects document content\n"
            )
            f.write(
                "3. **Standardize Fields**: Use consistent date formats "
                "and document types\n"
            )
            f.write(
                "4. **Content Alignment**: Verify titles, descriptions, "
                "and tags match content\n\n"
            )

            f.write("---\n")
            f.write(
                "**Report generated by**: DevOnboarder Frontmatter Content Validator\n"
            )
            f.write(f"**Log location**: `{report_file}`\n")

        return str(report_file)


def main():
    parser = argparse.ArgumentParser(
        description="Validate frontmatter content consistency"
    )
    parser.add_argument(
        "files", nargs="*", help="Files to validate (default: all changed files)"
    )
    parser.add_argument(
        "--all", action="store_true", help="Validate all markdown files"
    )
    parser.add_argument(
        "--changed-only", action="store_true", help="Validate only git changed files"
    )
    parser.add_argument("--log-dir", default="logs", help="Log directory")

    args = parser.parse_args()

    validator = FrontmatterContentValidator(log_dir=args.log_dir)

    # Determine files to validate
    files_to_validate = []

    if args.all:
        # Find all markdown files
        for root, dirs, files in os.walk("."):
            for file in files:
                if file.endswith(".md"):
                    files_to_validate.append(Path(root) / file)
    elif args.changed_only or not args.files:
        # Get changed files from git
        import subprocess  # noqa: S404

        try:
            result = subprocess.run(  # noqa: S603,S607
                ["/usr/bin/git", "status", "--porcelain"],
                capture_output=True,
                text=True,
                check=True,
                timeout=30,
            )
            for line in result.stdout.strip().split("\n"):
                if line and line.endswith(".md"):
                    file_path = line[3:]  # Remove git status prefix
                    if os.path.exists(file_path):
                        files_to_validate.append(Path(file_path))
        except (subprocess.CalledProcessError, subprocess.TimeoutExpired):
            print("Error: Could not get git status. Not in a git repository?")
            return 1
    else:
        # Use provided files
        files_to_validate = [Path(f) for f in args.files if f.endswith(".md")]

    if not files_to_validate:
        print("No markdown files to validate.")
        return 0

    print(
        f" Validating frontmatter content consistency for "
        f"{len(files_to_validate)} files..."
    )
    print()

    # Validate files
    for file_path in files_to_validate:
        if file_path.exists():
            print(f"Validating: {file_path}")
            validator.validate_file(file_path)
        else:
            print(f"Warning: File not found: {file_path}")

    # Generate report
    report_file = validator.generate_report()

    print()
    print(" Validation Summary:")
    print(f"   Files processed: {validator.stats['files_processed']}")
    print(f"   Issues found: {validator.stats['issues_found']}")
    print(f"   Critical issues: {validator.stats['critical_issues']}")
    print(f"   Warnings: {validator.stats['warnings']}")
    print()
    print(f"FILE: Detailed report: {report_file}")

    # Return appropriate exit code
    if validator.stats["critical_issues"] > 0:
        return 1
    elif validator.stats["warnings"] > 10:  # Too many warnings
        return 1
    else:
        return 0


if __name__ == "__main__":
    exit(main())
