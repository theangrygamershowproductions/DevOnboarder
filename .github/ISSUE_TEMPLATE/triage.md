---
name: Triage

description: For issues that need review or further classification.
title: "TRIAGE: "
labels: ["triage"]
---

body:

- type: textarea

  id: description
  attributes:
    label: Description
    description: Describe why this issue needs triage or clarification.
    placeholder: e.g., Needs more info, unclear scope, requires team input.
  validations:
    required: true
