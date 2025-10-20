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

## 🧭 4. Centralized Ingress and Egress

When multiple VPCs (or even accounts) need to enter or leave the AWS network through a single inspection point, AWS gives you the Gateway Load Balancer (GWLB).
Think of it as a traffic checkpoint — packets come in, get inspected by security appliances (firewalls, IDS/IPS), and then continue on their journey. This is very different from how ALB/NLB work. ALB/NLB forward traffic to its destination; GWLB forwards traffic to an intermediary service before sending it on its way.

### 🧩 How It Works

- A GWLB is deployed in a dedicated “inspection” or “security” VPC.
- Network appliances (like firewalls or intrusion detection systems) run behind the GWLB.
- Gateway Load Balancer Endpoints (GWLBE) live in the ingress/egress VPC — the one handling internet connectivity or cross-network routing.
- Traffic from application VPCs reaches the inspection layer via Transit Gateway or VPC peering before being directed through the GWLBE → GWLB → appliance path.

The GWLB preserves flow symmetry — every packet in a session follows the same path through the same appliance.

| **Use Case**                                     | **Design Pattern**                                                | **Exam Trigger**                                                                     |
| ------------------------------------------------ | ----------------------------------------------------------------- | ------------------------------------------------------------------------------------ |
| Centralized inbound inspection                   | GWLB in security VPC + GWLBE in ingress VPC                       | “All internet-bound traffic must pass through a firewall before reaching workloads.” |
| Centralized outbound inspection (egress control) | GWLB + NAT Gateway + route table directing through inspection VPC | “Outbound internet traffic must be inspected or logged.”                             |


#### 💡 Bit’s Tip:
If you see a question saying “traffic from multiple VPCs or accounts must be inspected before reaching the internet,” your answer is Gateway Load Balancer.
If the question says “must route traffic to a shared firewall VPC without exposing the appliances,” again — GWLB is the right choice.

But! If Gateway Load Balancer is not an option, look for AWS Network Firewall — it's an AWS native network firewall that can be used instead of GWLB + third-party newtork appliance.

---

## 🧠 Exam Recap: Spot the Connectivity Clues

| **Clue in question**                           | **Likely Pattern**              |
| ---------------------------------------------- | ------------------------------- |
| “Users access from the internet”               | Public ALB/NLB                  |
| “Route users to the nearest Region”            | Route 53 latency routing + NLB/ALB |
| “Global low-latency access to non-HTTP app”    | Global Accelerator + NLB        |
| “Consolidate all inbound/outbound traffic in one place” | Centralized ingress VPC using GWLB for traffic inspection |
| “Offload TLS and cache for global web users”   | CloudFront + ALB origin         |
| “Private instances behind public endpoint”     | ALB or NLB with private targets |

---

## 🐿️ Bit’s Closing Thought

External load balancers are your **front doors** to AWS applications — and AWS gives you a whole toolbox for controlling **where**, **how**, and **who** can walk through that door.

> Choose the right pattern based on **who’s connecting**, **from where**, and **how public** your entry point needs to be.
