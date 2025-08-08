#!/usr/bin/env python3
"""
scripts/extract_service_interfaces.py
Extract and document service API contracts for strategic repository split readiness.
"""

import ast
import json
import re
from datetime import datetime
from pathlib import Path
from typing import Dict, List, Optional


def setup_logging():
    """Set up logging to centralized logs directory."""
    log_dir = Path("logs")
    log_dir.mkdir(exist_ok=True)

    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    log_file = log_dir / f"service_interface_extraction_{timestamp}.log"

    return log_file


def analyze_fastapi_routes(service_path: str) -> Dict[str, List[Dict[str, str]]]:
    """Extract FastAPI routes and their details."""
    routes = {}
    service_path = Path(service_path)

    print(f"Analyzing FastAPI routes in: {service_path}")

    for py_file in service_path.rglob("*.py"):
        try:
            with open(py_file, "r", encoding="utf-8") as f:
                content = f.read()
                tree = ast.parse(content)

            file_routes = []

            # Extract FastAPI route decorators
            for node in ast.walk(tree):
                if isinstance(node, ast.FunctionDef):
                    for decorator in node.decorator_list:
                        route_info = extract_route_info(decorator, node, content)
                        if route_info:
                            file_routes.append(route_info)

            if file_routes:
                routes[str(py_file.relative_to(Path.cwd()))] = file_routes

        except Exception as e:
            print(f"Warning: Could not parse {py_file}: {e}")
            continue

    return routes


def extract_route_info(
    decorator, function_node, file_content: str
) -> Optional[Dict[str, str]]:  # noqa: E501
    """Extract route information from FastAPI decorator."""
    route_info = None

    # Handle @app.get("/path") style decorators
    http_methods = ["get", "post", "put", "delete", "patch"]
    if hasattr(decorator, "attr") and decorator.attr in http_methods:
        method = decorator.attr.upper()
        path = "/"  # default

        # Extract path from decorator arguments
        if hasattr(decorator, "args") and decorator.args:
            for arg in decorator.args:
                if hasattr(arg, "s"):  # String literal
                    path = arg.s
                    break

        # Extract function docstring
        docstring = ast.get_docstring(function_node) or "No description"

        route_info = {
            "method": method,
            "path": path,
            "function": function_node.name,
            "description": docstring.split("\n")[0],  # First line only
        }

    # Handle @router.get("/path") style decorators
    elif hasattr(decorator, "attr") and hasattr(decorator, "value"):
        if (
            hasattr(decorator.value, "id")
            and decorator.value.id == "router"
            and decorator.attr in http_methods
        ):

            method = decorator.attr.upper()
            path = "/"

            if hasattr(decorator, "args") and decorator.args:
                for arg in decorator.args:
                    if hasattr(arg, "s"):
                        path = arg.s
                        break

            docstring = ast.get_docstring(function_node) or "No description"

            route_info = {
                "method": method,
                "path": path,
                "function": function_node.name,
                "description": docstring.split("\n")[0],
            }

    return route_info


def analyze_database_models(src_path: str = "src") -> Dict[str, List[str]]:
    """Extract database model definitions and relationships."""
    models = {}
    src_path = Path(src_path)

    print(f"Analyzing database models in: {src_path}")

    for py_file in src_path.rglob("*.py"):
        if "model" in py_file.name.lower() or "models" in py_file.name.lower():
            try:
                with open(py_file, "r", encoding="utf-8") as f:
                    content = f.read()

                # Extract class definitions that might be models
                class_pattern = r"class\s+(\w+).*?:"
                classes = re.findall(class_pattern, content)

                # Look for SQLAlchemy patterns
                sqlalchemy_patterns = [
                    r"from sqlalchemy",
                    r"Base\s*=",
                    r"Column\(",
                    r"relationship\(",
                    r"ForeignKey\(",
                ]

                has_sqlalchemy = any(
                    re.search(pattern, content) for pattern in sqlalchemy_patterns
                )

                if classes and has_sqlalchemy:
                    models[str(py_file.relative_to(Path.cwd()))] = classes

            except Exception as e:
                print(f"Warning: Could not analyze {py_file}: {e}")
                continue

    return models


