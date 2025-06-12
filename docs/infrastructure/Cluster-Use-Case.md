---

project: "TAGS Studios"
module: "Infrastructure Planning"
phase: "Pre-Alpha"
tags: \["tags-studios", "infrastructure", "project-aurora", "scaling", "nvl72", "ms-01", "n5pro", "devops", "ai"]
updated: "31 May 2025 11:28 (EST)"
version: "v2.0.0"
-----------------

# TAGS Studios – Infrastructure Deployment Blueprint

## 📌 Purpose

This blueprint provides a scalable and secure infrastructure model for **all divisions under TAGS Studios**, including centralized services and project-specific resource allocation. Project Aurora (AI-driven game platform) is included as a specialized module with GPU-intensive compute requirements.

---

## 🧱 Facility Power & Cooling Readiness Checklist (Global Applicability)

### ⚡ Power Requirements

* [ ] 480V 3-phase AC electrical service available
* [ ] 120kW continuous draw per NVL72 supported
* [ ] Dedicated transformer or subpanel provisioning
* [ ] Power Distribution Unit (PDU) compatibility check
* [ ] Generator backup for Tier 3/Tier 4 redundancy
* [ ] Dual UPS systems (N+1 or 2N configuration preferred)

### ❄️ Cooling Requirements

* [ ] Liquid cooling infrastructure or compatibility
* [ ] Chilled water or direct-to-chip cooling system
* [ ] Redundant HVAC systems with independent zoning
* [ ] Environmental sensors for temperature and humidity
* [ ] Raised flooring or hot/cold aisle containment

### 🔐 Security & Compliance

* [ ] Controlled physical access (badge, biometric, or PIN)
* [ ] Server room surveillance and monitoring
* [ ] Fire suppression system (non-destructive gas type preferred)
* [ ] Rack-level locking and access logging
* [ ] Compliance: NIST, ISO 27001, or FedRAMP (optional)

### 📡 Networking & Connectivity

* [ ] 100G uplink or distributed 10G/40G switching
* [ ] Dual-homed internet or private fiber connections
* [ ] Isolated VLAN for AI compute traffic
* [ ] Remote KVM or IPMI access provisioning
* [ ] DNS, DHCP, NTP, and IPAM readiness

---

## 🧩 Shared Infrastructure Roles Across TAGS

| Role                             | Device(s)    | Qty | Notes                                                 |
| -------------------------------- | ------------ | --- | ----------------------------------------------------- |
| Shared Firewall/Gateway          | N5 Pro       | 2   | Manages all inter-network VLAN segmentation           |
| DevOps Runner Pool               | N5 Pro       | 10  | Shared between active development projects            |
| Build & CI/CD Servers            | MS-01        | 2   | Shared pipeline for builds, containers, packages      |
| Internal Bastion / Audit Node    | MS-01 (Xeon) | 1   | Jump host, SSH audit, SSO enforcement                 |
| App Hosting / ERP / Portal       | MS-01        | 1   | ERPNext, Studio Portal, HR systems                    |
| Monitoring & Observability Stack | N5 Pro       | 2   | Grafana, Prometheus, Loki, system-wide alerting       |
| Documentation & NAS/Backup       | MS-01        | 2   | Nextcloud, MinIO, rsync archive, IP-restricted access |

---

## 🎮 Project-Specific Resource Breakdown

### Project Aurora (AI Game Framework)

| Role                         | Device(s)          | Qty | Notes                                       |
| ---------------------------- | ------------------ | --- | ------------------------------------------- |
| AI Model Training            | NVIDIA GB200 NVL72 | 2   | Dev + Production tiers                      |
| Game Logic / World State     | MS-01              | 1   | Real-time logic + server sync               |
| Proxy / Gateway Layer        | N5 Pro             | 2   | API management and traffic control          |
| Dev/Test/Assets + Tools      | N5 Pro             | 3   | Build tools, test environments, web preview |
| Project Dashboards & Metrics | N5 Pro             | 1   | Custom Grafana dashboards for Aurora only   |

### Project ASoS Gaming (MMO & GameDev)

| Role                          | Device(s) | Qty | Notes                                       |
| ----------------------------- | --------- | --- | ------------------------------------------- |
| Mod Toolchain / CDN Cache     | MS-01     | 1   | Game mod/asset processing + cached delivery |
| Emulator Lab / Private Server | N5 Pro    | 2   | Local multiplayer tests, sandboxing         |
| Build/Test Integration        | N5 Pro    | 2   | Continuous build/test pipeline              |

### TAGS Web Platform

| Role                | Device(s) | Qty | Notes                                           |
| ------------------- | --------- | --- | ----------------------------------------------- |
| Frontend Hosting    | N5 Pro    | 1   | Vite/React Shadcn stack                         |
| Backend Auth & APIs | MS-01     | 1   | Discord OAuth, role management, session control |
| Admin Tools + CMS   | N5 Pro    | 1   | Content editors, markdown tools, patch notes    |

---

## 📦 Procurement Phases (Updated)

### Phase 1 – Core Foundation

* [x] 2× N5 Pro (Firewall + VLAN control)
* [x] 2× N5 Pro (Monitoring, DNS, Metrics)
* [ ] 1× MS-01 (Admin + Auth)

### Phase 2 – Dev & CI/CD Stack

* [ ] 5–10× N5 Pro (Runner cluster)
* [ ] 2× MS-01 (Build servers)

### Phase 3 – Project Resource Pools

* [ ] 2× MS-01 (Aurora + ASoS)
* [ ] 6× N5 Pro (Aurora/ASoS split)

### Phase 4 – AI Infrastructure

* [ ] 2× NVIDIA GB200 NVL72
* [ ] Facility upgrades to support NVL72

---

Let me know when you'd like a printable version, Git-tracked change log, or an investor/partner-friendly summary of this infrastructure plan.
