#!/usr/bin/env python3
"""
CI Health Monitor v1.0
Part of DevOnboarder Phase 4: CI Triage Guard Enhancement

Real-time CI pipeline health monitoring with predictive analytics.
Integrates with Enhanced Potato Policy v2.0 and                message = (
                    f"CI success rate ({success_rate:.1%}) below "
                    f"threshold "
                    f"({self.metrics_config['success_rate_threshold']:.1%})"
                )Hub Actions.
"""

import json
import os
import sys
import time
from datetime import datetime, timedelta
from pathlib import Path
from typing import Dict, List, Any, Optional
import argparse
import subprocess  # nosec B404 - Controlled subprocess usage for GitHub CLI
import statistics


class CIHealthMonitor:
    """Real-time CI health monitoring with predictive analytics."""

    def __init__(self, venv_path: Optional[str] = None):
        """Initialize monitor with virtual environment validation."""
        self.venv_path = venv_path or os.environ.get("VIRTUAL_ENV")
        self.validate_virtual_environment()

        # Health metrics configuration
        self.metrics_config = {
            "success_rate_threshold": 0.85,  # 85% success rate minimum
            "avg_duration_threshold": 1800,  # 30 minutes maximum
            "failure_trend_threshold": 0.15,  # 15% increase in failures
            "resource_usage_threshold": 0.80,  # 80% resource usage
            "alert_cooldown": 3600,  # 1 hour cooldown between alerts
        }

        # Health indicators
        self.health_indicators = {
            "success_rate": "CI job success percentage",
            "avg_duration": "Average CI job duration",
            "failure_trend": "Recent failure rate trend",
            "resource_usage": "CI resource utilization",
            "queue_time": "Time jobs spend in queue",
            "flaky_test_rate": "Rate of intermittent test failures",
        }

    def validate_virtual_environment(self) -> None:
        """Validate virtual environment compliance per DevOnboarder."""
        if not self.venv_path:
            print("❌ Virtual environment not detected")
            print("💡 DevOnboarder requires virtual environment isolation")
            print("🔧 Run: python -m venv .venv && source .venv/bin/activate")
            sys.exit(1)

        venv_python = Path(self.venv_path) / "bin" / "python"
        if not venv_python.exists():
            print(f"❌ Virtual environment invalid: {self.venv_path}")
            sys.exit(1)

        print(f"✅ Virtual environment validated: {self.venv_path}")

    def collect_ci_metrics(self, days_back: int = 7) -> Dict[str, Any]:
        """Collect CI metrics from GitHub Actions."""
        end_date = datetime.now()
        start_date = end_date - timedelta(days=days_back)

        metrics = {
            "collection_time": end_date.isoformat(),
            "period_days": days_back,
            "start_date": start_date.isoformat(),
            "end_date": end_date.isoformat(),
            "workflow_runs": [],
            "summary_stats": {},
            "health_score": 0.0,
            "alerts": [],
        }

        try:
            # Use GitHub CLI to fetch workflow runs
            cmd = [
                "gh",
                "run",
                "list",
                "--limit",
                "100",
                "--json",
                "status,conclusion,createdAt,updatedAt,"
                "workflowName,displayTitle,url,id",
            ]

            result = subprocess.run(  # nosec B603 - Trusted GitHub CLI
                cmd, capture_output=True, text=True, check=True
            )

            runs_data = json.loads(result.stdout)

            # Filter runs within date range
            filtered_runs = []
            for run in runs_data:
                created_at = datetime.fromisoformat(
                    run["createdAt"].replace("Z", "+00:00")
                )
                if start_date <= created_at <= end_date:
                    filtered_runs.append(run)

            metrics["workflow_runs"] = filtered_runs
            metrics["summary_stats"] = self._calculate_summary_stats(filtered_runs)
            summary_stats = metrics["summary_stats"]
            if isinstance(summary_stats, dict):
                metrics["health_score"] = self._calculate_health_score(summary_stats)
                metrics["alerts"] = self._generate_health_alerts(summary_stats)

        except subprocess.CalledProcessError as e:
            print(f"⚠️  GitHub CLI error: {e}")
            print("💡 Ensure 'gh' is authenticated and available")
            metrics["error"] = str(e)
        except (json.JSONDecodeError, OSError) as e:
            print(f"❌ Error collecting CI metrics: {e}")
            metrics["error"] = str(e)

        return metrics

    def _calculate_summary_stats(self, runs: List[Dict[str, Any]]) -> Dict[str, Any]:
        """Calculate summary statistics from workflow runs."""
        if not runs:
            return {"total_runs": 0, "message": "No runs in period"}

        total_runs = len(runs)
        successful_runs = len([r for r in runs if r["conclusion"] == "success"])
        failed_runs = len([r for r in runs if r["conclusion"] == "failure"])
        cancelled_runs = len([r for r in runs if r["conclusion"] == "cancelled"])

        success_rate = successful_runs / total_runs if total_runs > 0 else 0
        failure_rate = failed_runs / total_runs if total_runs > 0 else 0

        # Calculate durations for completed runs
        durations = []
        for run in runs:
            if run.get("updatedAt") and run.get("createdAt"):
                try:
                    created = datetime.fromisoformat(
                        run["createdAt"].replace("Z", "+00:00")
                    )
                    updated = datetime.fromisoformat(
                        run["updatedAt"].replace("Z", "+00:00")
                    )
                    duration = (updated - created).total_seconds()
                    durations.append(duration)
                except (ValueError, KeyError):
                    # Skip runs with invalid timestamps
                    pass

        avg_duration = statistics.mean(durations) if durations else 0
        median_duration = statistics.median(durations) if durations else 0

        return {
            "total_runs": total_runs,
            "successful_runs": successful_runs,
            "failed_runs": failed_runs,
            "cancelled_runs": cancelled_runs,
            "success_rate": success_rate,
            "failure_rate": failure_rate,
            "avg_duration_seconds": avg_duration,
            "median_duration_seconds": median_duration,
            "min_duration_seconds": min(durations) if durations else 0,
            "max_duration_seconds": max(durations) if durations else 0,
        }

    def _calculate_health_score(self, stats: Dict[str, Any]) -> float:
        """Calculate overall CI health score (0-100)."""
        if not stats or stats.get("total_runs", 0) == 0:
            return 0.0

        # Weighted health score calculation
        success_weight = 0.4
        duration_weight = 0.3
        reliability_weight = 0.3

        # Success rate component (0-40 points)
        success_score = stats.get("success_rate", 0) * success_weight * 100

        # Duration component (0-30 points)
        avg_duration = stats.get("avg_duration_seconds", 0)
        duration_score = max(
            0, (1 - min(1, avg_duration / 3600)) * duration_weight * 100
        )

        # Reliability component (0-30 points)
        total_runs = stats.get("total_runs", 1)
        cancelled_rate = stats.get("cancelled_runs", 0) / total_runs
        reliability_score = max(0, (1 - cancelled_rate) * reliability_weight * 100)

        total_score = success_score + duration_score + reliability_score
        return round(total_score, 1)

    def _generate_health_alerts(self, stats: Dict[str, Any]) -> List[Dict[str, Any]]:
        """Generate health alerts based on thresholds."""
        alerts: List[Dict[str, Any]] = []

        if not stats or stats.get("total_runs", 0) == 0:
            return alerts

        # Success rate alert
        success_rate = stats.get("success_rate", 0)
        if success_rate < self.metrics_config["success_rate_threshold"]:
            alerts.append(
                {
                    "type": "success_rate_low",
                    "severity": "high",
                    "message": (
                        f"CI success rate ({success_rate:.1%}) below "
                        f"threshold "
                        f"({self.metrics_config['success_rate_threshold']:.1%})"
                    ),
                    "metric": "success_rate",
                    "current_value": success_rate,
                    "threshold": self.metrics_config["success_rate_threshold"],
                }
            )

        # Duration alert
        avg_duration = stats.get("avg_duration_seconds", 0)
        if avg_duration > self.metrics_config["avg_duration_threshold"]:
            alerts.append(
                {
                    "type": "duration_high",
                    "severity": "medium",
                    "message": (
                        f"Average CI duration ({avg_duration / 60:.1f} min) exceeds "
                        f"threshold "
                        f"({self.metrics_config['avg_duration_threshold'] / 60:.1f} "
                        f"min)"
                    ),
                    "metric": "avg_duration",
                    "current_value": avg_duration,
                    "threshold": self.metrics_config["avg_duration_threshold"],
                }
            )

        # High failure rate alert
        failure_rate = stats.get("failure_rate", 0)
        if failure_rate > 0.2:  # 20% failure rate
            alerts.append(
                {
                    "type": "failure_rate_high",
                    "severity": "high",
                    "message": (f"CI failure rate ({failure_rate:.1%}) is elevated"),
                    "metric": "failure_rate",
                    "current_value": failure_rate,
                    "threshold": 0.2,
                }
            )

        return alerts

    def generate_health_report(self, metrics: Dict[str, Any], output_path: str) -> None:
        """Generate comprehensive CI health report."""
        report = {
            "ci_health_report": {
                "version": "1.0",
                "framework": "Phase 4: CI Triage Guard Enhancement",
                "virtual_env": self.venv_path,
                "metrics": metrics,
                "recommendations": self._generate_recommendations(metrics),
                "next_monitoring": (datetime.now() + timedelta(hours=6)).isoformat(),
            }
        }

        with open(output_path, "w", encoding="utf-8") as f:
            json.dump(report, f, indent=2, ensure_ascii=False)

        print(f"📊 Health report saved: {output_path}")

    def _generate_recommendations(
        self, metrics: Dict[str, Any]
    ) -> List[Dict[str, str]]:
        """Generate actionable recommendations based on metrics."""
        recommendations: List[Dict[str, str]] = []
        stats = metrics.get("summary_stats", {})
        alerts = metrics.get("alerts", [])

        if not stats:
            return recommendations

        # Recommendations based on alerts
        for alert in alerts:
            if alert["type"] == "success_rate_low":
                recommendations.append(
                    {
                        "priority": "high",
                        "category": "reliability",
                        "action": "Investigate and fix failing tests",
                        "description": (
                            "Low success rate indicates systematic issues. "
                            "Review recent failures and implement fixes."
                        ),
                    }
                )
            elif alert["type"] == "duration_high":
                recommendations.append(
                    {
                        "priority": "medium",
                        "category": "performance",
                        "action": "Optimize CI pipeline performance",
                        "description": (
                            "Long CI durations slow development. "
                            "Consider parallelization and caching improvements."
                        ),
                    }
                )

        # General recommendations
        health_score = metrics.get("health_score", 0)
        if health_score < 80:
            recommendations.append(
                {
                    "priority": "medium",
                    "category": "overall",
                    "action": "Implement CI health monitoring alerts",
                    "description": (
                        "CI health score is below optimal. "
                        "Set up proactive monitoring and alerting."
                    ),
                }
            )

        return recommendations

    def monitor_continuously(
        self, interval_hours: int = 6, max_iterations: int = 0
    ) -> None:
        """Run continuous CI health monitoring."""
        print(
            f"🔄 Starting continuous CI health monitoring (interval: {interval_hours}h)"
        )

        iteration = 0
        while max_iterations == 0 or iteration < max_iterations:
            try:
                print(
                    f"\n⏰ Health check #{iteration + 1} "
                    f"at {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}"
                )

                metrics = self.collect_ci_metrics()
                health_score = metrics.get("health_score", 0)
                alerts = metrics.get("alerts", [])

                print(f"🏥 CI Health Score: {health_score}/100")

                if alerts:
                    print(f"🚨 Active Alerts: {len(alerts)}")
                    for alert in alerts[:3]:  # Show top 3 alerts
                        print(f"   • {alert['message']}")
                else:
                    print("✅ No active alerts")

                # Save monitoring report
                timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
                report_path = f"logs/ci_health_{timestamp}.json"
                self.generate_health_report(metrics, report_path)

                iteration += 1

                if max_iterations == 0 or iteration < max_iterations:
                    print(f"⏳ Next check in {interval_hours} hours...")
                    time.sleep(interval_hours * 3600)

            except KeyboardInterrupt:
                print("\n🛑 Monitoring stopped by user")
                break
            except (subprocess.CalledProcessError, FileNotFoundError) as e:
                print(f"❌ Monitoring error: {e}")
                print("🔄 Continuing monitoring...")
                time.sleep(300)  # Wait 5 minutes before retry


