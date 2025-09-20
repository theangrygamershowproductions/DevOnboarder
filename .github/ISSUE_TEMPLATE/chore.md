---
name: Chore

description: For maintenance, refactoring, or non-feature/non-bug work.
title: "CHORE: "
labels: ["chore"]
---

body:

- type: textarea

  id: description
  attributes:
    label: Description
    description: Describe the maintenance or refactoring task.
    placeholder: e.g., Update dependencies, refactor code, improve CI config.
  validations:
    required: true
