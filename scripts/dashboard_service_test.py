#!/usr/bin/env python3
"""Standalone Dashboard Service Test.

This script tests the dashboard service without complex imports.
"""

import logging
import os
from datetime import datetime
from pathlib import Path
from typing import Dict, List, Optional

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)


# Simple CORS configuration for testing
def get_cors_origins()  List[str]:
    """Get CORS origins for testing."""
    return ["http://localhost:8081", "http://localhost:3000", "http://127.0.0.1:8081"]


class ScriptInfo(BaseModel):
    """Information about a discovered script."""

    name: str
    path: str
    description: str
    category: str
    executable: bool
    last_modified: str
    size_bytes: int


class ExecutionRequest(BaseModel):
    """Request to execute a script."""

    script_path: str
    args: Optional[List[str]] = []
    background: bool = False


class ExecutionResult(BaseModel):
    """Result of script execution."""

    execution_id: str
    script_path: str
    status: str  # "running", "completed", "failed"
    exit_code: Optional[int] = None
    output: str = ""
    error: str = ""
    start_time: str
    end_time: Optional[str] = None
    duration_seconds: Optional[float] = None


class DashboardService:
    """Main dashboard service for script discovery and execution."""

    def __init__(self, base_dir: Optional[Path] = None):
        """Initialize the dashboard service."""
        self.base_dir = base_dir or Path("/home/potato/DevOnboarder")
        self.scripts_dir = self.base_dir / "scripts"
        self.logs_dir = self.base_dir / "logs"
        self.active_executions: Dict[str, ExecutionResult] = {}

        # Ensure logs directory exists
        self.logs_dir.mkdir(exist_ok=True)

    def discover_scripts(self)  List[ScriptInfo]:
        """Discover all executable scripts in the scripts directory."""
        scripts: List[ScriptInfo] = []

        if not self.scripts_dir.exists():
            logger.warning(f"Scripts directory not found: {self.scripts_dir}")
            return scripts

        for script_path in self.scripts_dir.rglob("*"):
            if not script_path.is_file():
                continue

            # Skip hidden files and directories
            if any(part.startswith(".") for part in script_path.parts):
                continue

            # Check if file is executable or has known script extensions
            is_executable = os.access(script_path, os.X_OK)
            is_script = script_path.suffix in {".sh", ".py", ".js", ".ts"}

            if not (is_executable or is_script):
                continue

            # Extract description from script header
            description = self._extract_description(script_path)

            # Categorize script
            category = self._categorize_script(script_path)

            stat = script_path.stat()
            scripts.append(
                ScriptInfo(
                    name=script_path.name,
                    path=str(script_path.relative_to(self.base_dir)),
                    description=description,
                    category=category,
                    executable=is_executable,
                    last_modified=datetime.fromtimestamp(stat.st_mtime).isoformat(),
                    size_bytes=stat.st_size,
                )
            )

        return sorted(scripts, key=lambda s: (s.category, s.name))

    def _extract_description(self, script_path: Path)  str:
        """Extract description from script header comments."""
        try:
            with open(script_path, "r", encoding="utf-8") as f:
                lines = f.readlines()[:20]  # Check first 20 lines

            description_lines = []
            for line in lines:
                line = line.strip()
                if not line:
                    continue

                # Python docstring
                if line.startswith('"""') or line.startswith("'''"):
                    desc = line.strip('"""').strip("'''").strip()
                    if desc:
                        return desc

                # Shell/Python comments
                if line.startswith("#"):
                    comment = line[1:].strip()
                    if comment and not comment.startswith("!"):
                        description_lines.append(comment)
                        if len(description_lines) >= 3:
                            break

            return (
                " ".join(description_lines)
                if description_lines
                else "No description available"
            )

        except Exception as e:
            logger.warning(f"Failed to extract description from {script_path}: {e}")
            return "Description unavailable"

    def _categorize_script(self, script_path: Path)  str:
        """Categorize script based on path and name."""
        path_str = str(script_path).lower()
        name_str = script_path.name.lower()

        if "test" in name_str or "test" in path_str:
            return "testing"
        elif "ci" in name_str or "ci" in path_str:
            return "ci"
        elif "deploy" in name_str or "deploy" in path_str:
            return "deployment"
        elif "clean" in name_str or "lint" in name_str or "format" in name_str:
            return "maintenance"
        elif "setup" in name_str or "install" in name_str:
            return "setup"
        elif "monitor" in name_str or "health" in name_str:
            return "monitoring"
        elif "security" in name_str or "audit" in name_str:
            return "security"
        else:
            return "general"


def create_dashboard_app()  FastAPI:
    """Create the FastAPI dashboard application."""
    app = FastAPI(
        title="DevOnboarder Dashboard Service",
        description="CI Troubleshooting and Script Execution Dashboard",
        version="1.0.0",
    )

    # Configure CORS
    cors_origins = get_cors_origins()
    app.add_middleware(
        CORSMiddleware,
        allow_origins=cors_origins,
        allow_credentials=True,
        allow_methods=["*"],
        allow_headers=["*"],
    )

    # Global service instance
    dashboard_service = DashboardService()

    @app.get("/health")
    def health()  Dict[str, str]:
        """Health check endpoint."""
        return {"status": "ok"}

    @app.get("/api/scripts", response_model=List[ScriptInfo])
    def list_scripts()  List[ScriptInfo]:
        """List all discovered scripts."""
        return dashboard_service.discover_scripts()

    @app.get("/api/executions", response_model=List[ExecutionResult])
    def list_executions()  List[ExecutionResult]:
        """List all active executions."""
        return list(dashboard_service.active_executions.values())

    return app


if __name__ == "__main__":
    import uvicorn

    app = create_dashboard_app()
    print("Starting DevOnboarder Dashboard Service on http://127.0.0.1:8003")
    print("Available endpoints:")
    print("  - GET  /health")
    print("  - GET  /api/scripts")
    print("  - GET  /api/executions")

    uvicorn.run(app, host="127.0.0.1", port=8003)
