#!/usr/bin/env python3
"""
Predictive Analytics Module v1.0
Part of DevOnboarder Phase 5: Advanced Orchestration

ML-based failure prediction, performance trend analysis, and capacity planning
for the DevOnboarder ecosystem. Integrates with CI Triage Guard (Phase 4).
"""

import json
import logging
import os
from datetime import datetime, timedelta
from pathlib import Path
from typing import Dict, List, Optional
import numpy as np
import pandas as pd
from dataclasses import dataclass
from sklearn.ensemble import RandomForestClassifier, GradientBoostingRegressor
from sklearn.preprocessing import StandardScaler
from sklearn.model_selection import train_test_split
from sklearn.metrics import accuracy_score, mean_squared_error


@dataclass
class PredictionResult:
    """Result from predictive analytics."""

    prediction: float
    confidence: float
    factors: Dict[str, float]
    recommendation: str
    timestamp: datetime


class PredictiveAnalytics:
    """
    Advanced predictive analytics for DevOnboarder ecosystem.

    Provides ML-based failure prediction, performance forecasting,
    and intelligent capacity planning recommendations.
    """

    def __init__(self, venv_path: Optional[str] = None):
        """Initialize predictive analytics with virtual environment validation."""
        self.venv_path = venv_path or os.environ.get("VIRTUAL_ENV")
        self.validate_virtual_environment()

        # ML Models
        self.failure_predictor: Optional[RandomForestClassifier] = None
        self.performance_forecaster: Optional[GradientBoostingRegressor] = None
        self.scaler = StandardScaler()

        # Data storage
        self.historical_data: List[Dict] = []
        self.feature_columns = [
            "cpu_usage",
            "memory_usage",
            "response_time",
            "error_rate",
            "request_count",
            "disk_usage",
            "network_latency",
            "hour_of_day",
            "day_of_week",
            "recent_deployments",
            "test_failures",
        ]

        # Setup
        self.setup_logging()
        self.load_historical_data()
        self.train_models()

    def validate_virtual_environment(self) -> None:
        """Validate virtual environment compliance per DevOnboarder."""
        if not self.venv_path:
            raise EnvironmentError(
                "FAILED Virtual environment not detected. "
                "DevOnboarder Phase 5 requires virtual environment isolation."
            )
        print(f"SUCCESS Predictive Analytics virtual environment: {self.venv_path}")

    def setup_logging(self) -> None:
        """Configure logging for analytics events."""
        log_dir = Path("logs")
        log_dir.mkdir(exist_ok=True)

        logging.basicConfig(
            level=logging.INFO,
            format="%(asctime)s - %(name)s - %(levelname)s - %(message)s",
            handlers=[
                logging.FileHandler(log_dir / "predictive_analytics.log"),
                logging.StreamHandler(),
            ],
        )
        self.logger = logging.getLogger("PredictiveAnalytics")

    def load_historical_data(self) -> None:
        """Load historical data for model training."""
        # Load from Phase 4 CI analysis reports
        data_sources = [
            "ci_failure_analysis.json",
            "phase4_analysis_report.json",
            "github_cli_analysis.json",
            "precommit_analysis_v2.json",
        ]

        for source in data_sources:
            if Path(source).exists():
                try:
                    with open(source, "r") as f:
                        data = json.load(f)
                        self.process_ci_data(data)
                except Exception as e:
                    self.logger.warning(f"Failed to load {source}: {e}")

        # Generate synthetic data for demo (would use real data in production)
        self.generate_synthetic_training_data()

        self.logger.info(f"Loaded {len(self.historical_data)} historical records")

    def process_ci_data(self, data: Dict) -> None:
        """Process CI failure analysis data for training."""
        if "enhanced_ci_analysis" in data:
            analysis = data["enhanced_ci_analysis"]["analysis"]

            # Extract features from CI analysis
            record = {
                "timestamp": analysis.get("timestamp", datetime.now().isoformat()),
                "failure_occurred": len(analysis.get("detected_failures", [])) > 0,
                "confidence_score": analysis.get("confidence_score", 0.0),
                "auto_fixable": analysis.get("auto_fixable", False),
                "log_size": analysis.get("log_size", 0),
                "failure_count": len(analysis.get("detected_failures", [])),
            }

            self.historical_data.append(record)

    def generate_synthetic_training_data(self) -> None:
        """Generate synthetic data for model training demonstration."""
        np.random.seed(42)  # For reproducible results

        # Generate 1000 synthetic records
        for i in range(1000):
            base_time = datetime.now() - timedelta(days=np.random.randint(1, 365))

            # Simulate realistic patterns
            hour = base_time.hour
            day_of_week = base_time.weekday()

            # Higher failure rates during peak hours and after deployments
            failure_prob = 0.1
            if 9 <= hour <= 17:  # Business hours
                failure_prob += 0.05
            if day_of_week in [0, 6]:  # Monday/Sunday deployments
                failure_prob += 0.03

            cpu_usage = np.random.normal(45, 15)
            memory_usage = np.random.normal(60, 20)
            response_time = np.random.lognormal(0, 0.5)

            # Correlate metrics with failure probability
            if cpu_usage > 70 or memory_usage > 80 or response_time > 2:
                failure_prob += 0.2

            record = {
                "timestamp": base_time.isoformat(),
                "cpu_usage": max(0, min(100, cpu_usage)),
                "memory_usage": max(0, min(100, memory_usage)),
                "response_time": max(0.1, response_time),
                "error_rate": np.random.exponential(0.02),
                "request_count": np.random.poisson(1000),
                "disk_usage": np.random.normal(40, 10),
                "network_latency": np.random.exponential(20),
                "hour_of_day": hour,
                "day_of_week": day_of_week,
                "recent_deployments": np.random.poisson(0.3),
                "test_failures": np.random.poisson(0.5),
                "failure_occurred": np.random.random() < failure_prob,
                "performance_score": np.random.normal(85, 10),
            }

            self.historical_data.append(record)

    def prepare_features(self, data: List[Dict]) -> pd.DataFrame:
        """Prepare feature matrix for ML models."""
        df = pd.DataFrame(data)

        # Ensure all feature columns exist
        for col in self.feature_columns:
            if col not in df.columns:
                df[col] = 0

        # Feature engineering
        df["cpu_memory_ratio"] = df["cpu_usage"] / (df["memory_usage"] + 1)
        df["response_error_ratio"] = df["response_time"] * df["error_rate"]
        df["load_factor"] = df["request_count"] / 1000

        # Time-based features
        if "timestamp" in df.columns:
            df["timestamp"] = pd.to_datetime(df["timestamp"])
            df["hour_sin"] = np.sin(2 * np.pi * df["hour_of_day"] / 24)
            df["hour_cos"] = np.cos(2 * np.pi * df["hour_of_day"] / 24)
            df["day_sin"] = np.sin(2 * np.pi * df["day_of_week"] / 7)
            df["day_cos"] = np.cos(2 * np.pi * df["day_of_week"] / 7)

        return df

    def train_models(self) -> None:
        """Train ML models on historical data."""
        if len(self.historical_data) < 10:
            self.logger.warning("Insufficient data for model training")
            return

        df = self.prepare_features(self.historical_data)

        # Prepare failure prediction model
        if "failure_occurred" in df.columns:
            self.train_failure_predictor(df)

        # Prepare performance forecasting model
        if "performance_score" in df.columns:
            self.train_performance_forecaster(df)

        self.logger.info("ML models trained successfully")

    def train_failure_predictor(self, df: pd.DataFrame) -> None:
        """Train failure prediction model."""
        feature_cols = [col for col in self.feature_columns if col in df.columns]
        feature_cols.extend(["cpu_memory_ratio", "response_error_ratio", "load_factor"])

        X = df[feature_cols].fillna(0)
        y = df["failure_occurred"].astype(int)

        if len(X) < 10:
            return

        X_train, X_test, y_train, y_test = train_test_split(
            X, y, test_size=0.2, random_state=42
        )

        # Scale features
        X_train_scaled = self.scaler.fit_transform(X_train)
        X_test_scaled = self.scaler.transform(X_test)

        # Train Random Forest
        self.failure_predictor = RandomForestClassifier(
            n_estimators=100, max_depth=10, random_state=42
        )
        self.failure_predictor.fit(X_train_scaled, y_train)

        # Evaluate
        y_pred = self.failure_predictor.predict(X_test_scaled)
        accuracy = accuracy_score(y_test, y_pred)

        self.logger.info(f"Failure predictor accuracy: {accuracy:.3f}")

    def train_performance_forecaster(self, df: pd.DataFrame) -> None:
        """Train performance forecasting model."""
        feature_cols = [col for col in self.feature_columns if col in df.columns]

        X = df[feature_cols].fillna(0)
        y = df["performance_score"].fillna(85)

        if len(X) < 10:
            return

        X_train, X_test, y_train, y_test = train_test_split(
            X, y, test_size=0.2, random_state=42
        )

        # Train Gradient Boosting
        self.performance_forecaster = GradientBoostingRegressor(
            n_estimators=100, learning_rate=0.1, random_state=42
        )
        self.performance_forecaster.fit(X_train, y_train)

        # Evaluate
        y_pred = self.performance_forecaster.predict(X_test)
        mse = mean_squared_error(y_test, y_pred)

        self.logger.info(f"Performance forecaster MSE: {mse:.3f}")

    def predict_failure_risk(self, current_metrics: Dict) -> PredictionResult:
        """Predict failure risk based on current system metrics."""
        if not self.failure_predictor:
            return PredictionResult(
                prediction=0.0,
                confidence=0.0,
                factors={},
                recommendation="Model not trained",
                timestamp=datetime.now(),
            )

        # Prepare feature vector
        features = {}
        for col in self.feature_columns:
            features[col] = current_metrics.get(col, 0)

        # Add engineered features
        features["cpu_memory_ratio"] = features["cpu_usage"] / (
            features["memory_usage"] + 1
        )
        features["response_error_ratio"] = (
            features["response_time"] * features["error_rate"]
        )
        features["load_factor"] = features["request_count"] / 1000

        feature_vector = [
            features[col]
            for col in self.feature_columns
            + ["cpu_memory_ratio", "response_error_ratio", "load_factor"]
        ]
        feature_vector = np.array(feature_vector).reshape(1, -1)
        feature_vector = self.scaler.transform(feature_vector)

        # Predict
        prediction_prob = self.failure_predictor.predict_proba(feature_vector)[0][
            1
        ]  # Feature importance
        feature_names = self.feature_columns + [
            "cpu_memory_ratio",
            "response_error_ratio",
            "load_factor",
        ]
        importance = dict(
            zip(feature_names, self.failure_predictor.feature_importances_)
        )

        # Generate recommendation
        recommendation = self.generate_failure_recommendation(prediction_prob, features)

        return PredictionResult(
            prediction=float(prediction_prob),
            confidence=max(prediction_prob, 1 - prediction_prob),
            factors=importance,
            recommendation=recommendation,
            timestamp=datetime.now(),
        )

    def forecast_performance(
        self, current_metrics: Dict, hours_ahead: int = 24
    ) -> PredictionResult:
        """Forecast system performance trends."""
        if not self.performance_forecaster:
            return PredictionResult(
                prediction=85.0,
                confidence=0.0,
                factors={},
                recommendation="Model not trained",
                timestamp=datetime.now(),
            )

        # Prepare feature vector (simplified for demo)
        features = [current_metrics.get(col, 0) for col in self.feature_columns]
        feature_vector = np.array(features).reshape(1, -1)

        # Predict
        performance_score = self.performance_forecaster.predict(feature_vector)[0]

        # Generate recommendation
        recommendation = self.generate_performance_recommendation(performance_score)

        return PredictionResult(
            prediction=float(performance_score),
            confidence=0.8,  # Simplified confidence
            factors={
                col: current_metrics.get(col, 0) for col in self.feature_columns[:5]
            },
            recommendation=recommendation,
            timestamp=datetime.now(),
        )

    def generate_failure_recommendation(self, risk_score: float, metrics: Dict) -> str:
        """Generate actionable recommendation based on failure risk."""
        if risk_score < 0.2:
            return "SUCCESS System healthy - continue monitoring"
        elif risk_score < 0.5:
            return "WARNING Elevated risk - consider scaling resources"
        elif risk_score < 0.8:
            return "SYMBOL High risk - immediate attention required"
        else:
            return "FAILED Critical risk - activate incident response"

    def generate_performance_recommendation(self, score: float) -> str:
        """Generate performance optimization recommendation."""
        if score >= 90:
            return "SUCCESS Excellent performance - maintain current configuration"
        elif score >= 80:
            return "SYMBOL Good performance - minor optimizations available"
        elif score >= 70:
            return "WARNING Fair performance - consider resource optimization"
        else:
            return "SYMBOL Poor performance - immediate optimization required"

    def save_prediction_report(
        self, predictions: List[PredictionResult], output_path: str
    ) -> None:
        """Save prediction analysis report."""
        report = {
            "predictive_analysis": {
                "version": "1.0",
                "framework": "Phase 5: Advanced Orchestration - Predictive Analytics",
                "virtual_env": self.venv_path,
                "timestamp": datetime.now().isoformat(),
                "predictions": [
                    {
                        "prediction": p.prediction,
                        "confidence": p.confidence,
                        "factors": p.factors,
                        "recommendation": p.recommendation,
                        "timestamp": p.timestamp.isoformat(),
                    }
                    for p in predictions
                ],
            }
        }

        with open(output_path, "w", encoding="utf-8") as f:
            json.dump(report, f, indent=2, ensure_ascii=False)

        self.logger.info(f"STATS Prediction report saved: {output_path}")


