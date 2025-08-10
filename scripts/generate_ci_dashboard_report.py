#!/usr/bin/env python3
"""Generate CI Dashboard Report for GitHub Actions.

This script creates a comprehensive HTML report that can be uploaded as a CI artifact,
providing the same dashboard functionality accessible in CI environments.
"""

import html
import json
import os
import subprocess
import sys
from datetime import datetime
from pathlib import Path


def check_environment():
    """Check if we're in a proper environment."""
    if not (Path.cwd() / "pyproject.toml").exists():
        print("❌ Not in DevOnboarder project root")
        return False
    return True


def get_scripts_info():
    """Get information about available scripts."""
    scripts_dir = Path("scripts")
    if not scripts_dir.exists():
        return []

    scripts = []
    for script_path in scripts_dir.rglob("*"):
        if not script_path.is_file():
            continue

        # Skip hidden files
        if any(part.startswith(".") for part in script_path.parts):
            continue

        # Check if it's a script
        is_executable = os.access(script_path, os.X_OK)
        is_script = script_path.suffix in {".sh", ".py", ".js", ".ts"}

        if not (is_executable or is_script):
            continue

        # Get file info
        stat = script_path.stat()
        scripts.append(
            {
                "name": script_path.name,
                "path": str(script_path),
                "type": "Python" if script_path.suffix == ".py" else "Shell",
                "size": stat.st_size,
                "modified": datetime.fromtimestamp(stat.st_mtime).isoformat(),
            }
        )

    return sorted(scripts, key=lambda s: s["name"])


def run_ci_analysis():
    """Run CI analysis commands and capture output."""
    analyses = {}

    # Pattern analysis
    try:
        result = subprocess.run(
            ["bash", "scripts/analyze_ci_patterns.sh"],
            capture_output=True,
            text=True,
            timeout=30,
            check=False,
        )
        analyses["patterns"] = {
            "exit_code": result.returncode,
            "output": result.stdout,
            "error": result.stderr,
        }
    except (subprocess.TimeoutExpired, FileNotFoundError, OSError) as e:
        analyses["patterns"] = {"error": str(e)}

    # Health monitoring
    try:
        result = subprocess.run(
            ["bash", "scripts/monitor_ci_health.sh"],
            capture_output=True,
            text=True,
            timeout=30,
            check=False,
        )
        analyses["health"] = {
            "exit_code": result.returncode,
            "output": result.stdout,
            "error": result.stderr,
        }
    except (subprocess.TimeoutExpired, FileNotFoundError, OSError) as e:
        analyses["health"] = {"error": str(e)}

    # Failed runs analysis
    try:
        result = subprocess.run(
            ["bash", "scripts/analyze_failed_ci_runs.sh"],
            capture_output=True,
            text=True,
            timeout=60,
            check=False,
        )
        analyses["failures"] = {
            "exit_code": result.returncode,
            "output": result.stdout,
            "error": result.stderr,
        }
    except (subprocess.TimeoutExpired, FileNotFoundError, OSError) as e:
        analyses["failures"] = {"error": str(e)}

    return analyses


def safe_html_escape(text):
    """
    Escape text for safe inclusion in HTML, preserving emojis and Unicode.

    Parameters:
        text (str or any): Input text to be escaped. Converted to string if needed.

    Returns:
        str: HTML-escaped version of input text, safe for embedding in HTML.

    Why:
        Prevents HTML injection and XSS vulnerabilities when displaying dynamic
        content in HTML. Uses Python's html.escape to escape special HTML
        characters (&, <, >, ", '). Emojis and Unicode characters are preserved.
    """
    if not text:
        return ""
    # First escape HTML special characters
    escaped = html.escape(str(text))
    return escaped


