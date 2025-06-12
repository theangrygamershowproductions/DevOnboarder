---
project: "DevOnboarder Codex"
module: "Infrastructure"
phase: "Hardware Planning"
tags: ["budget", "hardware", "minisforum", "cluster", "TCO"]
updated: "06 June 2025 11:45 (EST)"
version: "v1.0.0"
---

# Cluster Budget – Minisforum AI X1 Pro (5-Node Setup)

This document outlines the full 36-month Total Cost of Ownership (TCO) for a 5-node **Minisforum AI X1 Pro** cluster, including hardware, energy usage, and expansion considerations.

---

## 1. 💰 Up-Front Hardware Costs

| Item                                | Qty | Unit Price (USD) | Total (USD) |
| ----------------------------------- | --: | ----------------:| -----------:|
| Minisforum AI X1 Pro (96 GB / 2 TB) |  5  | $899             | $4,495      |
| Uninterruptible Power Supply (UPS)  |  1  | $150             | $150        |
| Managed 5 Port 2.5 GbE Switch       |  1  | $120             | $120        |
| Cat 6a Ethernet Cables (10 ft each) |  5  | $10              | $50         |
| **Subtotal – Hardware**             |     |                  | **$4,815**  |

> ✅ Each X1 Pro includes 96 GB DDR5 RAM and 2 TB NVMe SSD  
> ✅ Networking and power protection are consolidated for cost-efficiency

---

## 2. ⚡ Electricity Costs (Ongoing)

### 2.1 Power Draw

- **Avg Draw per Unit:** ~28 W  
- **Total Cluster Load:** `5 × 28 W = 140 W`

### 2.2 Monthly Usage Estimate

```

0.14 kW × 24 h/day × 30 days ≈ 100.8 kWh/month
100.8 kWh × $0.13/kWh ≈ $13.10 → Rounded to $18 to include UPS overhead

```

| Period     | Monthly Est. | Total Cost |
| ---------- | ------------ | ---------- |
| 12 Months  | $18          | $216       |
| 24 Months  | $18          | $432       |
| 36 Months  | $18          | **$648**   |

---

## 3. 📦 Total Cost of Ownership (TCO – 36 Months)

| Category        | Cost (USD) |
| --------------- | ----------:|
| Hardware        | $4,815     |
| Electricity     | $648       |
| **Total (TCO)** | **$5,463** |

---

## 4. 🧮 Per-Node Breakdown

| Node | Hardware | Power (36mo) | Total (USD) |
| ----:| --------:| ------------:| -----------:|
| 1    | $899     | $129.60      | $1,028.60   |
| 2    | $899     | $129.60      | $1,028.60   |
| 3    | $899     | $129.60      | $1,028.60   |
| 4    | $899     | $129.60      | $1,028.60   |
| 5    | $899     | $129.60      | $1,028.60   |

---

## 5. 🧾 Optional Expenses

| Item                          | Est. Cost (USD) |
| ----------------------------- | ---------------:|
| 2 TB–4 TB NVMe (node expansion) | $100–$200       |
| Business-class router/QoS    | $50–$100         |
| RPC Service (Infura, Alchemy)| TBD              |

> 🛈 Software licenses like **GitHub Advanced Security** are not included but may be added later.

---

## 6. 🔍 Summary

- 🖥 5-node cluster: **60 cores / 120 threads**, **480 GB RAM**, **10 TB NVMe**
- ⚡ Estimated Power Budget: **$18/month**
- 🧮 3-Year Total Cost: **$5,463**
- 💡 Designed for CI, containerized apps, and Web3 workloads

---

