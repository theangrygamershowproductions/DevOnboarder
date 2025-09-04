import importlib


def test_client_imports():
    try:
        importlib.import_module("devonboarder_ci_client")
    except Exception as e:
        raise AssertionError(f"Client import failed: {e}")
