"""Checks that all FastAPI endpoints have docstrings.

Usage: ``python scripts/check_docstrings.py [PATH]``

Provide an optional ``PATH`` to scan a different directory. The default path is
``src/devonboarder``.
"""
import ast
import os
import sys


def has_docstring(node: ast.AST) -> bool:
    return bool(ast.get_docstring(node))


ROUTE_DECORATORS = {
    "get",
    "post",
    "put",
    "delete",
    "patch",
    "options",
    "head",
    "trace",
}


def _is_route_decorator(deco: ast.expr) -> bool:
    """Return True if ``deco`` represents a FastAPI route decorator."""

    call = deco
    if isinstance(deco, ast.Call):
        call = deco.func

    return isinstance(call, ast.Attribute) and call.attr in ROUTE_DECORATORS


def main() -> None:
    api_path = sys.argv[1] if len(sys.argv) > 1 else "src/devonboarder"
    errors: list[str] = []
    for dirpath, _, filenames in os.walk(api_path):
        for filename in filenames:
            if filename.endswith(".py"):
                with open(os.path.join(dirpath, filename), "r") as f:
                    tree = ast.parse(f.read())
                for node in ast.walk(tree):
                    if isinstance(node, ast.FunctionDef):
                        if any(_is_route_decorator(d) for d in node.decorator_list):
                            if not has_docstring(node):
                                errors.append(
                                    f"{filename}:{node.lineno} missing docstring"
                                )
    if errors:
        print("Missing docstrings:\n" + "\n".join(errors))
        exit(1)
    print("All endpoint docstrings present.")


if __name__ == "__main__":
    main()
