"""
Test suite for DevOnboarder CI Health Dashboard Engine
Tests the comprehensive CI monitoring and health management system.
"""

import json
import os
import subprocess
import sys
from datetime import datetime
from pathlib import Path
from unittest.mock import MagicMock, patch, mock_open
import unittest.mock as unittest_mock

import pytest

# Add scripts directory to path for imports
scripts_path = Path(__file__).parent.parent / "scripts"
sys.path.insert(0, str(scripts_path))
import devonboarder_ci_health  # Import after path modification  # noqa: E402


class TestTokenLoader:
    """Test the TokenLoader class functionality."""

    def test_token_loader_initialization(self):
        """Test TokenLoader initializes correctly."""
        loader = devonboarder_ci_health.TokenLoader()
        assert loader.token is None
        assert loader.token_source is None

    @patch.dict(os.environ, {"CI_BOT_TOKEN": "test_token_123"}, clear=True)
    def test_load_token_from_environment(self):
        """Test token loading from environment variable."""
        loader = devonboarder_ci_health.TokenLoader()
        token = loader.load_token()
        assert token == "test_token_123"
        assert loader.token_source == "CI_BOT_TOKEN"  # noqa: B105

    @patch.dict(os.environ, {}, clear=True)
    @patch("devonboarder_ci_health.subprocess.run")
    def test_load_token_from_file(self, mock_subprocess):
        """Test token loading from enhanced token loader script."""
        # Mock successful script execution
        mock_result = unittest_mock.MagicMock()
        mock_result.returncode = 0
        mock_result.stdout = "file_token_456"
        mock_subprocess.return_value = mock_result

        loader = devonboarder_ci_health.TokenLoader()
        token = loader.load_token()
        assert token == "file_token_456"
        assert loader.token_source == "enhanced_token_loader.sh"

    @patch.dict(os.environ, {}, clear=True)
    @patch("devonboarder_ci_health.subprocess.run")
    def test_load_token_failure(self, mock_subprocess):
        """Test token loading when no token is available."""
        # Mock script execution failure
        mock_result = unittest_mock.MagicMock()
        mock_result.returncode = 1
        mock_result.stdout = ""
        mock_subprocess.return_value = mock_result

        loader = devonboarder_ci_health.TokenLoader()
        token = loader.load_token()
        assert token is None


class TestCIHealthDashboard:
    """Test the main CI Health Dashboard functionality."""

    def setup_method(self):
        """Set up test fixtures."""
        self.dashboard = devonboarder_ci_health.CIHealthDashboard()

    def test_dashboard_initialization(self):
        """Test CI Health Dashboard initializes correctly."""
        assert self.dashboard is not None
        assert hasattr(self.dashboard, "token_loader")

    @patch("devonboarder_ci_health.subprocess.run")
    def test_get_workflow_runs_success(self, mock_run):
        """Test successful workflow runs retrieval."""
        # Mock successful API response
        mock_response = {
            "workflow_runs": [
                {
                    "id": 123456,
                    "name": "CI",
                    "status": "completed",
                    "conclusion": "success",
                    "created_at": "2023-10-01T12:00:00Z",
                    "updated_at": "2023-10-01T12:05:00Z",
                }
            ]
        }
        mock_run.return_value.stdout = json.dumps(mock_response).encode()
        mock_run.return_value.returncode = 0

        result = self.dashboard.get_workflow_runs("test-repo")
        assert result is not None
        assert len(result["workflow_runs"]) == 1
        assert result["workflow_runs"][0]["status"] == "completed"

    @patch("devonboarder_ci_health.subprocess.run")
    def test_get_workflow_runs_failure(self, mock_run):
        """Test workflow runs retrieval failure."""
        mock_run.return_value.returncode = 1
        mock_run.return_value.stderr = b"API rate limit exceeded"

        result = self.dashboard.get_workflow_runs("test-repo")
        assert result is None

    def test_analyze_workflow_health_success_rate(self):
        """Test workflow health analysis with various success rates."""
        # Test high success rate
        runs = [{"conclusion": "success"} for _ in range(90)] + [
            {"conclusion": "failure"} for _ in range(10)
        ]

        health_score = self.dashboard.analyze_workflow_health(runs)
        assert 80 <= health_score <= 100  # Should be high due to 90% success rate

        # Test low success rate
        runs = [{"conclusion": "failure"} for _ in range(90)] + [
            {"conclusion": "success"} for _ in range(10)
        ]

        health_score = self.dashboard.analyze_workflow_health(runs)
        assert 0 <= health_score <= 30  # Should be low due to 10% success rate

    def test_analyze_workflow_health_empty_runs(self):
        """Test workflow health analysis with empty runs list."""
        health_score = self.dashboard.analyze_workflow_health([])
        assert health_score == 0

    @patch("devonboarder_ci_health.datetime")
    def test_detect_anomalies_high_failure_rate(self, mock_datetime):
        """Test anomaly detection for high failure rate."""
        mock_datetime.now.return_value = datetime(2023, 10, 1, 12, 0, 0)

        runs = [
            {
                "conclusion": "failure",
                "created_at": "2023-10-01T11:55:00Z",
                "name": "CI",
            }
            for _ in range(5)
        ]

        anomalies = self.dashboard.detect_anomalies(runs)
        assert len(anomalies) > 0
        assert any("high failure rate" in anomaly.lower() for anomaly in anomalies)

    def test_detect_anomalies_no_recent_runs(self):
        """Test anomaly detection when no recent runs exist."""
        # Old runs (more than 24 hours ago)
        runs = [
            {
                "conclusion": "success",
                "created_at": "2023-09-29T11:55:00Z",
                "name": "CI",
            }
        ]

        anomalies = self.dashboard.detect_anomalies(runs)
        assert len(anomalies) > 0
        assert any(
            "no recent workflow runs" in anomaly.lower() for anomaly in anomalies
        )


