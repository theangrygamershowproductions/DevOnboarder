"""Dashboard Service for DevOnboarder CI Troubleshooting.

This service provides a web API for discovering and executing scripts,
monitoring CI health, and providing real-time feedback on automation tasks.
"""

import asyncio
import json
import logging
import os
import uuid
from datetime import datetime
from pathlib import Path
from typing import Dict, List, Optional

from fastapi import FastAPI, HTTPException, WebSocket, WebSocketDisconnect
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import RedirectResponse
from pydantic import BaseModel

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)


def get_cors_origins() -> List[str]:
    """Get CORS origins for the dashboard service."""
    return [
        "http://localhost:8081",
        "http://localhost:3000",
        "http://127.0.0.1:8081",
    ]


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
        """Initialize the dashboard service.

        Parameters
        ----------
        base_dir : Path, optional
            Base directory for script discovery. Defaults to project root.
        """
        if base_dir is not None:
            self.base_dir = base_dir
        else:
            env_base_dir = os.environ.get("DEVONBOARDER_BASE_DIR")
            if env_base_dir:
                self.base_dir = Path(env_base_dir)
            else:
                # Use current working directory or detect project root
                cwd = Path.cwd()
                if (cwd / "pyproject.toml").exists():
                    self.base_dir = cwd
                elif (cwd.parent / "pyproject.toml").exists():
                    self.base_dir = cwd.parent
                else:
                    # Search up the directory tree for project root
                    current = cwd
                    while current != current.parent:
                        if (current / "pyproject.toml").exists():
                            self.base_dir = current
                            break
                        current = current.parent
                    else:
                        # Fallback to current directory if no project root found
                        self.base_dir = cwd

        self.scripts_dir = self.base_dir / "scripts"
        self.logs_dir = self.base_dir / "logs"
        self.active_executions: Dict[str, ExecutionResult] = {}
        self.websocket_connections: List[WebSocket] = []

        # Ensure logs directory exists
        self.logs_dir.mkdir(parents=True, exist_ok=True)

    def discover_scripts(self) -> List[ScriptInfo]:
        """Discover all executable scripts in the scripts directory.

        Returns
        -------
        List[ScriptInfo]
            List of discovered scripts with metadata.
        """
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

    def _extract_description(self, script_path: Path) -> str:
        """Extract description from script header comments.

        Parameters
        ----------
        script_path : Path
            Path to the script file.

        Returns
        -------
        str
            Description extracted from script header.
        """
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

        except FileNotFoundError:
            logger.warning(f"Script file not found: {script_path}")
            return "Description unavailable (file not found)"
        except PermissionError:
            logger.warning(f"Permission denied when reading script: {script_path}")
            return "Description unavailable (permission denied)"
        except Exception as e:
            logger.warning(f"Failed to extract description from {script_path}: {e}")
            return "Description unavailable"

    def _categorize_script(self, script_path: Path) -> str:
        """Categorize script based on path and name.

        Parameters
        ----------
        script_path : Path
            Path to the script file.

        Returns
        -------
        str
            Category name.
        """
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

    async def execute_script(self, request: ExecutionRequest) -> ExecutionResult:
        """Execute a script with the given parameters.

        Parameters
        ----------
        request : ExecutionRequest
            Script execution request.

        Returns
        -------
        ExecutionResult
            Execution result with status and output.
        """
        execution_id = str(uuid.uuid4())
        script_path = self.base_dir / request.script_path

        if not script_path.exists():
            raise HTTPException(status_code=404, detail="Script not found")

        if not os.access(script_path, os.R_OK):
            raise HTTPException(status_code=403, detail="Script not readable")

        start_time = datetime.now()
        result = ExecutionResult(
            execution_id=execution_id,
            script_path=request.script_path,
            status="running",
            start_time=start_time.isoformat(),
            output="",
            error="",
        )

        self.active_executions[execution_id] = result

        try:
            # Prepare command
            if script_path.suffix == ".py":
                cmd = ["python", str(script_path)] + (request.args or [])
            elif script_path.suffix in {".sh", ".bash"}:
                cmd = ["bash", str(script_path)] + (request.args or [])
            else:
                cmd = [str(script_path)] + (request.args or [])

            # Create log file
            log_file = self.logs_dir / f"dashboard_execution_{execution_id}.log"

            # Execute script
            process = await asyncio.create_subprocess_exec(
                *cmd,
                stdout=asyncio.subprocess.PIPE,
                stderr=asyncio.subprocess.PIPE,
                cwd=str(self.base_dir),
            )

            if request.background:
                # For background execution, return immediately
                asyncio.create_task(
                    self._monitor_background_execution(process, result, log_file)
                )
                return result
            else:
                # Wait for completion
                stdout, stderr = await process.communicate()

                end_time = datetime.now()
                duration = (end_time - start_time).total_seconds()

                result.status = "completed" if process.returncode == 0 else "failed"
                result.exit_code = process.returncode
                result.output = stdout.decode("utf-8") if stdout else ""
                result.error = stderr.decode("utf-8") if stderr else ""
                result.end_time = end_time.isoformat()
                result.duration_seconds = duration

                # Write to log file
                with open(log_file, "w", encoding="utf-8") as f:
                    f.write(f"Execution ID: {execution_id}\n")
                    f.write(f"Script: {request.script_path}\n")
                    f.write(f"Args: {request.args}\n")
                    f.write(f"Start Time: {result.start_time}\n")
                    f.write(f"End Time: {result.end_time}\n")
                    f.write(f"Duration: {duration:.2f}s\n")
                    f.write(f"Exit Code: {process.returncode}\n")
                    f.write("\n--- STDOUT ---\n")
                    f.write(result.output)
                    f.write("\n--- STDERR ---\n")
                    f.write(result.error)

                # Notify WebSocket clients
                await self._broadcast_execution_update(result)

                return result

        except Exception as e:
            logger.error(f"Script execution failed: {e}")
            result.status = "failed"
            result.error = str(e)
            result.end_time = datetime.now().isoformat()
            await self._broadcast_execution_update(result)
            raise HTTPException(status_code=500, detail=f"Execution failed: {e}")

    async def _monitor_background_execution(
        self, process, result: ExecutionResult, log_file: Path
    ):
        """Monitor a background script execution.

        Parameters
        ----------
        process
            The subprocess to monitor.
        result : ExecutionResult
            The execution result to update.
        log_file : Path
            Path to the log file.
        """
        try:
            stdout, stderr = await process.communicate()

            end_time = datetime.now()
            start_time = datetime.fromisoformat(result.start_time)
            duration = (end_time - start_time).total_seconds()

            result.status = "completed" if process.returncode == 0 else "failed"
            result.exit_code = process.returncode
            result.output = stdout.decode("utf-8") if stdout else ""
            result.error = stderr.decode("utf-8") if stderr else ""
            result.end_time = end_time.isoformat()
            result.duration_seconds = duration

            # Write to log file
            with open(log_file, "w", encoding="utf-8") as f:
                f.write(f"Execution ID: {result.execution_id}\n")
                f.write(f"Script: {result.script_path}\n")
                f.write(f"Start Time: {result.start_time}\n")
                f.write(f"End Time: {result.end_time}\n")
                f.write(f"Duration: {duration:.2f}s\n")
                f.write(f"Exit Code: {process.returncode}\n")
                f.write("\n--- STDOUT ---\n")
                f.write(result.output)
                f.write("\n--- STDERR ---\n")
                f.write(result.error)

            await self._broadcast_execution_update(result)

        except Exception as e:
            logger.error(f"Background execution monitoring failed: {e}")
            result.status = "failed"
            result.error = str(e)
            result.end_time = datetime.now().isoformat()
            await self._broadcast_execution_update(result)

    async def _broadcast_execution_update(self, result: ExecutionResult):
        """Broadcast execution update to all WebSocket clients.

        Parameters
        ----------
        result : ExecutionResult
            The execution result to broadcast.
        """
        if not self.websocket_connections:
            return

        message = {
            "type": "execution_update",
            "data": result.model_dump(),
        }

        disconnected = []
        for websocket in self.websocket_connections:
            try:
                await websocket.send_text(json.dumps(message))
            except Exception:
                disconnected.append(websocket)

        # Remove disconnected clients
        for ws in disconnected:
            self.websocket_connections.remove(ws)

    def get_execution_status(self, execution_id: str) -> Optional[ExecutionResult]:
        """Get the status of a specific execution.

        Parameters
        ----------
        execution_id : str
            The execution ID to check.

        Returns
        -------
        Optional[ExecutionResult]
            The execution result if found.
        """
        return self.active_executions.get(execution_id)

    def list_active_executions(self) -> List[ExecutionResult]:
        """List all active executions.

        Returns
        -------
        List[ExecutionResult]
            List of active executions.
        """
        return list(self.active_executions.values())