# CLI Interface
def main():
    """Main predictive analytics execution."""
    analytics = PredictiveAnalytics()

    # Demo prediction
    current_metrics = {
        "cpu_usage": 75,
        "memory_usage": 68,
        "response_time": 1.2,
        "error_rate": 0.03,
        "request_count": 1500,
        "disk_usage": 45,
        "network_latency": 25,
        "hour_of_day": datetime.now().hour,
        "day_of_week": datetime.now().weekday(),
        "recent_deployments": 1,
        "test_failures": 2,
    }

    # Generate predictions
    failure_prediction = analytics.predict_failure_risk(current_metrics)
    performance_forecast = analytics.forecast_performance(current_metrics)

    print("SYMBOL DevOnboarder Predictive Analytics Results")
    print(f"   Failure Risk: {failure_prediction.prediction:.1%}")
    print(f"   Confidence: {failure_prediction.confidence:.1%}")
    print(f"   Recommendation: {failure_prediction.recommendation}")
    print(f"   Performance Forecast: {performance_forecast.prediction:.1f}/100")
    print(f"   Performance Recommendation: {performance_forecast.recommendation}")

    # Save report
    analytics.save_prediction_report(
        [failure_prediction, performance_forecast],
        "logs/predictive_analytics_report.json",
    )


if __name__ == "__main__":
    main()
