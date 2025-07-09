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

The hook prevents bad commit messages from reaching CI. See
[docs/git-guidelines.md](docs/git-guidelines.md) for style rules and
[docs/README.md](docs/README.md) for environment setup tips.
See [docs/dependencies.md](docs/dependencies.md) for the Dependabot update workflow.