def generate_html_report(scripts, analyses):
    """Generate HTML dashboard report."""
    # Get safe outputs
    patterns_output = safe_html_escape(
        analyses.get("patterns", {}).get("output", "Analysis not available")
    )
    health_output = safe_html_escape(
        analyses.get("health", {}).get("output", "Health data not available")
    )
    failures_output = safe_html_escape(
        analyses.get("failures", {}).get("output", "Failure analysis not available")
    )

    # Create CSS class expressions for readability
    patterns_status = (
        "good" if analyses.get("patterns", {}).get("exit_code") == 0 else "warn"
    )
    health_status = (
        "good" if analyses.get("health", {}).get("exit_code") == 0 else "warn"
    )
    failures_status = (
        "good" if analyses.get("failures", {}).get("exit_code") == 0 else "warn"
    )

    # Create status text expressions
    patterns_text = (
        "✅ Success"
        if analyses.get("patterns", {}).get("exit_code") == 0
        else "❌ Issues Found"
    )
    health_text = (
        "✅ Healthy"
        if analyses.get("health", {}).get("exit_code") == 0
        else "❌ Needs Attention"
    )
    failures_text = (
        "✅ Clean"
        if analyses.get("failures", {}).get("exit_code") == 0
        else "❌ Failures Detected"
    )

    html_content = f"""<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>DevOnboarder CI Dashboard Report</title>
    <style>
        body {{
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Arial,
            sans-serif; margin: 20px; background: #f6f8fa;
        }}
        .container {{ max-width: 1200px; margin: 0 auto; }}
        .header {{
            background: #24292f; color: white; padding: 20px;
            border-radius: 8px; margin-bottom: 20px;
        }}
        .section {{
            background: white; padding: 20px; border-radius: 8px;
            margin-bottom: 20px; border: 1px solid #d1d9e0;
        }}
        .scripts-grid {{
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
            gap: 15px;
        }}
        .script-card {{
            border: 1px solid #d1d9e0; padding: 15px;
            border-radius: 6px; background: #f6f8fa;
        }}
        .analysis-output {{
            background: #f6f8fa; padding: 15px; border-radius: 6px;
            font-family: 'SFMono-Regular', Consolas, monospace;
            font-size: 12px; white-space: pre-wrap; max-height: 400px;
            overflow-y: auto;
        }}
        .status-good {{ color: #1a7f37; }}
        .status-warn {{ color: #d1242f; }}
        .timestamp {{ color: #656d76; font-size: 14px; }}
        h1, h2, h3 {{ margin-top: 0; }}
        .summary {{
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 15px;
        }}
        .summary-card {{
            background: #dbeafe; padding: 15px; border-radius: 6px;
            text-align: center;
        }}
        .summary-card.warn {{ background: #fee2e2; }}
        .summary-card.good {{ background: #d1fae5; }}
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>🛠️ DevOnboarder CI Dashboard Report</h1>
            <p class="timestamp">Generated: {datetime.now().isoformat()}</p>
        </div>

        <div class="section">
            <h2>📊 CI Analysis Summary</h2>
            <div class="summary">
                <div class="summary-card {patterns_status}">
                    <h3>Pattern Analysis</h3>
                    <p>Status: {patterns_text}</p>
                </div>
                <div class="summary-card {health_status}">
                    <h3>Health Monitoring</h3>
                    <p>Status: {health_text}</p>
                </div>
                <div class="summary-card {failures_status}">
                    <h3>Failure Analysis</h3>
                    <p>Status: {failures_text}</p>
                </div>
                <div class="summary-card good">
                    <h3>Available Scripts</h3>
                    <p>{len(scripts)} automation scripts</p>
                </div>
            </div>
        </div>

        <div class="section">
            <h2>🔍 CI Pattern Analysis</h2>
            <div class="analysis-output">{patterns_output}</div>
        </div>

        <div class="section">
            <h2>💚 CI Health Monitoring</h2>
            <div class="analysis-output">{health_output}</div>
        </div>

        <div class="section">
            <h2>🚨 Failure Analysis</h2>
            <div class="analysis-output">{failures_output}</div>
        </div>

        <div class="section">
            <h2>🛠️ Available Automation Scripts</h2>
            <div class="scripts-grid">"""

    for script in scripts[:20]:  # Limit to first 20 scripts to prevent huge HTML
        html_content += f"""
                <div class="script-card">
                    <h3>{safe_html_escape(script["name"])}</h3>
                    <p><strong>Type:</strong> {safe_html_escape(script["type"])}</p>
                    <p><strong>Path:</strong>
                       <code>{safe_html_escape(script["path"])}</code></p>
                    <p><strong>Size:</strong> {script["size"]} bytes</p>
                    <p><strong>Modified:</strong> {script["modified"][:19]}</p>
                </div>"""

    if len(scripts) > 20:
        html_content += f"""
                <div class="script-card">
                    <h3>... and {len(scripts) - 20} more scripts</h3>
                    <p>See JSON data for complete list</p>
                </div>"""

    html_content += f"""
            </div>
        </div>

        <div class="section">
            <h2>📋 Raw Analysis Data</h2>
            <details>
                <summary>Click to view JSON data</summary>
                <div class="analysis-output">{
        safe_html_escape(json.dumps(analyses, indent=2))
    }</div>
            </details>
        </div>
    </div>
</body>
</html>"""

    return html_content


def main():
    """Main execution function."""
    print("🛠️ Generating DevOnboarder CI Dashboard Report...")

    if not check_environment():
        sys.exit(1)

    # Create output directory
    output_dir = Path("logs")
    output_dir.mkdir(exist_ok=True)

    print("📋 Discovering automation scripts...")
    scripts = get_scripts_info()
    print(f"Found {len(scripts)} scripts")

    print("🔍 Running CI analysis...")
    analyses = run_ci_analysis()

    print("📊 Generating HTML report...")
    html_report = generate_html_report(scripts, analyses)

    # Write report
    report_path = output_dir / "ci_dashboard_report.html"
    with open(report_path, "w", encoding="utf-8") as f:
        f.write(html_report)

    # Also create a JSON report
    json_data = {
        "timestamp": datetime.now().isoformat(),
        "scripts": scripts,
        "analyses": analyses,
    }

    json_path = output_dir / "ci_dashboard_data.json"
    with open(json_path, "w", encoding="utf-8") as f:
        json.dump(json_data, f, indent=2, ensure_ascii=False)

    print("✅ Dashboard report generated:")
    print(f"   HTML: {report_path}")
    print(f"   JSON: {json_path}")
    print("   Open the HTML file in a browser to view the dashboard")

    return 0


if __name__ == "__main__":
    sys.exit(main())