def create_dashboard_app() -> FastAPI:
    """Create the FastAPI dashboard application.

    Returns
    -------
    FastAPI
        The configured FastAPI application.
    """
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

    # Create service instance within app scope
    dashboard_service = DashboardService()

    @app.get("/health")
    def health() -> Dict[str, str]:
        """Health check endpoint."""
        return {"status": "ok"}

    @app.get("/")
    def dashboard_info():
        """Dashboard service information and available endpoints."""
        return {
            "service": "DevOnboarder Dashboard Service",
            "description": "CI Troubleshooting and Script Execution API",
            "version": "1.0",
            "endpoints": {
                "health": "GET /health - Service health check",
                "scripts": "GET /scripts - List available automation scripts",
                "execute": "POST /execute - Execute a script",
                "executions": "GET /executions - List script executions",
                "execution_detail": "GET /execution/{id} - Get execution details",
                "policy": "GET /policy/no-verify - Check no-verify policy status",
            },
            "documentation": "https://dashboard.theangrygamershow.com/docs",
        }

    @app.get("/login/discord")
    def discord_login() -> RedirectResponse:
        """Redirect to Discord OAuth with dashboard return URL."""
        dashboard_url = os.getenv(
            "VITE_DASHBOARD_URL", "https://dashboard.theangrygamershow.com"
        )
        auth_url = "https://auth.theangrygamershow.com"

        # Redirect to auth service with dashboard as the redirect destination
        from urllib.parse import urlencode

        params = {"redirect_to": dashboard_url}
        return RedirectResponse(f"{auth_url}/login/discord?{urlencode(params)}")

    @app.get("/auth/callback")
    def auth_callback(token: Optional[str] = None) -> dict[str, str]:
        """Handle authentication callback from Discord OAuth."""
        if token:
            return {
                "status": "success",
                "message": "Authentication successful",
                "token": token,
                "redirect": "Set token in localStorage and refresh page",
            }
        else:
            return {"status": "error", "message": "No authentication token received"}

    @app.get("/policy/no-verify")
    def no_verify_policy_status() -> Dict[str, str]:
        """Get --no-verify policy enforcement status."""
        # Import only what we need for security
        import os
        import re
        import subprocess  # noqa: B404
        from pathlib import Path

        status: Dict[str, str] = {
            "policy_name": "No-Verify Zero Tolerance Policy",
            "enforcement_level": "CRITICAL",
            "status": "unknown",
            "last_check": datetime.now().isoformat(),
            "violations": "0",
            "emergency_approvals": "0",
            "compliance_score": "0.0",
        }

        components: Dict[str, str] = {}

        try:
            # Check if validation script exists and is executable
            validation_script = Path("scripts/validate_no_verify_usage.sh")
            if validation_script.exists() and os.access(validation_script, os.X_OK):
                components["validation_script"] = "✅ Available"

                # Run the validation with trusted script path
                result = subprocess.run(  # noqa: B603
                    [str(validation_script.resolve())],
                    capture_output=True,
                    text=True,
                    timeout=30,
                    cwd=Path.cwd(),
                )

                if result.returncode == 0:
                    status["status"] = "COMPLIANT"
                    status["compliance_score"] = "100.0"

                    # Parse output for emergency approvals
                    output = result.stdout
                    if "Emergency approved usages:" in output:
                        match = re.search(r"Emergency approved usages: (\d+)", output)
                        if match:
                            status["emergency_approvals"] = match.group(1)

                    if "Unauthorized violations:" in output:
                        match = re.search(r"Unauthorized violations: (\d+)", output)
                        if match:
                            violations = match.group(1)
                            status["violations"] = violations
                            if int(violations) > 0:
                                status["status"] = "VIOLATION"
                                status["compliance_score"] = "0.0"
                else:
                    status["status"] = "VIOLATION"
                    status["compliance_score"] = "0.0"
                    status["error"] = result.stderr
            else:
                components["validation_script"] = "❌ Missing"

            # Check safety wrapper
            safety_wrapper = Path("scripts/git_safety_wrapper.sh")
            if safety_wrapper.exists() and os.access(safety_wrapper, os.X_OK):
                components["safety_wrapper"] = "✅ Available"
            else:
                components["safety_wrapper"] = "❌ Missing"

            # Check pre-commit hook
            precommit_config = Path(".pre-commit-config.yaml")
            if precommit_config.exists():
                with open(precommit_config, "r", encoding="utf-8") as f:
                    config_content = f.read()
                    if "validate-no-verify" in config_content:
                        components["precommit_hook"] = "✅ Configured"
                    else:
                        components["precommit_hook"] = "❌ Not configured"
            else:
                components["precommit_hook"] = "❌ Missing"

            # Check CI workflow
            ci_workflow = Path(".github/workflows/no-verify-policy.yml")
            if ci_workflow.exists():
                components["ci_workflow"] = "✅ Active"
            else:
                components["ci_workflow"] = "❌ Missing"

            # Check policy documentation
            policy_doc = Path("docs/NO_VERIFY_POLICY.md")
            quick_ref = Path("docs/NO_VERIFY_QUICK_REFERENCE.md")

            docs_status = []
            if policy_doc.exists():
                docs_status.append("Policy")
            if quick_ref.exists():
                docs_status.append("Quick Reference")

            if docs_status:
                components["documentation"] = f"✅ {', '.join(docs_status)}"
            else:
                components["documentation"] = "❌ Missing"

        except subprocess.TimeoutExpired:
            status["status"] = "ERROR"
            status["error"] = "Validation script timeout"
        except Exception as e:
            status["status"] = "ERROR"
            status["error"] = str(e)

        # Add components to status
        status.update(components)
        return status

    @app.get("/scripts", response_model=List[ScriptInfo])
    def list_scripts() -> List[ScriptInfo]:
        """List all discovered scripts."""
        return dashboard_service.discover_scripts()

    @app.post("/execute", response_model=ExecutionResult)
    async def execute_script(request: ExecutionRequest) -> ExecutionResult:
        """Execute a script."""
        return await dashboard_service.execute_script(request)

    @app.get("/execution/{execution_id}", response_model=ExecutionResult)
    def get_execution_status(execution_id: str) -> ExecutionResult:
        """Get execution status."""
        result = dashboard_service.get_execution_status(execution_id)
        if not result:
            raise HTTPException(status_code=404, detail="Execution not found")
        return result

    @app.get("/executions", response_model=List[ExecutionResult])
    def list_executions() -> List[ExecutionResult]:
        """List all active executions."""
        return dashboard_service.list_active_executions()

    @app.websocket("/ws")
    async def websocket_endpoint(websocket: WebSocket):
        """WebSocket endpoint for real-time updates."""
        await websocket.accept()
        dashboard_service.websocket_connections.append(websocket)

        try:
            while True:
                # Keep connection alive
                await websocket.receive_text()
        except WebSocketDisconnect:
            dashboard_service.websocket_connections.remove(websocket)

    return app


if __name__ == "__main__":
    import uvicorn

    app = create_dashboard_app()
    # Use environment-configurable host for security
    host = os.getenv("DASHBOARD_HOST", "127.0.0.1")  # Default to localhost for security
    port = int(os.getenv("DASHBOARD_PORT", "8003"))
    uvicorn.run(app, host=host, port=port)
