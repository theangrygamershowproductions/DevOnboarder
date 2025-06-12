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
# 🧠 Threat Model - The Angry Gamer Show Productions

## 🗺️ System Overview
- Frontend: React + Vite, hosted on Traefik/TrueNAS
- Auth: Node.js/Express OAuth server (Discord login)
- Discord APIs, Token Exchanges
- User data (profile, roles, preferences)

## 🔓 Entry Points
- Public login page
- OAuth2 redirect/callback
- API routes under /api/
- Webhooks (future: streaming platforms, donations)

## 🧨 Key Threats
- Replay attacks on OAuth callback
- Token leakage via improper headers or CORS
- Brute force login via Discord rate limit bypass
- Malicious input (XSS, injection)

## 🛡️ Mitigations
- Helmet, rate-limiters, secure token scopes
- HTTPS enforced through Traefik
- Express `trust proxy` configured
- JWT expiration + refresh flow planned

## 🔒 Trust Boundaries
- Frontend ⇄ Auth (internal, secured)
- Auth ⇄ Discord (external, verify all responses)
- Web requests ⇄ API (public access, validate deeply)

## 🔐 Assets at Risk
- Discord Access Tokens
- User data and permissions
- OAuth redirect URIs
