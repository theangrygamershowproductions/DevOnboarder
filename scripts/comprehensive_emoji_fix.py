#!/usr/bin/env python3
"""
Comprehensive Emoji Fix for Phase 3 Framework.

Handles both shell scripts and Python files with DevOnboarder
terminal output compliance.
"""

import os
import sys
from pathlib import Path
from datetime import datetime

# DevOnboarder emoji mapping for terminal output compliance
EMOJI_MAP = {
    # Basic status indicators
    "✅": "SUCCESS:",
    "❌": "ERROR:",
    "⚠️": "WARNING:",
    "🟢": "SUCCESS:",
    "🔴": "ERROR:",
    "🟡": "WARNING:",
    "🟠": "DEGRADED:",
    # Action indicators
    "🔍": "INFO:",
    "📋": "INFO:",
    "🎯": "TARGET:",
    "🚀": "ACTION:",
    "⚡": "QUICK:",
    "📊": "STATS:",
    "📝": "NOTE:",
    "💡": "TIP:",
    "🏗️": "BUILD:",
    "⚙️": "CONFIG:",
    "🤖": "BOT:",
    "👁️": "MONITOR:",
    "🕒": "TIME:",
    # Additional indicators found in codebase
    "🛡️": "SECURITY:",
    "🔗": "LINK:",
    "ℹ️": "INFO:",
    "🚨": "ALERT:",
}


def create_backup(file_path):
    """Create backup of file before modification."""
    backup_path = f"{file_path}.emoji_fix_backup"
    if not os.path.exists(backup_path):
        with open(file_path, "r", encoding="utf-8") as original:
            with open(backup_path, "w", encoding="utf-8") as backup:
                backup.write(original.read())
    return backup_path


def fix_file_emojis(file_path):
    """Fix emoji violations in a single file."""
    try:
        with open(file_path, "r", encoding="utf-8") as f:
            content = f.read()

        fixes_made = 0

        # Apply emoji replacements
        for emoji, replacement in EMOJI_MAP.items():
            if emoji in content:
                # Count occurrences
                count = content.count(emoji)
                if count > 0:
                    content = content.replace(emoji, replacement)
                    fixes_made += count
                    print(f"  Fixed {count}x: {emoji} -> {replacement}")

        # Only write if changes were made
        if fixes_made > 0:
            create_backup(file_path)
            with open(file_path, "w", encoding="utf-8") as f:
                f.write(content)
            print(f"  Total fixes: {fixes_made}")
            return fixes_made
        else:
            print("  No fixes needed")
            return 0

    except (OSError, UnicodeDecodeError) as e:
        print(f"  ERROR: Failed to process {file_path}: {e}")
        return 0


def main():
    """Main execution function."""
    framework_dir = Path("frameworks/monitoring_automation")

    if not framework_dir.exists():
        print("ERROR: frameworks/monitoring_automation directory not found")
        return 1

    print("Comprehensive Phase 3 Framework Emoji Fix")
    print("=" * 50)
    print(f"Timestamp: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    print()

    total_fixes = 0
    files_processed = 0

    # Process all files in framework
    for file_path in framework_dir.rglob("*"):
        if file_path.is_file() and file_path.suffix in [".py", ".sh"]:
            print(f"Processing: {file_path}")
            fixes = fix_file_emojis(file_path)
            total_fixes += fixes
            files_processed += 1
            print()

    print("=" * 50)
    print("Comprehensive Emoji Fix Complete")
    print("=" * 50)
    print(f"Files processed: {files_processed}")
    print(f"Total fixes applied: {total_fixes}")
    print()

    # Verify compliance
    print("Verifying compliance...")
    violation_count = 0

    for file_path in framework_dir.rglob("*"):
        if file_path.is_file() and file_path.suffix in [".py", ".sh"]:
            try:
                with open(file_path, "r", encoding="utf-8") as f:
                    content = f.read()
                for emoji in EMOJI_MAP.keys():
                    if emoji in content:
                        violation_count += content.count(emoji)
            except (OSError, UnicodeDecodeError):
                pass

    if violation_count == 0:
        print("SUCCESS: No emoji violations found in Phase 3 framework")
        print(
            "Phase 3 framework is now compliant with "
            "DevOnboarder terminal output policy"
        )
    else:
        print(f"WARNING: {violation_count} violations may remain")
        print("Manual review may be required for edge cases")

    print()
    print("Next steps:")
    print("1. Review fixed files for correctness")
    print("2. Test script functionality")
    print("3. Remove .emoji_fix_backup files if satisfied")
    print("4. Commit emoji compliance fixes")

    return 0


if __name__ == "__main__":
    sys.exit(main())
