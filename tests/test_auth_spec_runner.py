# PATCHED v0.1.58 tests/test_auth_spec_runner.py — skip when ts-node missing

"""Run TypeScript auth.spec tests with ts-node."""
import os
import shutil
import subprocess
import pytest


@pytest.mark.skipif(
    shutil.which("ts-node") is None,
    reason="ts-node executable not found",
)
def test_auth_spec():
    cmd = ["ts-node", "auth-server/tests/auth.spec.ts"]
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