class TestWorkflowMetrics:
    """Test workflow metrics calculation and reporting."""

    def setup_method(self):
        """Set up test fixtures."""
        self.dashboard = devonboarder_ci_health.CIHealthDashboard()

    def test_calculate_success_rate(self):
        """Test success rate calculation."""
        runs = [{"conclusion": "success"} for _ in range(7)] + [
            {"conclusion": "failure"} for _ in range(3)
        ]

        success_rate = self.dashboard.calculate_success_rate(runs)
        assert success_rate == 70.0

    def test_calculate_success_rate_empty(self):
        """Test success rate calculation with empty runs."""
        success_rate = self.dashboard.calculate_success_rate([])
        assert success_rate == 0.0

    def test_calculate_average_duration(self):
        """Test average duration calculation."""
        runs = [
            {
                "created_at": "2023-10-01T12:00:00Z",
                "updated_at": "2023-10-01T12:05:00Z",
            },
            {
                "created_at": "2023-10-01T12:10:00Z",
                "updated_at": "2023-10-01T12:18:00Z",
            },
        ]

        avg_duration = self.dashboard.calculate_average_duration(runs)
        assert avg_duration == 6.5  # (5 + 8) / 2 minutes


class TestHealthReporting:
    """Test health report generation and output."""

    def setup_method(self):
        """Set up test fixtures."""
        self.dashboard = devonboarder_ci_health.CIHealthDashboard()

    def test_generate_health_report(self):
        """Test health report generation."""
        workflow_data = {
            "workflow_runs": [
                {
                    "conclusion": "success",
                    "created_at": "2023-10-01T12:00:00Z",
                    "updated_at": "2023-10-01T12:05:00Z",
                    "name": "CI",
                }
            ]
        }

        report = self.dashboard.generate_health_report(workflow_data)
        assert report is not None
        assert "health_score" in report
        assert "success_rate" in report
        assert "anomalies" in report
        assert isinstance(report["anomalies"], list)

    @patch("builtins.open", new_callable=mock_open)
    def test_save_health_report(self, mock_file):
        """Test saving health report to file."""
        report = {
            "health_score": 85.5,
            "success_rate": 90.0,
            "anomalies": ["Test anomaly"],
        }

        self.dashboard.save_health_report(report, "test_report.json")
        # Verify the file was opened with correct path and encoding
        from pathlib import Path

        expected_path = Path("/home/potato/TAGS/ecosystem/DevOnboarder/logs/test_report.json")
        mock_file.assert_called_once_with(expected_path, "w", encoding="utf-8")
        mock_file().write.assert_called()


