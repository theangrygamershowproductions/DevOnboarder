# Maintainer Merge Checklist

Reviewers must verify the following before merging a pull request:

- [ ] All tests and lint checks pass.
- [ ] `docs/CHANGELOG.md` includes an entry for the change.
- [ ] Documentation in `docs/` is updated as needed.
- [ ] Documentation passes `bash scripts/check_docs.sh`.
- [ ] The pull request contains a completed reviewer sign-off section.

After merging large documentation updates, run `bash scripts/check_docs.sh`
locally to ensure the main branch remains lint-free.