def main():
    """Main execution function with virtual environment compliance."""
    parser = argparse.ArgumentParser(
        description="CI Health Monitor - Phase 4: CI Triage Guard"
    )
    parser.add_argument(
        "--days-back",
        type=int,
        default=7,
        help="Days of CI history to analyze (default: 7)",
    )
    parser.add_argument(
        "--output",
        default="ci_health_report.json",
        help="Output file for health report",
    )
    parser.add_argument(
        "--continuous", action="store_true", help="Run continuous monitoring"
    )
    parser.add_argument(
        "--interval",
        type=int,
        default=6,
        help="Monitoring interval in hours (default: 6)",
    )
    parser.add_argument(
        "--max-iterations",
        type=int,
        default=0,
        help="Maximum monitoring iterations (0 = infinite)",
    )

    args = parser.parse_args()

    # Initialize monitor with virtual environment validation
    monitor = CIHealthMonitor()

    if args.continuous:
        monitor.monitor_continuously(args.interval, args.max_iterations)
    else:
        print(f"🔍 Collecting CI metrics for last {args.days_back} days...")
        metrics = monitor.collect_ci_metrics(args.days_back)

        # Display summary
        stats = metrics.get("summary_stats", {})
        if stats:
            print("\n📊 CI Health Summary:")
            print(f"   Total runs: {stats.get('total_runs', 0)}")
            print(f"   Success rate: {stats.get('success_rate', 0):.1%}")
            print(
                f"   Average duration: "
                f"{stats.get('avg_duration_seconds', 0) / 60:.1f} minutes"
            )
            print(f"   Health score: {metrics.get('health_score', 0)}/100")

        alerts = metrics.get("alerts", [])
        if alerts:
            print(f"\n🚨 Active Alerts ({len(alerts)}):")
            for alert in alerts:
                print(f"   • [{alert['severity'].upper()}] {alert['message']}")
        else:
            print("\n✅ No active health alerts")

        # Generate report
        monitor.generate_health_report(metrics, args.output)

        print("\n✅ CI health monitoring complete")


if __name__ == "__main__":
    main()
