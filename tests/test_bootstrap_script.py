import os
import shutil
import subprocess
from pathlib import Path


def test_bootstrap_creates_env_dev(tmp_path):
    """bootstrap.sh should create .env.dev from .env.example."""
    repo_root = Path(__file__).resolve().parents[1]
    # copy scripts and env example to a temp directory
    shutil.copy(repo_root / "scripts" / "bootstrap.sh", tmp_path / "bootstrap.sh")
    shutil.copy(repo_root / "scripts" / "setup-env.sh", tmp_path / "setup-env.sh")
    shutil.copy(repo_root / ".env.example", tmp_path / ".env.example")

    # stub docker to avoid heavy operations
    bin_dir = tmp_path / "bin"
    bin_dir.mkdir()
    docker_stub = bin_dir / "docker"
    docker_stub.write_text("#!/bin/sh\nexit 0\n")
    docker_stub.chmod(0o755)

    env = os.environ.copy()
    env["PATH"] = str(bin_dir) + os.pathsep + env.get("PATH", "")

    subprocess.run(
        ["bash", str(tmp_path / "bootstrap.sh")],
        cwd=tmp_path,
        env=env,
        check=True,
    )

    env_dev = tmp_path / ".env.dev"
    assert env_dev.exists()
    assert env_dev.read_text() == (tmp_path / ".env.example").read_text()
