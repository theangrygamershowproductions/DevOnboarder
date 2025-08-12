#!/usr/bin/env python3
"""Proactive Policy Monitor - Real-time CI Framework Integration.

Extends the current emoji policy enforcement tools to provide real-time
monitoring and proactive validation. Integrates with existing infrastructure
from the comprehensive emoji policy enforcement framework.
"""

import os
import sys
import time
import subprocess
from pathlib import Path
from typing import Dict, List, Optional

from watchdog.observers import Observer
from watchdog.events import FileSystemEventHandler

# Import existing enforcement tools - add to path first
sys.path.append(str(Path(__file__).parent))


class ProactivePolicyHandler(FileSystemEventHandler):
    """Real-time file system handler for proactive policy enforcement."""

    def __init__(self):
        """Initialize with existing enforcement tools."""
        self.validation_cache: Dict[str, float] = {}
        self.violation_count = 0
        self.last_qc_run = 0

        # Integration with existing QC system
        self.qc_script = Path(__file__).parent / "qc_pre_push.sh"
        self.enforcement_enabled = self._check_enforcement_status()

        # Dynamic imports for existing tools
        self._import_enforcement_tools()

    def _import_enforcement_tools(self):
        """Dynamically import existing enforcement tools."""
        try:
            # These imports are handled dynamically to avoid import errors
            import importlib.util

            # Import agent policy enforcer if available
            enforcer_path = Path(__file__).parent / "agent_policy_enforcer.py"
            if enforcer_path.exists():
                spec = importlib.util.spec_from_file_location(
                    "agent_policy_enforcer", enforcer_path
                )
                if spec and spec.loader:
                    module = importlib.util.module_from_spec(spec)
                    spec.loader.exec_module(module)
                    self.detect_policy_violations = getattr(
                        module, "detect_policy_violations", None
                    )

            # Import emoji scrubber if available
            scrubber_path = Path(__file__).parent / "comprehensive_emoji_scrub.py"
            if scrubber_path.exists():
                spec = importlib.util.spec_from_file_location(
                    "comprehensive_emoji_scrub", scrubber_path
                )
                if spec and spec.loader:
                    module = importlib.util.module_from_spec(spec)
                    spec.loader.exec_module(module)
                    scrubber_class = getattr(module, "EmojiScrubber", None)
                    if scrubber_class:
                        self.emoji_scrubber = scrubber_class()

            # Import terminal validator if available
            validator_path = (
                Path(__file__).parent / "validate_terminal_output_simple.sh"
            )
            # For shell script, we'll use subprocess
            self.has_terminal_validator = validator_path.exists()

        except Exception as e:
            print(f"Warning: Could not import enforcement tools: {e}")
            self.detect_policy_violations = None
            self.emoji_scrubber = None
            self.has_terminal_validator = False

    def _check_enforcement_status(self) -> bool:
        """Check if proactive enforcement is enabled via environment."""
        return os.getenv("PROACTIVE_CI_ENABLED", "true").lower() == "true"

    def _should_validate_file(self, file_path: str) -> bool:
        """Determine if file should trigger proactive validation."""
        if not self.enforcement_enabled:
            return False

        path = Path(file_path)

        # Skip validation for certain patterns
        skip_patterns = [
            ".git/",
            "node_modules/",
            ".venv/",
            "__pycache__/",
            "logs/",
            ".pytest_cache/",
            "coverage/",
            ".coverage",
        ]

        if any(pattern in str(path) for pattern in skip_patterns):
            return False

        # Focus on critical file types
        critical_extensions = {".py", ".sh", ".yml", ".yaml", ".md", ".json"}
        if path.suffix not in critical_extensions:
            return False

        # Rate limiting: don't validate same file too frequently
        now = time.time()
        if file_path in self.validation_cache:
            if now - self.validation_cache[file_path] < 5:  # 5 second cooldown
                return False

        self.validation_cache[file_path] = now
        return True

    def _run_targeted_validation(self, file_path: str) -> Dict[str, any]:
        """Run targeted validation using existing enforcement tools."""
        results = {
            "file": file_path,
            "timestamp": time.time(),
            "violations": [],
            "auto_fixed": False,
            "needs_attention": False,
        }

        try:
            path = Path(file_path)

            # 1. Policy violation detection (existing tool)
            if path.suffix in {".py", ".sh", ".yml", ".yaml", ".md"}:
                has_detector = (
                    hasattr(self, "detect_policy_violations")
                    and self.detect_policy_violations
                )
                if has_detector:
                    violations = self.detect_policy_violations(file_path)
                    if violations:
                        results["violations"].extend(violations)

            # 2. Emoji detection and auto-fix (existing tool)
            if path.suffix == ".md" or path.suffix in {".py", ".sh", ".yml"}:
                if hasattr(self, "emoji_scrubber") and self.emoji_scrubber:
                    fixed = self.emoji_scrubber.process_file(file_path, auto_fix=True)
                    if fixed:
                        results["auto_fixed"] = True
                        print(f"SYMBOL Auto-fixed emoji violations in {file_path}")

            # 3. Terminal output validation (existing tool)
            if path.suffix == ".sh":
                if self.has_terminal_validator:
                    terminal_safe = self._validate_terminal_output(file_path)
                    if not terminal_safe:
                        results["violations"].append("terminal_output_unsafe")

            # 4. Check if full QC needed
            if results["violations"] and not results["auto_fixed"]:
                results["needs_attention"] = True
                self.violation_count += 1

        except Exception as e:
            results["violations"].append(f"validation_error: {e}")

        return results

    def _trigger_smart_qc(self) -> None:
        """Trigger smart QC validation when threshold reached."""
        now = time.time()

        # Only run QC if violations accumulated or time threshold reached
        should_run = (
            self.violation_count >= 3  # Violation threshold
            or (now - self.last_qc_run) > 300  # 5 minute time threshold
        )

        if should_run and self.qc_script.exists():
            violation_msg = f"({self.violation_count} violations)"
            print(f"SYMBOL Triggering smart QC validation {violation_msg}")
            try:
                result = subprocess.run(
                    [str(self.qc_script)], capture_output=True, text=True, timeout=60
                )
                if result.returncode == 0:
                    print("SYMBOL Smart QC validation passed")
                    self.violation_count = 0  # Reset counter
                else:
                    print("SYMBOL Smart QC validation found issues")
                    print(result.stdout[-500:])  # Last 500 chars

            except subprocess.TimeoutExpired:
                print("⏰ Smart QC validation timed out")
            except Exception as e:
                print(f"SYMBOL Smart QC validation error: {e}")

            self.last_qc_run = now

    def _validate_terminal_output(self, file_path: str) -> bool:
        """Validate terminal output using existing shell script."""
        try:
            validator_script = (
                Path(__file__).parent / "validate_terminal_output_simple.sh"
            )
            if not validator_script.exists():
                return True  # Skip if validator not available

            result = subprocess.run(
                ["bash", str(validator_script), file_path],
                capture_output=True,
                text=True,
                timeout=30,
            )
            return result.returncode == 0
        except Exception:
            return True  # Default to safe if validation fails

    def on_modified(self, event):
        """Handle file modification events."""
        if event.is_directory:
            return

        file_path = event.src_path
        if self._should_validate_file(file_path):
            print(f"SYMBOL Proactive validation: {file_path}")

            results = self._run_targeted_validation(file_path)

            if results["violations"]:
                print(
                    f"SYMBOL Found violations in {file_path}: {results['violations']}"
                )

            if results["needs_attention"]:
                self._trigger_smart_qc()

    def on_created(self, event):
        """Handle file creation events."""
        if not event.is_directory:
            self.on_modified(event)


