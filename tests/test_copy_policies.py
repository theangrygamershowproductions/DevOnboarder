# PATCHED v0.1.1 tests/test_copy_policies.py — include frontend node_modules
"""Unit tests for copyPolicies utilities."""

import subprocess
import os
import shutil
import pytest


def run_update_owner(data: str, owner: str) -> str:
    cmd = [
        "node",
        "-r",
        "ts-node/register",
        "-e",
        (
            "const { updateOwner } = require('./codex/src/tasks/copyPolicies.ts');"
            f"process.stdout.write(updateOwner({data!r}, {owner!r}));"
        ),
    ]
    node_root = subprocess.check_output(["npm", "root", "-g"], text=True).strip()
    env = os.environ.copy()
    frontend_modules = os.path.join(os.getcwd(), "frontend", "node_modules")
    auth_modules = os.path.join(os.getcwd(), "auth-server", "node_modules")
    env["NODE_PATH"] = (
        env.get("NODE_PATH", "")
        + os.pathsep
        + node_root
        + os.pathsep
        + frontend_modules
        + os.pathsep
        + auth_modules
    )
    env["TS_NODE_COMPILER_OPTIONS"] = (
        '{"module":"CommonJS","esModuleInterop":true,'
        '"skipLibCheck":true,"moduleResolution":"node",'
        '"allowImportingTsExtensions":true}'
    )
    result = subprocess.run(
        cmd, capture_output=True, text=True, cwd=os.getcwd(), env=env
    )
    assert result.returncode == 0, result.stderr
    return result.stdout


@pytest.mark.skipif(
    shutil.which("ts-node") is None,
    reason="ts-node executable not found",
)
def test_update_owner_inserts_special_chars():
    """Owners with symbols should be copied verbatim."""
    output = run_update_owner("Copyright <<COPYRIGHT_OWNER>>", "A&B Co. (c)")
    assert output == "Copyright A&B Co. (c)"


@pytest.mark.skipif(
    shutil.which("ts-node") is None,
    reason="ts-node executable not found",
)
def test_copy_policies_script():
    """Execute TypeScript test verifying copy summary counts."""
    cmd = [
        "node",
        "-r",
        "ts-node/register",
        "tests/codex/test_copy_policies.ts",
    ]
    node_root = subprocess.check_output(["npm", "root", "-g"], text=True).strip()
    env = os.environ.copy()
    frontend_modules = os.path.join(os.getcwd(), "frontend", "node_modules")
    auth_modules = os.path.join(os.getcwd(), "auth-server", "node_modules")
    env["NODE_PATH"] = (
        env.get("NODE_PATH", "")
        + os.pathsep
        + node_root
        + os.pathsep
        + frontend_modules
        + os.pathsep
        + auth_modules
    )
    env["TS_NODE_COMPILER_OPTIONS"] = (
        '{"module":"CommonJS","esModuleInterop":true,'
        '"skipLibCheck":true,"moduleResolution":"node",'
        '"allowImportingTsExtensions":true}'
    )
    result = subprocess.run(
        cmd, capture_output=True, text=True, cwd=os.getcwd(), env=env
    )
    assert result.returncode == 0, result.stderr
