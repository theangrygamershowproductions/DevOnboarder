---
project: "TAGS Studios"
module: "Infrastructure Planning"
phase: "Design"
tags: ["blueprint", "project-aurora", "k8s", "gpu", "devops"]
updated: "15 September 2025 00:00 (EST)"
version: "v0.1.0"
---
<!-- markdownlint-disable-file MD041 -->

# Project Aurora Blueprint

## 📌 Purpose

This document outlines the reference infrastructure for **Project Aurora**,
the AI-driven game framework under TAGS Studios.
It provides a high-level deployment plan focused on GPU compute resources
and container orchestration.

---

## 🏗 Architecture Overview

* **Cluster**: Kubernetes with GPU scheduling via `nvidia-device-plugin`
* **Compute Nodes**: 8× NVL72 servers with InfiniBand networking
* **Storage**: CephFS for scalable asset distribution
* **CI/CD**: GitHub Actions deploying to a private registry

---

## 🚀 Deployment Steps

1. Provision the Kubernetes control plane with HA etcd.
2. Join GPU nodes using the TAGS base image.
3. Install monitoring via Prometheus and Grafana.
4. Deploy Aurora microservices using Helm charts.
