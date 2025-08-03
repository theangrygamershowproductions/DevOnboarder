---
name: CI/CD
description: For CI/CD pipeline, workflow, or automation issues.
title: "CI: "
labels: ["ci/cd"]
---

body:

- type: textarea
  id: description
  attributes:
    label: Description
    description: Describe the CI/CD or automation issue.
    placeholder: e.g., Fix failing workflow, update pipeline, improve automation.
  validations:
    required: true
