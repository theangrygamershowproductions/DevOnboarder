import os
import shutil
import subprocess
from pathlib import Path


def setup_script(tmp_path: Path, body: str) -> tuple[Path, dict[str, str]]:
    repo_root = Path(__file__).resolve().parents[1]
    script_src = repo_root / "scripts" / "validate_pr_checklist.sh"
    script_dst = tmp_path / "validate_pr_checklist.sh"
    shutil.copy(script_src, script_dst)

    checklist_dir = tmp_path / "docs" / "checklists"
    checklist_dir.mkdir(parents=True)
    shutil.copy(
        repo_root / "docs" / "checklists" / "continuous-improvement.md",
        checklist_dir / "continuous-improvement.md",
    )

    bin_dir = tmp_path / "bin"
    bin_dir.mkdir()
    gh_stub = bin_dir / "gh"
    gh_stub.write_text(
        "#!/bin/sh\n"
        "if [ \"$1\" = \"pr\" ] && [ \"$2\" = \"view\" ]; then\n"
        f"  echo '{body}'\n"
        "  exit 0\n"
        "fi\n"
        "exit 0\n"
    )
    gh_stub.chmod(0o755)

    env = os.environ.copy()
    env["PATH"] = str(bin_dir) + os.pathsep + env.get("PATH", "")
    return script_dst, env


def test_validate_pr_checklist_success(tmp_path: Path) -> None:
    body = "## Continuous Improvement Checklist\n- [ ] item"
    script, env = setup_script(tmp_path, body)
    result = subprocess.run([
        "bash",
        str(script),
        "1",
    ], cwd=tmp_path, env=env)
    assert result.returncode == 0


def test_validate_pr_checklist_failure(tmp_path: Path) -> None:
    script, env = setup_script(tmp_path, "missing")
    result = subprocess.run(
        ["bash", str(script), "1"],
        cwd=tmp_path,
        capture_output=True,
        text=True,
        env=env,
    )
    assert result.returncode == 1
    assert "Continuous Improvement Checklist missing or incomplete" in result.stderr
    assert "Retrospective for the sprint" in result.stderr
