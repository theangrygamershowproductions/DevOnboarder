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
<!--
Project: DevOnboarder
File: verification_database.md
Purpose: Schema description for verification tracking
Updated: 07 Jun 2025
Version: v0.1.0
-->

# Verification Database Schema

The backend stores verification requests in a simple SQLite database. The table
`verification_requests` contains the following fields:

| Column            | Type    | Description                                |
|-------------------|---------|--------------------------------------------|
| `id`              | integer | Primary key                                |
| `user_id`         | text    | ID of the requesting user                  |
| `verification_type` | text  | Requested type (gov/mil/edu/None)          |
| `status`          | text    | `pending`, `approved`, or `rejected`       |
| `requested_at`    | datetime | Timestamp when the request was created     |
| `updated_at`      | datetime | Timestamp when the status last changed     |

Use `backend/models/init_db.py` to create the table locally.