def analyze_service_ports(src_path: str = "src") -> Dict[str, List[str]]:
    """Extract service port configurations."""
    ports = {}
    src_path = Path(src_path)

    print(f"Analyzing service ports in: {src_path}")

    # Common port patterns
    port_patterns = [
        r'port["\s]*[:=]["\s]*(\d+)',
        r'PORT["\s]*[:=]["\s]*(\d+)',
        r"localhost:(\d+)",
        r"127\.0\.0\.1:(\d+)",
        r"uvicorn.*--port\s+(\d+)",
        r"app\.run.*port=(\d+)",
    ]

    for py_file in src_path.rglob("*.py"):
        try:
            with open(py_file, "r", encoding="utf-8") as f:
                content = f.read()

            found_ports = []
            for pattern in port_patterns:
                matches = re.findall(pattern, content, re.IGNORECASE)
                found_ports.extend(matches)

            if found_ports:
                # Remove duplicates and sort
                unique_ports = sorted(list(set(found_ports)))
                ports[str(py_file.relative_to(Path.cwd()))] = unique_ports

        except Exception as e:
            print(f"Warning: Could not analyze {py_file}: {e}")
            continue

    return ports


def generate_service_contract_docs(routes: Dict, models: Dict, ports: Dict) -> str:
    """Generate comprehensive service API contract documentation."""

    timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")

    contract = f"""# DevOnboarder Service API Contracts

**Generated**: {timestamp}
**Purpose**: Strategic repository split readiness assessment
**Status**: Pre-split analysis for service boundary identification

## Executive Summary

This document provides a comprehensive analysis of DevOnboarder's service
interfaces, database models, and port configurations to assess readiness for
strategic repository separation post-MVP.

## Service API Endpoints

"""

    # Group routes by service
    service_routes = {}
    for file_path, file_routes in routes.items():
        service_name = extract_service_name(file_path)
        if service_name not in service_routes:
            service_routes[service_name] = []
        service_routes[service_name].extend(file_routes)

    for service_name, service_route_list in service_routes.items():
        contract += f"\n### {service_name.title()} Service\n\n"
        contract += (
            f"**Endpoints**: {len(service_route_list)} API routes identified\n\n"
        )

        for route in service_route_list:
            contract += (
                f"- **{route['method']} {route['path']}** - `{route['function']}()`\n"
            )
            contract += f"  - {route['description']}\n"

        contract += "\n"

    # Database Models Section
    contract += "## Database Models\n\n"

    for file_path, model_classes in models.items():
        service_name = extract_service_name(file_path)
        contract += f"### {service_name.title()} Models\n\n"
        contract += f"**File**: `{file_path}`  \n"
        contract += f"**Models**: {', '.join(model_classes)}\n\n"

    # Service Ports Section
    contract += "## Service Port Configuration\n\n"

    for file_path, port_list in ports.items():
        service_name = extract_service_name(file_path)
        contract += f"### {service_name.title()} Service\n\n"
        contract += f"**File**: `{file_path}`  \n"
        contract += f"**Ports**: {', '.join(port_list)}\n\n"

    # Split Readiness Assessment
    contract += """## Split Readiness Assessment

### Service Boundary Maturity

| Service | API Endpoints | Models | Ports | Split Risk |
|---------|---------------|---------|--------|------------|
"""

    all_services = set()
    all_services.update(service_routes.keys())
    all_services.update(extract_service_name(f) for f in models.keys())
    all_services.update(extract_service_name(f) for f in ports.keys())

    for service in sorted(all_services):
        endpoint_count = len(service_routes.get(service, []))
        model_count = sum(
            len(models[f]) for f in models if extract_service_name(f) == service
        )
        port_count = sum(
            len(ports[f]) for f in ports if extract_service_name(f) == service
        )

        # Simple risk assessment
        if endpoint_count > 5 and model_count > 2:
            risk = "HIGH"
        elif endpoint_count > 2 or model_count > 1:
            risk = "MEDIUM"
        else:
            risk = "LOW"

        contract += (
            f"| {service.title()} | {endpoint_count} | {model_count} "
            f"| {port_count} | **{risk}** |\n"
        )

    contract += """
### Recommendations

1. **Low Risk Services**: Can be split immediately post-MVP
2. **Medium Risk Services**: Require API contract stabilization (1-2 iterations)
3. **High Risk Services**: Defer split until service boundaries mature (3-4 iterations)

### Next Steps

1. Run service dependency analysis: `bash scripts/analyze_service_dependencies.sh`
2. Catalog shared resources: `bash scripts/catalog_shared_resources.sh`
3. Generate repository templates: `bash scripts/generate_repo_templates.sh`

---

*This analysis supports DevOnboarder's strategic repository split planning
for post-MVP service boundary extraction.*
"""

    return contract


