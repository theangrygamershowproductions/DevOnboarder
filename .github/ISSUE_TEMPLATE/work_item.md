# Work Item Template

name: Work Item
description: General purpose work item tracker for actionable tasks
title: "[Work Item] "
labels: [work-item]
assignees: []

body:

- type: markdown

  attributes:
    value: |
      ## Summary Description

      Please provide a short summary of the task or request.

- type: textarea

  id: steps
  attributes:
    label: Steps to Reproduce
    description: Describe how to reproduce the issue, if applicable.
    placeholder: |
      1. Go to ...

      2. Click on ...

      3. Observe ...

  validations:
    required: false

- type: textarea

  id: outcome
  attributes:
    label: Expected Outcome
    description: What should happen when this task is complete?
    placeholder: Describe the desired end state.
  validations:
    required: false

- type: textarea

  id: criteria
  attributes:
    label: Acceptance Criteria
    description: What conditions must be met for this to be considered complete?
    placeholder: Bullet out requirements if possible.
  validations:
    required: false
