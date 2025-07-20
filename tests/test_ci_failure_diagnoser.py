import importlib.util
import sys
from pathlib import Path

# Load the ci_failure_diagnoser script as a module
spec = importlib.util.spec_from_file_location(
    "ci_failure_diagnoser",
    Path(__file__).resolve().parents[1] / "scripts" / "ci_failure_diagnoser.py",
)
ci_failure_diagnoser = importlib.util.module_from_spec(spec)
spec.loader.exec_module(ci_failure_diagnoser)

SAMPLE_LINES = [
    "Step: python tests",
    "Traceback (most recent call last):",
    "AssertionError: boom",
    "Step: install deps",
    "ModuleNotFoundError: No module named 'foo'",
    "Step: build frontend",
    "npm ERR! missing script: test",
    "yarn ERR! something failed",
    "error Command failed with exit code 1.",
    "Cannot find module 'bar'",
    "Step: unit tests",
    "ERROR: something broke",
    "FAIL MyTest",
    "FAIL MyTest",
]


def test_parse_log(tmp_path):
    log = tmp_path / "ci.log"
    log.write_text("\n".join(SAMPLE_LINES))

    errors = ci_failure_diagnoser.parse_log(log)
    assert errors == [
        "Step: python tests | Traceback (most recent call last):",
        "Step: python tests | AssertionError: boom",
        "Step: install deps | ModuleNotFoundError: No module named 'foo'",
        "Step: build frontend | npm ERR! missing script: test",
        "Step: build frontend | yarn ERR! something failed",
        "Step: build frontend | error Command failed with exit code 1.",
        "Step: build frontend | Cannot find module 'bar'",
        "Step: unit tests | ERROR: something broke",
        "Step: unit tests | FAIL MyTest",
        "Step: unit tests | FAIL MyTest",
    ]


def test_main_outputs_summary(tmp_path, monkeypatch, capsys):
    log = tmp_path / "ci.log"
    log.write_text("\n".join(SAMPLE_LINES))

    monkeypatch.setattr(sys, "argv", ["ci_failure_diagnoser.py", str(log)])
    ci_failure_diagnoser.main()
    out_lines = [line for line in capsys.readouterr().out.splitlines() if line]

    assert out_lines == [
        "# CI Failure Diagnoser",
        "2x Step: unit tests | FAIL MyTest",
        "- Step: python tests | Traceback (most recent call last):",
        "- Step: python tests | AssertionError: boom",
        "- Step: install deps | ModuleNotFoundError: No module named 'foo'",
        "- Step: build frontend | npm ERR! missing script: test",
        "- Step: build frontend | yarn ERR! something failed",
        "- Step: build frontend | error Command failed with exit code 1.",
        "- Step: build frontend | Cannot find module 'bar'",
        "- Step: unit tests | ERROR: something broke",
    ]
