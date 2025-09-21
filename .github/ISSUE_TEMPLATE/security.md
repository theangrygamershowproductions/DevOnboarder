---
name: Security

description: For reporting vulnerabilities, dependency risks, or policy enforcement.
title: "SECURITY: "
labels: ["security"]
---

body:

- type: textarea

  id: description
  attributes:
    label: Description
    description: Describe the security concern, vulnerability, or audit finding.
    placeholder: e.g., Update vulnerable dependency, enforce Potato Policy, report secret exposure.
  validations:
    required: true
