# Environment Maintenance

Use `scripts/regenerate_env_docs.py` whenever you update any `.env.example` file.
The script parses the example files and rewrites the environment variable table
in `agents/index.md`.

```bash
python scripts/regenerate_env_docs.py
```

CI runs this command automatically before validating the docs, but running it
locally ensures the documentation stays current.
