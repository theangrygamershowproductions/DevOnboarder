# Contributing

Please install our commit message hook after cloning:

```bash
bash scripts/install_commit_msg_hook.sh
```

The hook prevents bad commit messages from reaching CI. See [docs/git-guidelines.md](docs/git-guidelines.md) for style
rules and [docs/README.md](docs/README.md) for environment setup tips.

After installing the commit message hook, install our lint hooks so code and documentation are checked automatically:

```bash
pre-commit install
```

Install the Python and Node.js dependencies before running tests or any
`pre-commit` commands. Run `pip install -e .[test]` before executing `pytest`:

```bash
pip install -e .[test]
npm ci --prefix bot
npm ci --prefix frontend
pre-commit install
```

You can run `scripts/dev_setup.sh` to perform these steps automatically, or
`scripts/setup_tests.sh` to install only the Python requirements.
See [docs/dependencies.md](docs/dependencies.md) for the Dependabot update workflow.

See [.codex/Agents.md](.codex/Agents.md) for agent YAML guidelines and notification rules.
Agent files are automatically validated against the schema in `schema/agent-schema.json` during pre-commit and CI.
Run `python scripts/validate_agents.py` to manually validate all agent files.
Refer to [docs/checklists/continuous-improvement.md](docs/checklists/continuous-improvement.md) during each retrospective.

## Continuous Improvement Checklist

Pull requests must include the block from
[`.github/pull_request_template.md`](.github/pull_request_template.md) with the
heading **## Continuous Improvement Checklist**. The CI workflow fails when this
heading is missing. See
[docs/checklists/continuous-improvement.md](docs/checklists/continuous-improvement.md)
for details.
