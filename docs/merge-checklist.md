# Maintainer Merge Checklist

Reviewers must verify the following before merging a pull request:

-   [ ] All tests and lint checks pass.
-   [ ] `docs/CHANGELOG.md` includes an entry for the change.
-   [ ] Documentation in `docs/` is updated as needed.
-   [ ] Documentation passes `bash scripts/check_docs.sh`.
-   [ ] Environment variable docs match `.env.example` files via
        `python scripts/check_env_docs.py`.
-   [ ] Run `make openapi` if API routes changed to update `openapi.json`.
-   [ ] The pull request contains a completed reviewer sign-off section.
-   [ ] Secret variable issues use the [Secret Alignment template](../.github/ISSUE_TEMPLATE/secret-alignment.md).
-   [ ] Assessment reviews use the [Engineer Assessment template](../.github/ISSUE_TEMPLATE/assessment.md).

After merging large documentation updates, run `bash scripts/check_docs.sh`
locally to ensure the main branch remains lint-free.
