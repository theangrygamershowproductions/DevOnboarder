import importlib.util
import sys
from pathlib import Path


# Load the ci_log_audit script as a module
spec = importlib.util.spec_from_file_location(
    "ci_log_audit", Path(__file__).resolve().parents[1] / "scripts" / "ci_log_audit.py"
)
ci_log_audit = importlib.util.module_from_spec(spec)
spec.loader.exec_module(ci_log_audit)


SAMPLE_LINES = [
    "All good",
    "Traceback (most recent call last):",
    "npm ERR! missing script: test",
    "ERROR: something broke",
    "FAIL MyTest",
    "FAIL MyTest",
]


def test_extract_errors(tmp_path):
    log = tmp_path / "ci.log"
    log.write_text("\n".join(SAMPLE_LINES))

    errors = ci_log_audit.extract_errors(log)
    assert errors == [
        "Traceback (most recent call last):",
        "npm ERR! missing script: test",
        "ERROR: something broke",
        "FAIL MyTest",
        "FAIL MyTest",
    ]


def test_main_summarizes_counts(tmp_path, monkeypatch, capsys):
    log = tmp_path / "ci.log"
    log.write_text("\n".join(SAMPLE_LINES))

    monkeypatch.setattr(sys, "argv", ["ci_log_audit.py", str(log)])
    ci_log_audit.main()
    out_lines = [line for line in capsys.readouterr().out.splitlines() if line]

    assert out_lines == [
        "# CI Log Audit",
        "2x FAIL MyTest",
        "- Traceback (most recent call last):",
        "- npm ERR! missing script: test",
        "- ERROR: something broke",
    ]
