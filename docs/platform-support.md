---
project: "TAGS"
module: "Documentation Tools"
phase: "Maintenance Automation"
tags: ["metadata", "markdown", "indexing", "automation"]
updated: "12 June 2025 09:33 (EST)"
version: "v1.2.6"
author: "Chad Allan Reesey (Mr. Potato)"
email: "education@thenagrygamershow.com"
description: "Manages indexing and metadata injection for project documentation."
---

# Documentation Tools – Maintenance Automation
<!-- PATCHED v0.1.0 docs/platform-support.md — supported platforms -->

<!--
Project: DevOnboarder
File: platform-support.md
Purpose: Outline officially supported development platforms
Updated: 15 Aug 2025
Version: v0.1.0
-->

# Platform Support

DevOnboarder can run on multiple environments. The following setups are tested
regularly.

## WSL2

Windows users can develop using **WSL2** with Ubuntu. Ensure Docker Desktop is
configured to expose the Docker engine to WSL2 and install the project
dependencies inside the Linux environment.

## Ubuntu

Native Linux machines using **Ubuntu 22.04** are fully supported.
Install Docker and Node.js with the setup scripts or the DevContainer.

## GitHub Codespaces

For a browser-based approach, open the repository in **GitHub Codespaces**.
The DevContainer installs dependencies and hooks automatically.
This provides the same experience as a local setup.