def extract_service_name(file_path: str) -> str:
    """Extract service name from file path."""
    path_parts = Path(file_path).parts

    # Common service directory patterns
    service_indicators = [
        "devonboarder",
        "xp",
        "discord_integration",
        "feedback_service",
        "llama2_agile_helper",
        "auth",
        "bot",
        "frontend",
    ]

    for part in path_parts:
        if part in service_indicators:
            return part
        if part.startswith("src"):
            continue

    # Fallback to directory name
    if len(path_parts) > 1:
        return path_parts[1] if path_parts[0] == "src" else path_parts[0]

    return "unknown"


def main():
    """Main execution function."""
    print("DevOnboarder Service Interface Extraction")
    print("=========================================")
    print("Extracting API contracts for strategic repository split assessment")
    print()

    log_file = setup_logging()

    try:
        # Analyze different aspects of services
        print("Extracting FastAPI routes...")
        routes = analyze_fastapi_routes("src")

        print("Analyzing database models...")
        models = analyze_database_models("src")

        print("Identifying service ports...")
        ports = analyze_service_ports("src")

        print("Generating service contract documentation...")
        contract_docs = generate_service_contract_docs(routes, models, ports)

        # Save results
        docs_dir = Path("docs")
        docs_dir.mkdir(exist_ok=True)

        contract_file = docs_dir / "service-api-contracts.md"
        with open(contract_file, "w", encoding="utf-8") as f:
            f.write(contract_docs)

        # Save raw data as JSON for further analysis
        analysis_data = {
            "timestamp": datetime.now().isoformat(),
            "routes": routes,
            "models": models,
            "ports": ports,
        }

        json_file = (
            log_file.parent
            / f"service_interface_data_{datetime.now().strftime('%Y%m%d_%H%M%S')}.json"
        )
        with open(json_file, "w", encoding="utf-8") as f:
            json.dump(analysis_data, f, indent=2)

        print("Service interface extraction complete!")
        print(f"Documentation saved to: {contract_file}")
        print(f"Raw data saved to: {json_file}")
        print(f"Log saved to: {log_file}")
        print()
        print("Summary:")
        print(f"- API routes found: {sum(len(r) for r in routes.values())}")
        print(f"- Database models found: {sum(len(m) for m in models.values())}")
        print(f"- Service ports identified: {sum(len(p) for p in ports.values())}")
        print()
        print("Next steps:")
        print("1. Review generated documentation: docs/service-api-contracts.md")
        print(
            "2. Run dependency analysis: bash scripts/analyze_service_dependencies.sh"
        )
        print("3. Catalog shared resources: bash scripts/catalog_shared_resources.sh")

    except Exception as e:
        print(f"Error during service interface extraction: {e}")
        with open(log_file, "a") as f:
            f.write(f"ERROR: {e}\n")
        return 1

    return 0


if __name__ == "__main__":
    exit(main())
