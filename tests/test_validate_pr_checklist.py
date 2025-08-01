import shutil
import subprocess
from pathlib import Path


def setup_script(tmp_path: Path, body: str) -> tuple[Path, dict[str, str], Path]:
    """Setup test environment with CI-compatible path resolution."""
    # CRITICAL: CI-compatible path resolution (handles /workspace/DevOnboarder/)
    current_dir = Path.cwd()
    repo_candidates = [
        current_dir,  # Current working directory (CI standard)
        Path(__file__).resolve().parents[1],  # Relative to test file (dev standard)
        Path("/workspace/DevOnboarder"),  # Explicit CI path
    ]

    repo_root = None
    for candidate in repo_candidates:
        if (candidate / "scripts" / "validate_pr_checklist.sh").exists():
            repo_root = candidate
            break

    if not repo_root:
        raise FileNotFoundError(f"Repository root not found in: {repo_candidates}")

    # Copy script with absolute path resolution
    script_src = repo_root / "scripts" / "validate_pr_checklist.sh"
    script_dst = tmp_path / "validate_pr_checklist.sh"
    shutil.copy(script_src, script_dst)

    # Copy checklist with same robust resolution
    checklist_src = repo_root / "docs" / "checklists" / "continuous-improvement.md"
    checklist_dir = tmp_path / "docs" / "checklists"
    checklist_dir.mkdir(parents=True)
    shutil.copy(checklist_src, checklist_dir / "continuous-improvement.md")

    # Create isolated gh stub
    bin_dir = tmp_path / "bin"
    bin_dir.mkdir()
    gh_calls = tmp_path / "gh_calls.log"
    gh_stub = bin_dir / "gh"

    # CRITICAL: Complete gh stub handling both 'pr view' AND 'pr comment'
    gh_stub.write_text(
        "#!/bin/bash\n"
        "set -euo pipefail\n"
        f"echo \"$@\" >> '{gh_calls}'\n"
        f"sync\n"  # Force file system sync
        'if [ "$1" = "pr" ] && [ "$2" = "view" ]; then\n'
        f"  echo '{body}'\n"
        "  exit 0\n"
        'elif [ "$1" = "pr" ] && [ "$2" = "comment" ]; then\n'
        "  exit 0\n"
        "fi\n"
        "exit 0\n"
    )
    gh_stub.chmod(0o755)

    # CRITICAL: Controlled environment (includes system paths but our bin first)
    env = {
        "PATH": str(bin_dir) + ":/usr/bin:/bin",  # Our bin first, then system paths
        "HOME": str(tmp_path),
        "TMPDIR": str(tmp_path),
        "SHELL": "/bin/bash",
    }

    # Initialize log file with explicit sync
    gh_calls.write_text("")
    gh_calls.parent.mkdir(exist_ok=True)

    return script_dst, env, gh_calls


def test_validate_pr_checklist_success(tmp_path: Path) -> None:
    """Test successful PR checklist validation."""
    body = "## Continuous Improvement Checklist\n- [ ] item"
    script, env, gh_calls = setup_script(tmp_path, body)

    result = subprocess.run(
        ["bash", str(script), "1"],
        cwd=tmp_path,
        capture_output=True,
        text=True,
        env=env,
        check=False,
    )
    assert result.returncode == 0

    # Force file system sync before reading
    subprocess.run(["sync"], check=False)
    calls = gh_calls.read_text().splitlines()

    assert any("pr view" in call for call in calls)
    assert not any("pr comment" in call for call in calls)


def test_validate_pr_checklist_failure(tmp_path: Path) -> None:
    """Test PR checklist validation failure with comment posting."""
    script, env, gh_calls = setup_script(tmp_path, "missing")

    result = subprocess.run(
        ["bash", str(script), "1"],
        cwd=tmp_path,
        capture_output=True,
        text=True,
        env=env,
        check=False,
    )
    assert result.returncode == 1
    assert "Continuous Improvement Checklist missing or incomplete" in result.stderr
    assert "Retrospective for the sprint" in result.stderr

    # CRITICAL: Force file system sync before reading log
    subprocess.run(["sync"], check=False)
    calls = gh_calls.read_text().splitlines()

    assert any("pr view" in call for call in calls), f"Missing 'pr view' in: {calls}"
    assert any(
        "pr comment" in call for call in calls
    ), f"Missing 'pr comment' in: {calls}"
