#!/usr/bin/env python3
"""
HTML AAR Portal Generator for DevOnboarder.

Generates static HTML portal from structured AAR data for web-based
knowledge discovery and trend analysis. Optimized for VSCode workflow
integration and GitHub Pages deployment.
"""

import argparse
import json
import os
import re
import sys
from datetime import datetime
from pathlib import Path
from typing import Dict, List, Any, Optional

try:
    from jinja2 import Environment, FileSystemLoader, select_autoescape
except ImportError:
    print("Error: Jinja2 not installed. Please install with:")
    print("source .venv/bin/activate && pip install jinja2")
    sys.exit(1)


class AARPortalGenerator:
    """Generate HTML portal from AAR data."""

    def __init__(
        self, aar_directory: str = ".aar", output_directory: str = "docs/aar-portal"
    ):
        """Initialize AAR portal generator.

        Parameters
        ----------
        aar_directory : str
            Path to AAR data directory (default: .aar)
        output_directory : str
            Path to output HTML portal (default: docs/aar-portal)
        """
        self.aar_dir = Path(aar_directory)
        self.output_dir = Path(output_directory)
        self.template_dir = self.output_dir / "templates"

        # Ensure output directory exists
        self.output_dir.mkdir(parents=True, exist_ok=True)
        self.template_dir.mkdir(parents=True, exist_ok=True)

        # Initialize Jinja2 environment
        self.jinja_env = Environment(
            loader=FileSystemLoader(str(self.template_dir)),
            autoescape=select_autoescape(["html", "xml"]),
        )

    def discover_aar_structure(self) -> Dict[str, Any]:
        """Scan .aar directory and build comprehensive data structure.

        Returns
        -------
        Dict[str, Any]
            Organized AAR data by quarters and types
        """
        aar_data = {
            "quarters": {},
            "total_aars": 0,
            "types": {
                "pull_requests": 0,
                "issues": 0,
                "sprints": 0,
                "incidents": 0,
                "automation": 0,
            },
            "metrics": {
                "total_files_changed": 0,
                "total_agents_updated": 0,
                "total_action_items": 0,
            },
        }

        if not self.aar_dir.exists():
            print(f"Warning: AAR directory {self.aar_dir} does not exist")
            return aar_data

        # Scan year directories
        for year_dir in self.aar_dir.glob("20*"):
            if not year_dir.is_dir():
                continue

            year = year_dir.name
            aar_data["quarters"][year] = {}

            # Scan quarter directories
            for quarter_dir in year_dir.glob("Q*"):
                if not quarter_dir.is_dir():
                    continue

                quarter = quarter_dir.name
                aar_data["quarters"][year][quarter] = {
                    "pull_requests": [],
                    "issues": [],
                    "sprints": [],
                    "incidents": [],
                    "automation": [],
                }

                # Scan type directories
                for type_dir in quarter_dir.iterdir():
                    if not type_dir.is_dir():
                        continue

                    type_name = type_dir.name.replace("-", "_")
                    if type_name not in aar_data["quarters"][year][quarter]:
                        continue

                    # Parse AAR files in type directory
                    for aar_file in type_dir.glob("*.md"):
                        aar_info = self.parse_aar_file(aar_file, type_name)
                        if aar_info:
                            aar_data["quarters"][year][quarter][type_name].append(
                                aar_info
                            )
                            aar_data["total_aars"] += 1
                            aar_data["types"][type_name] += 1

                            # Aggregate metrics
                            aar_data["metrics"]["total_files_changed"] += aar_info.get(
                                "files_changed", 0
                            )
                            aar_data["metrics"]["total_agents_updated"] += aar_info.get(
                                "agents_updated", 0
                            )
                            aar_data["metrics"]["total_action_items"] += aar_info.get(
                                "action_items", 0
                            )

        return aar_data

    def parse_aar_file(
        self, file_path: Path, aar_type: str
    ) -> Optional[Dict[str, Any]]:
        """Parse individual AAR file for metadata and content.

        Parameters
        ----------
        file_path : Path
            Path to AAR markdown file
        aar_type : str
            Type of AAR (pull_requests, issues, etc.)

        Returns
        -------
        Optional[Dict[str, Any]]
            Parsed AAR data or None if parsing fails
        """
        try:
            with open(file_path, "r", encoding="utf-8") as f:
                content = f.read()

            # Extract title from first heading
            title_match = re.search(r"^#\s+(.+)$", content, re.MULTILINE)
            title = title_match.group(1) if title_match else file_path.stem

            # Extract reference number
            ref_match = re.search(
                r"(pr|issue|sprint|incident|automation)-(\d+|\w+)",
                file_path.stem,
                re.IGNORECASE,
            )
            ref_number = ref_match.group(2) if ref_match else "unknown"

            # Parse metrics from content
            metrics = self.extract_metrics_from_content(content)

            # Extract labels/tags
            labels = self.extract_labels_from_content(content)

            # Calculate file stats
            lines = content.count("\n")
            word_count = len(content.split())

            return {
                "title": title,
                "file_path": str(file_path.relative_to(self.aar_dir)),
                "absolute_path": str(file_path),
                "ref_number": ref_number,
                "type": aar_type,
                "date_created": datetime.fromtimestamp(
                    file_path.stat().st_mtime
                ).isoformat(),
                "files_changed": metrics.get("files_changed", 0),
                "agents_updated": metrics.get("agents_updated", 0),
                "action_items": metrics.get("action_items", 0),
                "codex_alignment": metrics.get("codex_alignment", "Unknown"),
                "labels": labels,
                "word_count": word_count,
                "line_count": lines,
                "content_preview": (
                    content[:500] + "..." if len(content) > 500 else content
                ),
            }

        except Exception as e:
            print(f"Warning: Failed to parse {file_path}: {e}")
            return None

    def extract_metrics_from_content(self, content: str) -> Dict[str, Any]:
        """Extract metrics from AAR content.

        Parameters
        ----------
        content : str
            AAR file content

        Returns
        -------
        Dict[str, Any]
            Extracted metrics
        """
        metrics = {
            "files_changed": 0,
            "agents_updated": 0,
            "action_items": 0,
            "codex_alignment": "Unknown",
        }

        # Extract files changed
        files_match = re.search(r"Files Changed:?\s*(\d+)", content, re.IGNORECASE)
        if files_match:
            metrics["files_changed"] = int(files_match.group(1))

        # Extract agents updated
        agents_match = re.search(
            r"(?:Codex )?Agents Updated:?\s*(\d+)", content, re.IGNORECASE
        )
        if agents_match:
            metrics["agents_updated"] = int(agents_match.group(1))

        # Count action items
        action_items = len(re.findall(r"- \[ \]", content))
        metrics["action_items"] = action_items

        # Check codex alignment
        if "codex alignment" in content.lower():
            if "verified" in content.lower():
                metrics["codex_alignment"] = "Verified"
            elif "pending" in content.lower():
                metrics["codex_alignment"] = "Pending"
            else:
                metrics["codex_alignment"] = "Unknown"

        return metrics

    def extract_labels_from_content(self, content: str) -> List[str]:
        """Extract labels/tags from AAR content.

        Parameters
        ----------
        content : str
            AAR file content

        Returns
        -------
        List[str]
            Extracted labels
        """
        labels = []

        # Common label patterns
        label_patterns = [
            r"critical",
            r"infrastructure",
            r"security",
            r"feature",
            r"breaking-change",
            r"needs-aar",
            r"bug",
            r"enhancement",
            r"documentation",
            r"performance",
        ]

        content_lower = content.lower()
        for pattern in label_patterns:
            if pattern in content_lower:
                labels.append(pattern)

        return labels

    def calculate_trends(self, aar_data: Dict[str, Any]) -> Dict[str, Any]:
        """Calculate trend data for dashboard visualization.

        Parameters
        ----------
        aar_data : Dict[str, Any]
            Complete AAR data structure

        Returns
        -------
        Dict[str, Any]
            Trend analysis data
        """
        trends = {
            "quarterly_counts": [],
            "type_distribution": aar_data["types"],
            "files_changed_trend": [],
            "agents_updated_trend": [],
            "action_items_trend": [],
            "avg_metrics": {},
        }

        # Calculate quarterly trends
        for year, quarters in aar_data["quarters"].items():
            for quarter, types in quarters.items():
                quarter_total = sum(len(aars) for aars in types.values())
                quarter_files = 0
                quarter_agents = 0
                quarter_actions = 0

                for type_aars in types.values():
                    for aar in type_aars:
                        quarter_files += aar.get("files_changed", 0)
                        quarter_agents += aar.get("agents_updated", 0)
                        quarter_actions += aar.get("action_items", 0)

                trends["quarterly_counts"].append(
                    {
                        "period": f"{quarter} {year}",
                        "total_aars": quarter_total,
                        "files_changed": quarter_files,
                        "agents_updated": quarter_agents,
                        "action_items": quarter_actions,
                    }
                )

        # Calculate averages
        if aar_data["total_aars"] > 0:
            trends["avg_metrics"] = {
                "avg_files_per_aar": round(
                    aar_data["metrics"]["total_files_changed"] / aar_data["total_aars"],
                    1,
                ),
                "avg_agents_per_aar": round(
                    aar_data["metrics"]["total_agents_updated"]
                    / aar_data["total_aars"],
                    1,
                ),
                "avg_actions_per_aar": round(
                    aar_data["metrics"]["total_action_items"] / aar_data["total_aars"],
                    1,
                ),
            }

        return trends

    def create_templates(self):
        """Create Jinja2 templates for HTML portal."""

        # Base template - Break up long lines for linting compliance
        base_template = (
            "<!DOCTYPE html>\n"
            '<html lang="en">\n'
            "<head>\n"
            '    <meta charset="UTF-8">\n'
            '    <meta name="viewport" content="width=device-width, '
            'initial-scale=1.0">\n'
            "    <title>{% block title %}DevOnboarder AAR Portal"
            "{% endblock %}</title>\n"
            '    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/'
            'bootstrap.min.css" rel="stylesheet">\n'
            '    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.7.2/'
            'font/bootstrap-icons.css" rel="stylesheet">\n'
            "    <style>\n"
            "        .aar-card {\n"
            "            transition: transform 0.2s;\n"
            "            height: 100%;\n"
            "        }\n"
            "        .aar-card:hover {\n"
            "            transform: translateY(-2px);\n"
            "            box-shadow: 0 4px 8px rgba(0,0,0,0.1);\n"
            "        }\n"
            "        .metric-badge {\n"
            "            font-size: 0.8em;\n"
            "        }\n"
            "        .search-box {\n"
            "            position: sticky;\n"
            "            top: 20px;\n"
            "            z-index: 100;\n"
            "        }\n"
            "        .filter-sidebar {\n"
            "            background-color: #f8f9fa;\n"
            "            min-height: 100vh;\n"
            "        }\n"
            "        .trend-chart {\n"
            "            height: 300px;\n"
            "        }\n"
            "        .navbar-brand {\n"
            "            font-weight: bold;\n"
            "        }\n"
            "        .footer {\n"
            "            background-color: #343a40;\n"
            "            color: white;\n"
            "            padding: 20px 0;\n"
            "            margin-top: 50px;\n"
            "        }\n"
            "        .type-pull_requests { border-left: 4px solid #0d6efd; }\n"
            "        .type-issues { border-left: 4px solid #198754; }\n"
            "        .type-sprints { border-left: 4px solid #ffc107; }\n"
            "        .type-incidents { border-left: 4px solid #dc3545; }\n"
            "        .type-automation { border-left: 4px solid #6f42c1; }\n"
            "    </style>\n"
            "    {% block extra_head %}{% endblock %}\n"
            "</head>\n"
            "<body>\n"
            '    <nav class="navbar navbar-expand-lg navbar-dark bg-dark">\n'
            '        <div class="container">\n'
            '            <a class="navbar-brand" href="index.html">\n'
            '                <i class="bi bi-journal-text"></i> '
            "DevOnboarder AAR Portal\n"
            "            </a>\n"
            '            <div class="navbar-nav ms-auto">\n'
            '                <a class="nav-link" href="index.html">Browse</a>\n'
            '                <a class="nav-link" href="trends.html">Trends</a>\n'
            '                <a class="nav-link" href="search.html">Search</a>\n'
            "            </div>\n"
            "        </div>\n"
            "    </nav>\n"
            "\n"
            '    <main class="container-fluid mt-4">\n'
            "        {% block content %}{% endblock %}\n"
            "    </main>\n"
            "\n"
            '    <footer class="footer">\n'
            '        <div class="container text-center">\n'
            "            <p>&copy; 2025 DevOnboarder AAR Portal - Generated on "
            "{{ generation_date }}</p>\n"
            "            <p><small>Total AARs: {{ total_aars }} | Last Updated: "
            "{{ last_updated }}</small></p>\n"
            "        </div>\n"
            "    </footer>\n"
            "\n"
            '    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/'
            'bootstrap.bundle.min.js"></script>\n'
            '    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>\n'
            "    {% block extra_scripts %}{% endblock %}\n"
            "</body>\n"
            "</html>"
        )

        # Index template
        index_template = """{% extends "base.html" %}

{% block title %}AAR Browser - DevOnboarder{% endblock %}

{% block content %}
<div class="row">
    <!-- Filters Sidebar -->
    <div class="col-md-3 filter-sidebar p-4">
        <div class="search-box">
            <h5><i class="bi bi-funnel"></i> Filters</h5>

            <div class="mb-3">
                <label for="quarterFilter" class="form-label">Quarter</label>
                <select class="form-select" id="quarterFilter">
                    <option value="">All Quarters</option>
                    {% for year, quarters in aar_data.quarters.items() %}
                        {% for quarter in quarters.keys() %}
                            <option value="{{ quarter }}-{{ year }}">
                                {{ quarter }} {{ year }}
                            </option>
                        {% endfor %}
                    {% endfor %}
                </select>
            </div>

            <div class="mb-3">
                <label for="typeFilter" class="form-label">Type</label>
                <select class="form-select" id="typeFilter">
                    <option value="">All Types</option>
                    <option value="pull_requests">Pull Requests</option>
                    <option value="issues">Issues</option>
                    <option value="sprints">Sprints</option>
                    <option value="incidents">Incidents</option>
                    <option value="automation">Automation</option>
                </select>
            </div>

            <div class="mb-3">
                <label for="searchQuery" class="form-label">Search</label>
                <input type="text" class="form-control" id="searchQuery"
                       placeholder="Search AAR content...">
            </div>

            <button class="btn btn-secondary btn-sm" onclick="clearFilters()"
            >Clear Filters</button>
        </div>

        <!-- Summary Stats -->
        <div class="mt-4">
            <h6>Summary</h6>
            <ul class="list-unstyled">
                <li><strong>{{ aar_data.total_aars }}</strong> Total AARs</li>
                <li><strong>{{ aar_data.metrics.total_files_changed }}</strong> Files Changed</li>
                <li><strong>{{ aar_data.metrics.total_agents_updated }}</strong> Agents Updated</li>
                <li><strong>{{ aar_data.metrics.total_action_items }}</strong> Action Items</li>
            </ul>
        </div>
    </div>

    <!-- AAR Grid -->
    <div class="col-md-9">
        <div class="d-flex justify-content-between align-items-center mb-4">
            <h2><i class="bi bi-grid"></i> After Action Reports</h2>
            <span class="badge bg-primary" id="resultCount">{{ aar_data.total_aars }} AARs</span>
        </div>

        <div class="row" id="aarGrid">
            {% for year, quarters in aar_data.quarters.items() %}
                {% for quarter, types in quarters.items() %}
                    {% for type_name, aars in types.items() %}
                        {% for aar in aars %}
                            <div class="col-lg-4 col-md-6 mb-4 aar-item"
                                 data-quarter="{{ quarter }}-{{ year }}"
                                 data-type="{{ type_name }}"
                                 data-title="{{ aar.title.lower() }}"
                                 data-content="{{ aar.content_preview.lower() }}">
                                <div class="card aar-card h-100 type-{{ type_name }}">
                                    <div class="card-header">
                                        <h6 class="card-title mb-0">
                                            <i class="bi bi-{{ 'git-pull-request' if type_name == 'pull_requests' else 'exclamation-circle' if type_name == 'issues' else 'clock' if type_name == 'sprints' else 'bug' if type_name == 'incidents' else 'gear' }}"></i>
                                            {{ type_name.replace('_', ' ').title() }} #{{ aar.ref_number }}
                                        </h6>
                                    </div>
                                    <div class="card-body">
                                        <h6 class="card-title">{{ aar.title }}</h6>
                                        <p class="card-text small">{{ aar.content_preview[:150] }}...</p>

                                        <!-- Metrics -->
                                        <div class="d-flex gap-2 mb-2">
                                            <span class="badge bg-secondary metric-badge">{{ aar.files_changed }} files</span>
                                            <span class="badge bg-info metric-badge">{{ aar.agents_updated }} agents</span>
                                            <span class="badge bg-warning metric-badge">{{ aar.action_items }} items</span>
                                        </div>

                                        <!-- Labels -->
                                        <div class="mb-2">
                                            {% for label in aar.labels %}
                                                <span class="badge bg-light text-dark">{{ label }}</span>
                                            {% endfor %}
                                        </div>
                                    </div>
                                    <div class="card-footer">
                                        <small class="text-muted">{{ quarter }} {{ year }}</small>
                                        <div class="btn-group float-end" role="group">
                                            <a href="vscode://file/{{ aar.absolute_path }}" class="btn btn-outline-primary btn-sm" title="Open in VSCode">
                                                <i class="bi bi-code"></i>
                                            </a>
                                            <a href="../{{ aar.file_path }}" class="btn btn-outline-secondary btn-sm" title="View File">
                                                <i class="bi bi-eye"></i>
                                            </a>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        {% endfor %}
                    {% endfor %}
                {% endfor %}
            {% endfor %}
        </div>

        <div id="noResults" class="text-center mt-5" style="display: none;">
            <i class="bi bi-search display-1 text-muted"></i>
            <h4 class="text-muted">No AARs found</h4>
            <p class="text-muted">Try adjusting your filters or search terms.</p>
        </div>
    </div>
</div>
{% endblock %}

{% block extra_scripts %}
<script>
    function filterAARs() {
        const quarterFilter = document.getElementById('quarterFilter').value;
        const typeFilter = document.getElementById('typeFilter').value;
        const searchQuery = document.getElementById('searchQuery').value.toLowerCase();

        const aarItems = document.querySelectorAll('.aar-item');
        let visibleCount = 0;

        aarItems.forEach(item => {
            const quarter = item.dataset.quarter;
            const type = item.dataset.type;
            const title = item.dataset.title;
            const content = item.dataset.content;

            let show = true;

            if (quarterFilter && quarter !== quarterFilter) show = false;
            if (typeFilter && type !== typeFilter) show = false;
            if (searchQuery && !title.includes(searchQuery) && !content.includes(searchQuery)) show = false;

            item.style.display = show ? 'block' : 'none';
            if (show) visibleCount++;
        });

        document.getElementById('resultCount').textContent = `${visibleCount} AARs`;
        document.getElementById('noResults').style.display = visibleCount === 0 ? 'block' : 'none';
    }

    function clearFilters() {
        document.getElementById('quarterFilter').value = '';
        document.getElementById('typeFilter').value = '';
        document.getElementById('searchQuery').value = '';
        filterAARs();
    }

    // Add event listeners
    document.getElementById('quarterFilter').addEventListener('change', filterAARs);
    document.getElementById('typeFilter').addEventListener('change', filterAARs);
    document.getElementById('searchQuery').addEventListener('input', filterAARs);
</script>
{% endblock %}"""

        # Trends template
        trends_template = """{% extends "base.html" %}

{% block title %}Trends Dashboard - DevOnboarder AAR Portal{% endblock %}

{% block content %}
<div class="container">
    <div class="row mb-4">
        <div class="col-12">
            <h2><i class="bi bi-graph-up"></i> AAR Trends Dashboard</h2>
            <p class="text-muted">Visualize patterns and insights from your After Action Reports</p>
        </div>
    </div>

    <!-- Summary Cards -->
    <div class="row mb-4">
        <div class="col-md-3">
            <div class="card bg-primary text-white">
                <div class="card-body">
                    <h5 class="card-title">{{ aar_data.total_aars }}</h5>
                    <p class="card-text">Total AARs</p>
                </div>
            </div>
        </div>
        <div class="col-md-3">
            <div class="card bg-success text-white">
                <div class="card-body">
                    <h5 class="card-title">{{ trends.avg_metrics.avg_files_per_aar or 0 }}</h5>
                    <p class="card-text">Avg Files per AAR</p>
                </div>
            </div>
        </div>
        <div class="col-md-3">
            <div class="card bg-warning text-white">
                <div class="card-body">
                    <h5 class="card-title">{{ trends.avg_metrics.avg_agents_per_aar or 0 }}</h5>
                    <p class="card-text">Avg Agents per AAR</p>
                </div>
            </div>
        </div>
        <div class="col-md-3">
            <div class="card bg-info text-white">
                <div class="card-body">
                    <h5 class="card-title">{{ trends.avg_metrics.avg_actions_per_aar or 0 }}</h5>
                    <p class="card-text">Avg Actions per AAR</p>
                </div>
            </div>
        </div>
    </div>

    <!-- Charts Row -->
    <div class="row">
        <div class="col-md-6 mb-4">
            <div class="card">
                <div class="card-header">
                    <h5>AARs by Type</h5>
                </div>
                <div class="card-body">
                    <canvas id="typeChart" class="trend-chart"></canvas>
                </div>
            </div>
        </div>
        <div class="col-md-6 mb-4">
            <div class="card">
                <div class="card-header">
                    <h5>Quarterly Trends</h5>
                </div>
                <div class="card-body">
                    <canvas id="quarterlyChart" class="trend-chart"></canvas>
                </div>
            </div>
        </div>
    </div>

    <div class="row">
        <div class="col-12 mb-4">
            <div class="card">
                <div class="card-header">
                    <h5>Files Changed Over Time</h5>
                </div>
                <div class="card-body">
                    <canvas id="filesChart" class="trend-chart"></canvas>
                </div>
            </div>
        </div>
    </div>
</div>
{% endblock %}

{% block extra_scripts %}
<script>
    // Type Distribution Chart
    const typeCtx = document.getElementById('typeChart').getContext('2d');
    new Chart(typeCtx, {
        type: 'doughnut',
        data: {
            labels: ['Pull Requests', 'Issues', 'Sprints', 'Incidents', 'Automation'],
            datasets: [{
                data: [
                    {{ trends.type_distribution.pull_requests }},
                    {{ trends.type_distribution.issues }},
                    {{ trends.type_distribution.sprints }},
                    {{ trends.type_distribution.incidents }},
                    {{ trends.type_distribution.automation }}
                ],
                backgroundColor: [
                    '#0d6efd',
                    '#198754',
                    '#ffc107',
                    '#dc3545',
                    '#6f42c1'
                ]
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false
        }
    });

    // Quarterly Trends Chart
    const quarterlyCtx = document.getElementById('quarterlyChart').getContext('2d');
    const quarterlyData = {{ trends.quarterly_counts | tojson }};

    new Chart(quarterlyCtx, {
        type: 'line',
        data: {
            labels: quarterlyData.map(q => q.period),
            datasets: [{
                label: 'Total AARs',
                data: quarterlyData.map(q => q.total_aars),
                borderColor: '#0d6efd',
                backgroundColor: 'rgba(13, 110, 253, 0.1)',
                tension: 0.1
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            scales: {
                y: {
                    beginAtZero: true
                }
            }
        }
    });

    // Files Changed Chart
    const filesCtx = document.getElementById('filesChart').getContext('2d');

    new Chart(filesCtx, {
        type: 'bar',
        data: {
            labels: quarterlyData.map(q => q.period),
            datasets: [{
                label: 'Files Changed',
                data: quarterlyData.map(q => q.files_changed),
                backgroundColor: 'rgba(25, 135, 84, 0.7)',
                borderColor: '#198754',
                borderWidth: 1
            }, {
                label: 'Action Items',
                data: quarterlyData.map(q => q.action_items),
                backgroundColor: 'rgba(255, 193, 7, 0.7)',
                borderColor: '#ffc107',
                borderWidth: 1
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            scales: {
                y: {
                    beginAtZero: true
                }
            }
        }
    });
</script>
{% endblock %}"""

        # Write templates to files
        with open(self.template_dir / "base.html", "w") as f:
            f.write(base_template)

        with open(self.template_dir / "index.html", "w") as f:
            f.write(index_template)

        with open(self.template_dir / "trends.html", "w") as f:
            f.write(trends_template)

        print(f"Templates created in {self.template_dir}")

    def generate_portal(self):
        """Generate complete HTML portal."""
        print("Starting AAR Portal generation...")

        # Create templates if they don't exist
        if not (self.template_dir / "base.html").exists():
            self.create_templates()

        # Discover AAR data
        print("Scanning AAR directory structure...")
        aar_data = self.discover_aar_structure()
        print(
            f"Found {aar_data['total_aars']} AARs across "
            f"{len(aar_data['quarters'])} years"
        )

        # Calculate trends
        print("Calculating trend data...")
        trends = self.calculate_trends(aar_data)

        # Generate index page
        print("Generating index page...")
        template = self.jinja_env.get_template("index.html")
        html_content = template.render(
            aar_data=aar_data,
            trends=trends,
            generation_date=datetime.now().strftime("%Y-%m-%d %H:%M:%S"),
            total_aars=aar_data["total_aars"],
            last_updated=datetime.now().isoformat(),
        )

        with open(self.output_dir / "index.html", "w") as f:
            f.write(html_content)

        # Generate trends page
        print("Generating trends page...")
        trends_template = self.jinja_env.get_template("trends.html")
        trends_content = trends_template.render(
            aar_data=aar_data,
            trends=trends,
            generation_date=datetime.now().strftime("%Y-%m-%d %H:%M:%S"),
            total_aars=aar_data["total_aars"],
            last_updated=datetime.now().isoformat(),
        )

        with open(self.output_dir / "trends.html", "w") as f:
            f.write(trends_content)

        # Generate JSON data for API access
        print("Generating JSON data...")
        with open(self.output_dir / "aar-data.json", "w") as f:
            json.dump(
                {
                    "aar_data": aar_data,
                    "trends": trends,
                    "generated": datetime.now().isoformat(),
                },
                f,
                indent=2,
            )

        print(f"Portal generated successfully in {self.output_dir}")
        print(f"Open {self.output_dir}/index.html in your browser to view the portal")


def main():
    """Main entry point for AAR portal generation."""
    parser = argparse.ArgumentParser(
        description="Generate HTML portal from DevOnboarder AAR data"
    )
    parser.add_argument(
        "--aar-dir", default=".aar", help="Path to AAR directory (default: .aar)"
    )
    parser.add_argument(
        "--output-dir",
        default="docs/aar-portal",
        help="Output directory for HTML portal (default: docs/aar-portal)",
    )
    parser.add_argument(
        "--serve",
        action="store_true",
        help="Start local development server after generation",
    )

    args = parser.parse_args()

    # Generate portal
    generator = AARPortalGenerator(args.aar_dir, args.output_dir)
    generator.generate_portal()

    # Optional: Start development server
    if args.serve:
        import http.server
        import socketserver
        import webbrowser

        port = 8080
        os.chdir(args.output_dir)

        with socketserver.TCPServer(
            ("", port), http.server.SimpleHTTPRequestHandler
        ) as httpd:
            print(f"Serving AAR portal at http://localhost:{port}")
            webbrowser.open(f"http://localhost:{port}")
            try:
                httpd.serve_forever()
            except KeyboardInterrupt:
                print("\nServer stopped")


if __name__ == "__main__":
    main()
