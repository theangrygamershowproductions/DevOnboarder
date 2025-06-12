# PATCHED v0.1.39 codex/evaluate.py — Add rubric-based scoring

"""
Project: DevOnboarder
Module: Codex Evaluation
Phase: MVP
Tags: [codex, evaluation, automation, runner, toggle]
Updated: 12 Jun 2025 02:00 (EST)
Version: v0.1.1
Author: Chad Reesey
Email: potato@theangrygamershow.com
Description: Challenge evaluator script with optional internet toggle.
References: challenges/login-challenge.md and rubrics/login-rubric.json.
"""

import argparse
import json
import os
import subprocess
from pathlib import Path


def run_challenge(
    challenge: str,
    submission: str,
    allow_net: bool = False,
) -> int:
    """Run the given submission in a secure or unrestricted environment."""
    # fmt: off
    print(
        f"[INFO] Running challenge '{challenge}' with submission "
        f"'{submission}'"
    )
    # fmt: on
    if not os.path.exists(submission):
        print(f"[ERROR] Submission file '{submission}' not found.")
        return 1

    command = ["python3", submission]
    env = os.environ.copy()

    if not allow_net:
        print("[SECURE MODE] Internet access is disabled during this run.")
        # This is a logical toggle — in actual implementation, container-level
        # or sandbox enforcement would be needed
        # (e.g., firejail, docker --network none)
        env["NO_INTERNET"] = "1"

    try:
        result = subprocess.run(
            command,
            capture_output=True,
            text=True,
            env=env,
        )
        print("\n=== STDOUT ===\n", result.stdout)
        print("\n=== STDERR ===\n", result.stderr)
        return result.returncode
    except Exception as e:
        print(f"[CRITICAL] Failed to execute challenge: {e}")
        return 2


def load_rubric(challenge: str, rubrics_dir: str = "rubrics") -> dict:
    """Return rubric data for the given challenge."""
    rubric_path = Path(rubrics_dir) / f"{challenge}-rubric.json"
    if not rubric_path.exists():
        raise FileNotFoundError(f"Rubric not found: {rubric_path}")
    with open(rubric_path, "r", encoding="utf-8") as fh:
        return json.load(fh)


def run_test(test_name: str) -> bool:
    """Execute a pytest run for the given test name."""
    cmd = ["pytest", "-k", test_name, "-q"]
    result = subprocess.run(cmd, capture_output=True, text=True)
    print(result.stdout)
    if result.returncode != 0:
        print(result.stderr)
    return result.returncode == 0


def evaluate_submission(
    challenge: str,
    submission: str,
    allow_net: bool = False,
    rubrics_dir: str = "rubrics",
) -> dict:
    """Run a submission and score it using the appropriate rubric."""

    run_challenge(
        challenge=challenge,
        submission=submission,
        allow_net=allow_net,
    )
    rubric = load_rubric(challenge, rubrics_dir=rubrics_dir)

    results = []
    score = 0
    for test in rubric.get("tests", []):
        passed = run_test(test["name"])
        if passed:
            score += test["points"]
        results.append(
            {"name": test["name"], "passed": passed, "points": test["points"]}
        )

    print("\n=== Evaluation Summary ===")
    for res in results:
        status = "PASS" if res["passed"] else "FAIL"
        earned = res["points"] if res["passed"] else 0
        print(f"{res['name']}: {status} ({earned}/{res['points']})")
    print(f"TOTAL: {score}/{rubric['total_points']}")

    return {
        "score": score,
        "total": rubric["total_points"],
        "results": results,
    }


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Evaluate a challenge submission.")
    parser.add_argument(
        "--challenge",
        required=True,
        help="Name of the challenge",
    )
    parser.add_argument(
        "--submission", required=True, help="Path to the user submission"
    )
    parser.add_argument(
        "--allow-net",
        action="store_true",
        help="Allow internet access during execution",
    )
    args = parser.parse_args()

    summary = evaluate_submission(
        challenge=args.challenge,
        submission=args.submission,
        allow_net=args.allow_net,
    )

    exit(0 if summary["score"] == summary["total"] else 1)

__version__ = "v0.1.1"
__updated__ = "12 Jun 2025 02:00 (EST)"