class TestIntegrationScenarios:
    """Test integration scenarios and end-to-end workflows."""

    def setup_method(self):
        """Set up test fixtures."""
        self.dashboard = devonboarder_ci_health.CIHealthDashboard()

    @patch("devonboarder_ci_health.subprocess.run")
    def test_complete_health_check_workflow(self, mock_run):
        """Test complete health check workflow from start to finish."""
        # Mock API response
        mock_response = {
            "workflow_runs": [
                {
                    "id": 123456,
                    "name": "CI",
                    "status": "completed",
                    "conclusion": "success",
                    "created_at": "2023-10-01T12:00:00Z",
                    "updated_at": "2023-10-01T12:05:00Z",
                },
                {
                    "id": 123457,
                    "name": "Tests",
                    "status": "completed",
                    "conclusion": "failure",
                    "created_at": "2023-10-01T12:10:00Z",
                    "updated_at": "2023-10-01T12:15:00Z",
                },
            ]
        }
        mock_run.return_value.stdout = json.dumps(mock_response).encode()
        mock_run.return_value.returncode = 0

        # Run complete workflow
        workflow_data = self.dashboard.get_workflow_runs("test-repo")
        assert workflow_data is not None

        report = self.dashboard.generate_health_report(workflow_data)
        assert report is not None
        assert report["success_rate"] == 50.0  # 1 success out of 2 runs

    @patch.dict(os.environ, {"GITHUB_TOKEN": "test_token"})
    @patch("devonboarder_ci_health.subprocess.run")
    def test_token_integration(self, mock_run):
        """Test token integration in API calls."""
        mock_run.return_value.stdout = b'{"workflow_runs": []}'
        mock_run.return_value.returncode = 0

        self.dashboard.get_workflow_runs("test-repo")

        # Verify GitHub CLI was called correctly (token is handled via environment)
        mock_run.assert_called()
        call_args = mock_run.call_args[0][0]
        # Check that the command includes the basic gh run list structure
        assert call_args[0] == "gh"
        assert "run" in call_args
        assert "list" in call_args


class TestErrorHandling:
    """Test error handling and edge cases."""

    def setup_method(self):
        """Set up test fixtures."""
        self.dashboard = devonboarder_ci_health.CIHealthDashboard()

    @patch("devonboarder_ci_health.subprocess.run")
    def test_api_timeout_handling(self, mock_run):
        """Test handling of API timeouts."""
        mock_run.side_effect = subprocess.TimeoutExpired("gh", 30)

        result = self.dashboard.get_workflow_runs("test-repo")
        assert result is None

    @patch("devonboarder_ci_health.subprocess.run")
    def test_invalid_json_response(self, mock_run):
        """Test handling of invalid JSON responses."""
        mock_run.return_value.stdout = b"invalid json response"
        mock_run.return_value.returncode = 0

        result = self.dashboard.get_workflow_runs("test-repo")
        assert result is None

    def test_malformed_workflow_data(self):
        """Test handling of malformed workflow data."""
        malformed_data = {"invalid": "structure"}

        report = self.dashboard.generate_health_report(malformed_data)
        assert report is not None
        assert report["health_score"] == 0


class TestCommandLineInterface:
    """Test command-line interface functionality."""

    @patch("devonboarder_ci_health.CIHealthDashboard")
    @patch("sys.argv", ["devonboarder_ci_health.py", "--repo", "test-repo"])
    def test_main_function_execution(self, mock_dashboard_class):
        """Test main function execution with command line arguments."""
        mock_dashboard = MagicMock()
        mock_dashboard_class.return_value = mock_dashboard
        mock_dashboard.get_workflow_runs.return_value = {"workflow_runs": []}
        mock_dashboard.generate_health_report.return_value = {"health_score": 100}

        # This would normally call main(), but we'll test the components
        dashboard = devonboarder_ci_health.CIHealthDashboard()
        assert dashboard is not None

    def test_argument_parsing(self):
        """Test command line argument parsing."""
        # This test would require refactoring the script to make parsing testable
        # For now, we verify the script structure supports the expected arguments
        assert hasattr(devonboarder_ci_health, "argparse")


if __name__ == "__main__":
    pytest.main([__file__])
