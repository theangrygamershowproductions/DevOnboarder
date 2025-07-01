# Running the Test Suite

Install the project and its development requirements before executing the tests so Python can resolve all imports:

```bash
pip install -e .
pip install -r requirements-dev.txt
```

Then run `pytest` from the repository root:

```bash
pytest -q
```

Use `make test` to run the linter and all test suites at once.
