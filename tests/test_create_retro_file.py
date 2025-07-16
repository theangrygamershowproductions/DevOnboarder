import shutil
import subprocess
from datetime import date
from pathlib import Path


def setup_files(tmp_path: Path) -> Path:
    repo_root = Path(__file__).resolve().parents[1]
    script = repo_root / "scripts" / "create-retro-file.sh"
    shutil.copy(script, tmp_path / "create-retro-file.sh")
    checklist_dir = tmp_path / "docs" / "checklists"
    checklist_dir.mkdir(parents=True)
    shutil.copy(
        repo_root / "docs" / "checklists" / "retrospective-template.md",
        checklist_dir / "retrospective-template.md",
    )
    (checklist_dir / "retros").mkdir()
    return tmp_path


def test_create_retro_file(tmp_path: Path) -> None:
    setup_files(tmp_path)
    subprocess.run(
        ["bash", str(tmp_path / "create-retro-file.sh")],
        cwd=tmp_path,
        check=True,
    )

    today = date.today().strftime("%Y-%m-%d")
    new_file = tmp_path / "docs" / "checklists" / "retros" / f"{today}.md"
    assert new_file.exists()

    content = new_file.read_text()
    template = (
        tmp_path / "docs" / "checklists" / "retrospective-template.md"
    ).read_text()
    assert content == template.replace("[YYYY-MM-DD or Sprint #]", today)


def test_create_retro_file_exists(tmp_path: Path) -> None:
    setup_files(tmp_path)

    today = date.today().strftime("%Y-%m-%d")
    existing = tmp_path / "docs" / "checklists" / "retros" / f"{today}.md"
    existing.write_text("test")

    result = subprocess.run(
        ["bash", str(tmp_path / "create-retro-file.sh")],
        cwd=tmp_path,
        capture_output=True,
        text=True,
    )
    assert result.returncode == 1
    assert "already exists" in result.stderr
