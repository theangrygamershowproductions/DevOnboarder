# Running the Test Suite

Install the project and its development requirements before executing the tests so Python can resolve all imports:

```bash
pip install -e .
pip install -r requirements-dev.txt
```

Then run `pytest` from the repository root with coverage enabled:

```bash
pytest --cov=src --cov-fail-under=95
```

Use `make test` to run the linter and all test suites at once.

CI requires every suite to maintain **95%** code coverage.

Run JavaScript coverage from the `bot/` and `frontend/` directories:

```bash
npm run coverage
```
