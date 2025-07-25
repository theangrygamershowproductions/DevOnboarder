import importlib.util
from pathlib import Path

# Load the script as a module
spec = importlib.util.spec_from_file_location(
    "parse_retro_actions",
    Path(__file__).resolve().parents[1] / "scripts" / "parse_retro_actions.py",
)
parse_retro_actions = importlib.util.module_from_spec(spec)
spec.loader.exec_module(parse_retro_actions)


def test_parse_actions(tmp_path: Path) -> None:
    retro_dir = tmp_path / "docs" / "checklists" / "retros"
    retro_dir.mkdir(parents=True)
    file = retro_dir / "2024-07-16.md"
    file.write_text("- [ ] Task one @alice\n- [x] Done\n- [ ] Task two @bob")

    actions = parse_retro_actions.parse_actions(retro_dir)
    assert actions == [
        f"{file}:- [ ] Task one @alice",
        f"{file}:- [ ] Task two @bob",
    ]
    assert parse_retro_actions.extract_usernames(actions) == ["@alice", "@bob"]


def test_cli_owners(tmp_path: Path, capsys) -> None:
    retro_dir = tmp_path / "docs" / "checklists" / "retros"
    retro_dir.mkdir(parents=True)
    (retro_dir / "retro.md").write_text("- [ ] Example @user")

    parse_retro_actions.main([str(retro_dir), "--owners"])
    assert capsys.readouterr().out.strip() == "@user"
