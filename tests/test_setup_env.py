import os
import shutil
import subprocess
from pathlib import Path


def test_setup_env_without_docker(tmp_path):
    """setup-env.sh should create a venv and install deps when Docker is unavailable."""
    repo_root = Path(__file__).resolve().parents[1]
    shutil.copy(repo_root / "scripts" / "setup-env.sh", tmp_path / "setup-env.sh")
    shutil.copy(repo_root / "requirements-dev.txt", tmp_path / "requirements-dev.txt")

    bin_dir = tmp_path / "bin"
    bin_dir.mkdir()
    docker_stub = bin_dir / "docker"
    docker_stub.write_text("#!/bin/sh\nexit 1\n")
    docker_stub.chmod(0o755)

    env = os.environ.copy()
    env["PATH"] = str(bin_dir) + os.pathsep + env.get("PATH", "")

    subprocess.run(
        ["bash", str(tmp_path / "setup-env.sh")],
        cwd=tmp_path,
        env=env,
        check=True,
    )

    venv_dir = tmp_path / "venv"
    assert (venv_dir / "bin" / "python").exists()

    result = subprocess.check_output([venv_dir / "bin" / "pip", "list"], text=True)
    assert "PyYAML" in result


def test_setup_env_ci_skips_docker(tmp_path):
    """setup-env.sh should skip Docker when CI is set."""
    repo_root = Path(__file__).resolve().parents[1]
    shutil.copy(repo_root / "scripts" / "setup-env.sh", tmp_path / "setup-env.sh")
    shutil.copy(repo_root / "requirements-dev.txt", tmp_path / "requirements-dev.txt")

    bin_dir = tmp_path / "bin"
    bin_dir.mkdir()
    docker_stub = bin_dir / "docker"
    docker_stub.write_text(
        "#!/bin/sh\nif [ \"$1\" = \"info\" ]; then exit 0; else exit 1; fi\n"
    )
    docker_stub.chmod(0o755)

    env = os.environ.copy()
    env["PATH"] = str(bin_dir) + os.pathsep + env.get("PATH", "")
    env["CI"] = "true"

    subprocess.run(
        ["bash", str(tmp_path / "setup-env.sh")],
        cwd=tmp_path,
        env=env,
        check=True,
    )

    venv_dir = tmp_path / "venv"
    assert (venv_dir / "bin" / "python").exists()

    result = subprocess.check_output([venv_dir / "bin" / "pip", "list"], text=True)
    assert "PyYAML" in result
