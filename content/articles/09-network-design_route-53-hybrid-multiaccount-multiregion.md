+++
title="Route 53 for Hybrid, Multi-account, and Multi-region Scenarios"
date=2024-10-13

[taxonomies]
exams = ["Advanced Networking"]
topics = ["network design", "DNS", "Route 53", "multi-account", "multi-region"]
[extra]
toc = true
comments = true
+++

Hey there, cloud adventurers! 🏔️
It’s me, **Bit the Chipmunk**, your study buddy for AWS networking. Today we’re diving into **how Route 53 handles private DNS** — inside AWS, across accounts, across Regions, and even with your on-prem network.

<!--more-->

Private DNS is like your **company’s internal phone book** — only the right folks should see it, and it should work whether you’re in the cloud, the data center, or somewhere in between.

If the exam mentions phrases like *“internal name resolution,” “VPC-to-VPC communication,”* or *“on-prem DNS integration,”*—that’s your cue to think **Route 53 Private Hosted Zones** and **Route 53 Resolver**.

---

## 🧩 1. Private DNS Within AWS

**Route 53 Private Hosted Zones (PHZs)** provide DNS that’s only visible to the VPCs you associate with.

| Concept                       | Key Idea                                                                    | Exam Signal                                           |
| ----------------------------- | --------------------------------------------------------------------------- | ----------------------------------------------------- |
| **Private Hosted Zone (PHZ)** | A DNS zone visible only to associated VPCs.                                 | “EC2 instances must resolve internal service names.”  |
| **VPC Association**           | PHZs are attached to one or more VPCs; only those VPCs can resolve records. | “Instances in other accounts can’t resolve the zone.” |
| **Cross-Account Sharing**     | Use **AWS Resource Access Manager (RAM)** to share PHZs across accounts.    | “Central DNS account shares zones to app accounts.”   |

🧠 **Exam Tip:**

> Private Hosted Zones are **VPC-scoped**, not account-scoped or Region-global. If you want multiple VPCs (or accounts) to use the same internal DNS, you must **associate each VPC** explicitly.

---

## 🛰️ 2. Hybrid DNS – Connecting AWS and On-Premises

When your DNS world spans **AWS and on-prem**, Route 53 **Resolvers** act as the bridge.

| Component                        | Direction                                              | Description                                                                   | Exam Signal                                       |
| -------------------------------- | ------------------------------------------------------ | ----------------------------------------------------------------------------- | ------------------------------------------------- |
| **Inbound Resolver Endpoint**    | On-prem ➡️ AWS                                         | Allows on-prem DNS servers to query AWS PHZs.                                 | “On-prem servers must resolve AWS private names.” |
| **Outbound Resolver Endpoint**   | AWS ➡️ On-prem                                         | Allows EC2 instances to resolve on-prem domains (via conditional forwarding). | “EC2 needs to resolve corp.local records.”        |
| **Conditional Forwarding Rules** | AWS ➡️ On-prem | Define which domains route through outbound endpoints. | “Send corp.local queries to on-prem.”                                         |                                                   |

🧠 **Exam Tip:**

> On-prem DNS **cannot** see AWS private records unless you create an **inbound resolver endpoint** and configure your on-prem DNS to forward requests there.

---

## 🌐 3. Multi-Region Private DNS in AWS

Private DNS is **not global** — each PHZ is **Region-bound** to the VPCs it’s associated with.
In a **multi-Region** design, you need to **replicate your PHZs** or use **custom resolution** patterns.

| Pattern                                               | Description                                                                                           | When to Use                                                |
| ----------------------------------------------------- | ----------------------------------------------------------------------------------------------------- | ---------------------------------------------------------- |
| **Independent PHZ per Region**                        | Each Region has its own PHZ with identical records.                                                   | Redundant regional deployments with local resolution.      |
| **Centralized PHZ with Inter-Region VPC Association** | Use **inter-Region VPC association** (supported for PHZs) so VPCs in other Regions can resolve names. | When you want a single source of DNS truth across Regions. |
| **Route 53 Resolver Endpoints per Region**            | Deploy endpoints regionally for HA and low latency.                                                   | Multi-Region hybrid DNS.                                   |

🧠 **Exam Tip:**

> As of now, **Private Hosted Zones can be associated across Regions**, but **the traffic still stays within the AWS DNS resolver in each Region** — no global propagation.

---

## 4. Split-Horizon DNS

Sometimes you want the **same domain name** to resolve **differently inside and outside AWS** — for example:

* From the internet: `api.example.com → CloudFront`
* From within AWS: `api.example.com → internal ALB`

That’s called **Split-Horizon DNS** (or Split-View DNS).
You accomplish it by creating **both a public and a private hosted zone** for the same domain name.

| Component               | Description                             | Why It Matters                            |
| ----------------------- | --------------------------------------- | ----------------------------------------- |
| **Public Hosted Zone**  | Handles external DNS (public internet). | External users reach the public endpoint. |
| **Private Hosted Zone** | Handles internal DNS (VPC-only).        | Internal services use internal endpoints. |

🧠 **Exam Tip:**

> Route 53 automatically handles **which zone to answer from** based on the source of the query (VPC resolver vs public DNS).
> This is a **common exam scenario** — “The same domain name resolves differently for internal vs external clients.”

---

## 🧱 5. Key Exam Patterns to Recognize

| Scenario                                                       | Correct Design                                              |
| -------------------------------------------------------------- | ----------------------------------------------------------- |
| EC2 instances can’t resolve private names in another account   | Share PHZ via **RAM**                                       |
| On-prem cannot resolve AWS private names                       | Create **inbound resolver endpoint**                        |
| AWS instances can’t resolve on-prem names                      | Create **outbound resolver + forwarding rules**             |
| Same domain must resolve differently internally and externally | **Split-horizon DNS**                                       |
| Multi-Region private DNS required                              | Use **inter-Region PHZ association** or **duplicate zones** |

---

## 🐿️ Bit’s Nutshell Summary

- **Private DNS = PHZs**
- **Hybrid = Route 53 Resolvers (inbound/outbound)**
- **Multi-Region = Inter-Region associations or zone replication**
- **Split-Horizon = Same domain, different answers**

💡 **Final Exam Tip:**
When you see “internal resolution,” “cross-account VPC,” or “on-prem DNS integration,” immediately think **Private Hosted Zones + Resolver Endpoints**.
If the same name resolves differently inside and outside AWS — that’s **Split-Horizon** every time!
