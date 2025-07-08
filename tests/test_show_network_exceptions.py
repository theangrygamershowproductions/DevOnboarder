import re
import shutil
import subprocess
from pathlib import Path


def parse_domains(doc_path: Path) -> list[str]:
    pattern = re.compile(r"^[A-Za-z0-9.-]+\.(?:com|org|io|sh)$")
    domains = []
    for line in doc_path.read_text(encoding="utf-8").splitlines():
        if line.startswith("- "):
            for token in line.split():
                token = token.strip("`")
                if pattern.fullmatch(token):
                    domains.append(token)
    return domains


def test_show_network_exceptions(tmp_path):
    """Output of show_network_exceptions.sh matches the doc."""
    repo_root = Path(__file__).resolve().parents[1]
    script = repo_root / "scripts" / "show_network_exceptions.sh"
    docs_dst = tmp_path / "docs"
    scripts_dst = tmp_path / "scripts"
    docs_dst.mkdir()
    scripts_dst.mkdir()
    src = repo_root / "docs" / "network-exception-list.md"
    dst = docs_dst / "network-exception-list.md"
    shutil.copy(src, dst)
    shutil.copy(script, scripts_dst / "show_network_exceptions.sh")

    result = subprocess.check_output(
        ["bash", str(scripts_dst / "show_network_exceptions.sh")],
        cwd=tmp_path,
        text=True,
    )

    output_domains = result.strip().splitlines()
    expected_domains = parse_domains(repo_root / "docs" / "network-exception-list.md")
    assert output_domains == expected_domains
