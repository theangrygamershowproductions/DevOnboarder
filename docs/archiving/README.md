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
# Creating a Compressed TAR Archive of the `auth` Directory
<!-- PATCHED v0.2.9 docs/archiving/README.md — Use .env.development -->

This document explains how to create a `.tar.gz` archive of the `auth` directory, while excluding all sensitive `.env.*` files, the `node_modules` directory, and the `.git` directory.

## Purpose

We use the `tar` command to bundle and compress the `auth` directory into a single archive for deployment, transfer, or backup. To ensure security and reduce archive size, we exclude environment variable files, `node_modules`, and Git history.

## Command

Run the following command from the parent directory of `auth`:

```bash
tar --exclude='auth/.env.*' --exclude='auth/node_modules' --exclude='auth/.git' -czf auth.tar.gz auth
```

## Explanation

| Flag                            | Description                                                       |
| ------------------------------- | ----------------------------------------------------------------- |
| `--exclude='auth/.env.*'`       | Excludes files like `.env.local`, `.env.development`, etc., inside `auth` |
| `--exclude='auth/node_modules'` | Skips the bulky `node_modules` directory from the archive         |
| `--exclude='auth/.git'`         | Omits the `.git` directory and its history                        |
| `-c`                            | Creates a new archive                                             |
| `-z`                            | Compresses the archive using gzip                                 |
| `-f auth.tar.gz`                | Specifies the filename for the archive                            |
| `auth`                          | Target directory to be archived                                   |

## Verify Archive Contents

To confirm the archive was created properly and unwanted files are excluded:

```bash
tar -tzf auth.tar.gz
```

This lists the archive’s contents without extracting.

## Notes

* Be sure to run the command from the parent directory that contains `auth`.
* You may customize the `--exclude` patterns further to fit your project structure.
* Consider versioning your archives if multiple builds will be kept.

---

# Creating a Compressed TAR Archive of the `frontend` Directory

This section explains how to create a `.tar.gz` archive of the `frontend` directory, while excluding `.env.*` files, the `node_modules` directory, and the `.git` directory.

## Purpose

We use the `tar` command to package the `frontend` directory for transport or backup. As with the `auth` archive, we exclude `.env.*` files, `node_modules`, and Git internals for security and portability.

## Command

Run the following command from the parent directory of `frontend`:

```bash
tar --exclude='frontend/.env.*' --exclude='frontend/node_modules' --exclude='frontend/.git' -czf frontend.tar.gz frontend
```

## Explanation

| Flag                                | Description                                                       |
| ----------------------------------- | ----------------------------------------------------------------- |
| `--exclude='frontend/.env.*'`       | Skips inclusion of files like `.env.production`, `.env.development`, etc. |
| `--exclude='frontend/node_modules'` | Skips the `node_modules` directory to reduce archive size         |
| `--exclude='frontend/.git'`         | Omits the `.git` directory and commit history                     |
| `-c`                                | Creates a new archive                                             |
| `-z`                                | Compresses the archive using gzip                                 |
| `-f frontend.tar.gz`                | Sets the output archive name                                      |
| `frontend`                          | The directory to be included in the archive                       |

## Verify Archive Contents

To ensure the archive was created and unwanted files were excluded:

```bash
tar -tzf frontend.tar.gz
```

This command will list the contents without extracting anything.

## Notes

* Always run this command from the directory directly above `frontend`.
* Adapt the `--exclude` filters if your file naming convention or structure differs.
* Keep archive names consistent and versioned if needed for build tracking.

---

# Alternative: Create a ZIP Archive Instead of TAR

As an alternative to using `.tar.gz`, you can create a `.zip` archive directly. This method also allows you to exclude folders such as `.env.*`, `node_modules`, and `.git`.

## Command

```bash
zip -r auth.zip auth -x "auth/.env.*" "auth/node_modules/*" "auth/.git/*"
zip -r frontend.zip frontend -x "frontend/.env.*" "frontend/node_modules/*" "frontend/.git/*"
```

## Explanation

| Flag/Pattern                                          | Description                         |
| ----------------------------------------------------- | ----------------------------------- |
| `zip -r`                                              | Recursively zip the directory       |
| `auth.zip` / `frontend.zip`                           | Output filename for the ZIP archive |
| `-x`                                                  | Excludes the matching patterns      |
| `"auth/.env.*"` / `"frontend/.env.*"`                 | Excludes all `.env.*` files         |
| `"auth/node_modules/*"` / `"frontend/node_modules/*"` | Excludes `node_modules` directory   |
| `"auth/.git/*"` / `"frontend/.git/*"`                 | Excludes Git history                |

## Notes

* This is an alternative to `.tar.gz`, not a second layer of compression.
* Some platforms (e.g., Windows, certain CI/CD tools) may prefer `.zip` format.

---

Created: `02 May 2025`
