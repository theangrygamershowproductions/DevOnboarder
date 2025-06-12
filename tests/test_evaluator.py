# PATCHED v0.1.39 tests/test_evaluator.py — Verify rubric evaluation scoring

"""Unit tests for the Codex challenge evaluator module."""
import json

from codex import evaluate as eval_mod


class DummyCompleted:
    """Simple object mimicking subprocess.CompletedProcess."""

    def __init__(self, returncode: int):
        self.returncode = returncode
        self.stdout = ""
        self.stderr = ""


def fake_run_factory(expected):
    """Return a subprocess.run replacement."""

    def _run(cmd, capture_output=True, text=True):
        test_name = cmd[cmd.index("-k") + 1]
        return DummyCompleted(0 if expected.get(test_name, False) else 1)

    return _run


def test_evaluate_submission_scores_points(monkeypatch, tmp_path):
    """Ensure evaluator aggregates test results into a final score."""
    rubric = {
        "challenge": "sample",
        "total_points": 3,
        "tests": [
            {"name": "first", "points": 1, "description": ""},
            {"name": "second", "points": 2, "description": ""},
        ],
    }
    rubric_path = tmp_path / "sample-rubric.json"
    rubric_path.write_text(json.dumps(rubric))

    monkeypatch.setattr(
        eval_mod.subprocess,
        "run",
        fake_run_factory({"first": True, "second": False}),
    )
    result = eval_mod.evaluate_submission(
        "sample",
        submission="does_not_matter.py",
        rubrics_dir=str(tmp_path),
    )
    assert result["score"] == 1
    assert result["total"] == 3
    assert result["results"][0]["passed"] is True
    assert result["results"][1]["passed"] is False