class ProactiveCIMonitor:
    """Main proactive CI monitoring system."""

    def __init__(self, watch_paths: Optional[List[str]] = None):
        """Initialize proactive monitoring system."""
        self.watch_paths = watch_paths or ["."]
        self.observer = Observer()
        self.handler = ProactivePolicyHandler()
        self.is_running = False

    def start(self) -> None:
        """Start proactive monitoring."""
        print("SYMBOL Starting Proactive CI Framework")
        print("   Integrating with emoji policy enforcement infrastructure")
        print("   Watching paths:", self.watch_paths)

        for path in self.watch_paths:
            if os.path.exists(path):
                self.observer.schedule(self.handler, path, recursive=True)
                print(f"   SYMBOL Monitoring: {path}")
            else:
                print(f"   SYMBOL Path not found: {path}")

        self.observer.start()
        self.is_running = True
        print("SYMBOL Proactive CI monitoring active")

        try:
            while self.is_running:
                time.sleep(1)
        except KeyboardInterrupt:
            self.stop()

    def stop(self) -> None:
        """Stop proactive monitoring."""
        print("SYMBOL Stopping Proactive CI Framework")
        if self.observer.is_alive():
            self.observer.stop()
            self.observer.join()
        self.is_running = False
        print("SYMBOL Proactive monitoring stopped")


def main():
    """Main entry point for proactive CI monitoring."""
    import argparse

    parser = argparse.ArgumentParser(
        description="Proactive CI Framework - Real-time Policy Enforcement"
    )
    parser.add_argument(
        "--paths",
        nargs="+",
        default=["src", "scripts", "docs", ".github"],
        help="Paths to monitor for changes",
    )
    parser.add_argument(
        "--daemon", action="store_true", help="Run as background daemon"
    )

    args = parser.parse_args()

    # Ensure we're in virtual environment (DevOnboarder requirement)
    if not os.getenv("VIRTUAL_ENV"):
        print("SYMBOL Virtual environment required for DevOnboarder")
        print("   Run: source .venv/bin/activate")
        sys.exit(1)

    monitor = ProactiveCIMonitor(args.paths)

    if args.daemon:
        print("SYMBOL Running in daemon mode")
        # In production, this would use proper daemon libraries

    monitor.start()


if __name__ == "__main__":
    main()
