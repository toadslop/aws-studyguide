+++
title="Load Balancer Connectivity Patterns Part 2: External"
date=2024-10-17

[taxonomies]
exams = ["Advanced Networking"]
topics = ["network design", "load balancing"]
[extra]
toc = true
comments = true
+++

Hiya! Bit the Chipmunk here — your friendly AWS study buddy!
Today we’re heading **out to the edge** — exploring how **external load balancers** connect users to your applications from the **internet** and beyond.

<!--more-->

These are the patterns that make your apps **available, scalable, and secure** when real users are hitting your endpoints.
Let’s dive in! 🌊

---

## 🌍 1. Internet-Facing Load Balancing (Public Entry Point)

This is the most common setup:
Internet users connect to an **Application Load Balancer (ALB)** or **Network Load Balancer (NLB)** placed in **public subnets**.
Those load balancers then route to private targets — your EC2 instances, containers, or IPs inside private subnets.

| **Use Case**                 | **Pattern**                                 | **Exam Trigger**                                                    |
| ---------------------------- | ------------------------------------------- | ------------------------------------------------------------------- |
| Public web app or REST API   | ALB in public subnets + private EC2 targets | “Users access via the internet, but instances must remain private.” |
| High-performance TCP/UDP app | NLB in public subnets + private targets     | “App needs static IPs or ultra-low latency.”                        |

💡 **Bit’s Tip:**
For questions mentioning *“internet-facing endpoint but private backends,”* your best answer is **public ALB or NLB** with **private targets**.
The load balancer provides the **security boundary** — it’s public on the front, private behind!

---

## 🌎 2. Multi-Region Public Entry (Global High Availability)

When users are worldwide, AWS lets you distribute traffic across Regions for **latency-based performance** and **resiliency**.
You’ll do this with **Route 53** and **regional load balancers**.

| **Use Case**                     | **Pattern**                                          | **Exam Trigger**                      |
| -------------------------------- | ---------------------------------------------------- | ------------------------------------- |
| Global web app                   | ALB or NLB in each Region + Route 53 latency routing | “Direct users to the closest Region.” |
| Active-passive disaster recovery | ALB/NLB in each Region + Route 53 failover policy    | “Fail over traffic between Regions.”  |

💡 **Bit’s Tip:**
Route 53 routing policies (like *latency*, *weighted*, or *failover*) control which Region’s load balancer receives user traffic.
If the question says *“must route users to the nearest AWS Region”* or *“must fail over between Regions,”* Route 53 + multiple ALBs/NLBs is your friend.

---

## 🚀 3. Edge-Optimized and Accelerated Patterns

For global performance, AWS provides services that bring your load balancers **closer to your users** — either by caching or accelerating network paths.

| **Use Case**                         | **Pattern**                             | **Exam Trigger**                            |
| ------------------------------------ | --------------------------------------- | ------------------------------------------- |
| Global HTTPS web app                 | CloudFront (edge) + Regional ALB origin | “Reduce latency and offload TLS from ALB.”  |
| Non-HTTP traffic (e.g., gaming, VPN) | Global Accelerator + Regional NLB       | “Users worldwide need fast TCP/UDP access.” |

💡 **Bit’s Tip:**

* **CloudFront** is perfect for web content and APIs — it terminates TLS, caches responses, and integrates with ALBs.
* **Global Accelerator** is protocol-agnostic — it uses AWS’s global network to optimize TCP/UDP paths directly to your load balancer.
  If the question says *“minimize latency for global users”* → look for one of these edge solutions.

---

## 🧭 4. Cross-Account or Shared-Service Entry Points

In multi-account AWS environments, you might want a **centralized entry point** for all internet-facing traffic.
That’s where **shared load balancers** and **central ingress VPCs** come in.

| **Use Case**                          | **Pattern**                                                 | **Exam Trigger**                                                        |
| ------------------------------------- | ----------------------------------------------------------- | ----------------------------------------------------------------------- |
| Central ingress for multiple accounts | Shared ALB or NLB via AWS Resource Access Manager (RAM)     | “Multiple accounts must share one internet-facing entry point.”         |
| Centralized security or inspection    | NLB in a shared ‘security VPC’ fronting firewall appliances | “All incoming internet traffic must be inspected before reaching apps.” |

💡 **Bit’s Tip:**
This is your pattern for **hub-and-spoke architectures**.
If the question says *“central ingress point,” “shared services VPC,”* or *“common security layer,”* think **shared ALB/NLB**.

---

## 🧠 Exam Recap: Spot the Connectivity Clues

| **Clue in question**                           | **Likely Pattern**              |
| ---------------------------------------------- | ------------------------------- |
| “Users access from the internet”               | Public ALB/NLB                  |
| “Route users to the nearest Region”            | Route 53 latency routing + NLB/ALB |
| “Global low-latency access to non-HTTP app”    | Global Accelerator + NLB        |
| “Consolidate all inbound traffic in one place” | Centralized ingress VPC using ALB/NLB + TGW or PrivateLink for inter-VPC connectivity |
| “Consolidate traffic through a single inspection layer” | Ingress VPC with Network Firewall/Gateway Load Balancer + security appliance |
| “Offload TLS and cache for global web users”   | CloudFront + ALB origin         |
| “Private instances behind public endpoint”     | ALB or NLB with private targets |

---

## 🐿️ Bit’s Closing Thought

External load balancers are your **front doors** to AWS applications — and AWS gives you a whole toolbox for controlling **where**, **how**, and **who** can walk through that door.

> Choose the right pattern based on **who’s connecting**, **from where**, and **how public** your entry point needs to be.
