# CI-First OpenAI API Key Policy

The `OPENAI_API_KEY` secret is only available in GitHub Actions. Workflows use this key to request patches from OpenAI. Avoid storing it in `.env` files or committing it to the repository. Run automation that requires the key through CI so usage is auditable. For occasional local testing, export your own key temporarily and remove it afterward.
