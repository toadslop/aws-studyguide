+++
title="Load Balancer Connectivity Patterns Part 1: Simple Internal and External"
date=2024-10-17

[taxonomies]
exams = ["Advanced Networking"]
topics = ["network design", "load balancing"]
[extra]
toc = true
comments = true
+++

Hey there, network nut-gatherers! 🐾 It’s Bit again — here to untangle one of my favorite topics: **connectivity patterns for load balancers**.

This is a big topic so we'll split it two -- today we'll look at patterns for simple internal and external load balancers. In an upcoming article, we talk about more complex Hybrid, Multi-Region, and Edge scenarios!

<!--more-->

---

## 🧭 1. The Visibility Spectrum

In AWS, load balancers come in **two main flavors**:

* **Internet-facing** – reachable from the public internet.
* **Internal** – reachable only from within a VPC or through private connections (like VPC Peering or PrivateLink).

The choice affects DNS resolution, target access, and how traffic flows through your architecture.

---

## ☀️ 2. Internet-Facing Load Balancers

| **Scenario**                  | **Design Pattern**             | **Exam Trigger / Clue**                                       |
| ----------------------------- | ------------------------------ | ------------------------------------------------------------- |
| Public web app or API               | **Internet-facing ALB**        | “Must terminate HTTPS; use WAF for protection.”                   |
| Game servers or IoT endpoints | **Internet-facing NLB**        | “Requires static IPs or Elastic IPs for inbound connections.” |

💡 **Why It Matters:**
Internet-facing load balancers expose a **public DNS name** (resolvable via public Route 53) and route to targets in private subnets.
They often handle **TLS termination**, **WAF integration**, and **global routing** through Route 53.

⚠️ **Exam Trap:**
If the question says *“must be accessible only from internal networks”*, **don’t** pick an internet-facing load balancer — even if users connect via VPN. Use an internal LB instead.

---

## 🏠 3. Internal Load Balancers

| **Scenario**                  | **Design Pattern**                     | **Exam Trigger / Clue**                                    |
| ----------------------------- | -------------------------------------- | ---------------------------------------------------------- |
| Microservices within a VPC    | **Internal ALB**                       | “Service-to-service communication within private subnets.” |
| Database proxy or backend API | **Internal NLB**                       | “Needs TCP-level performance and no internet exposure.”    |
| Internal-only web portal      | **Internal ALB + Private Hosted Zone** | “Accessible only to VPC instances or corporate VPN users.” |

💡 **Why It Matters:**
Internal load balancers **don’t get public IPs** — only private ones. They’re essential for secure, private architectures where traffic never goes over the internet.

⚠️ **Exam Trap:**
An “internal” ALB still uses private subnets but can route to **targets in any AZ**. Make sure the subnets used have a route to your backend targets — otherwise, you’ll have silent black holes instead of happy users.

---

## 🔁 4. Cross-VPC Connectivity

Sometimes your acorns (uh, services) are stored across multiple VPCs. That’s when you need to think about **cross-VPC access** patterns.

| **Pattern**                        | **How It Works**                                                              | **Use Case / Exam Clue**                                     |
| ---------------------------------- | ----------------------------------------------------------------------------- | ------------------------------------------------------------ |
| **VPC Peering + Internal NLB/ALB** | Peered VPCs exchange traffic privately using private IPs; load balancer for single app entrypoint and availability | “Two VPCs need full network access to each other, but need a single entrypoint to one or more highly available apps”     |
| **PrivateLink (NLB-based)**        | Provider exposes an endpoint service via NLB; consumer connects via endpoint. | “One-way access between accounts or orgs; no route sharing.” |

💡 **Why It Matters:**

* **PrivateLink** is *provider-to-consumer only* — great for SaaS or cross-account use.
* **VPC Peering** is *bidirectional* — better for full trust or internal app meshes.

⚠️ **Exam Trap:**
PrivateLink **requires an NLB** on the provider side. If the question mentions ALB with PrivateLink — that’s a trick! 🐿️

---

## ⚖️ 5. Cross-Zone Load Balancing

AWS regions have multiple Availability Zones (AZs). Cross-zone balancing decides whether your load balancer sends traffic across AZs or only within one.

| **LB Type** | **Cross-Zone Behavior**         | **Exam Tip**                                                  |
| ----------- | ------------------------------- | ------------------------------------------------------------- |
| **ALB**     | Always enabled; can’t turn off. | “Traffic automatically distributed evenly across AZs.”        |
| **NLB**     | Optional; must be enabled.      | “Traffic only going to one AZ’s targets” → check if disabled. |

💡 **Why It Matters:**
Cross-zone balancing improves distribution but can increase **inter-AZ data transfer costs**.
If the exam says *“minimize inter-AZ charges”*, disable cross-zone on NLB (cross-zone is free for ALB).

---

## 🧠 6. Exam Tips Recap

| **Topic**       | **Remember This for the Exam**                                     |
| --------------- | ------------------------------------------------------------------ |
| Internet-facing | Public DNS name; HTTPS/WAF (for ALB); global access                |
| Internal        | Private IPs; for intra-VPC or VPN users                            |
| Cross-VPC       | NLB + PrivateLink (one-way) vs. ALB/NLB + Peering (full network access between VPCs) |
| Cross-Zone      | ALB = always on, NLB = optional; affects NLB cost                  |
| Security        | Internet-facing ≠ insecure — it’s about **exposure**, not **risk** |

---

## 🌰 Bit’s Final Bite

Load balancers aren’t just traffic directors — they define the app's entrypoint and there impact *who can access it*.
Understand the desired level of visibility first (external or internal) before designing a load balancing solution.
