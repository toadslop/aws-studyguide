+++
title="Choosing the Right Load Balancer"
date=2024-10-21

[taxonomies]
exams = ["Advanced Networking"]
topics = ["network design", "load balancing"]
[extra]
toc = true
comments = true
+++

Hey cloud explorers — Bit the Chipmunk here! When an exam question asks “Which load balancer should we use?”, your job is to map **requirements → constraints → the right LB**. This article gives you the decision patterns, quick rules, and exam clues to choose *ALB, NLB,* or *GWLB* (and when to combine them).

<!--more-->

---

## 🧭 Quick decision summary (if you’re in a hurry)

* **ALB (Application Load Balancer)** — Use for **HTTP/HTTPS**, host/path routing, WAF, and Layer-7 features (cookies, headers, OIDC).
* **NLB (Network Load Balancer)** — Use for **high-performance TCP/UDP**, static IPs, or TLS passthrough.
* **GWLB (Gateway Load Balancer)** — Use to **insert inspection appliances** (firewalls/IDS) transparently using GENEVE encapsulation.

---

## 🔎 How to pick — match requirements to LB capabilities

Below are common exam requirements and the reasoning you should use to choose an LB.

### 1) HTTP(S) apps that need smart routing, WAF, or auth

**Choose:** **ALB**
**Why:** ALB is Layer 7 so it can route by host/path, integrate with AWS WAF, and terminate TLS using ACM certs — all examy keywords. Use ALB when you must inspect headers or apply application-level rules.

**Exam clue:** “Route `/api/*` to service A and `/web/*` to service B” → ALB.

---

### 2) Low-latency, high-concurrency TCP/UDP apps or need static IPs

**Choose:** **NLB**
**Why:** NLB is Layer 4, excellent at millions of connections and very low latency. It preserves client source IP (useful for logging/ACLs) and supports static IPs/Elastic IPs — a big plus for firewall rules or hybrid peers. Use NLB for gaming, VoIP, gRPC, or custom protocols.

**Exam clue:** “Require millions of concurrent TCP connections” or “must preserve client IP” → NLB.

---

### 3) Centralized packet inspection (IDS/IPS, enterprise TLS inspection)

**Choose:** **GWLB** + inspection appliances
**Why:** GWLB forwards traffic (GENEVE encapsulation) to appliance fleets without terminating sessions; perfect for transparent inline inspection and enterprise security controls. Use GWLB when you must inspect all ingress/egress traffic centrally.

**Exam clue:** “All traffic must be passed through a firewall farm or IDS for inspection” → GWLB.

---

### 4) Hybrid and private connectivity (on-prem ↔ AWS)

**Pattern:** Use **internal NLB** for private, high-performance endpoints; use **PrivateLink** (NLB-based) or Transit Gateway for cross-account exposure. NLB supports IP targets and works well over Direct Connect or VPN.

**Exam clue:** “On-prem systems need to access a private endpoint hosted on AWS” → internal NLB or PrivateLink.

---

Absolutely — here’s the updated version of that section with the correct order and referencing the AWS doc for layering an ALB behind an NLB:

---

### 5) When You Need Both Layer 7 and Layer 4 Behavior

**Pattern:** Use a **Network Load Balancer (NLB)** up front for static IPs, low-latency or multi-protocol ingress, with an **Application Load Balancer (ALB)** behind it to handle Layer 7 routing (host/path-based) and advanced HTTP features.

**Why:** This layered approach gives you the best of both worlds — the NLB offers high performance, static IPs (or PrivateLink support), and TCP/UDP flexibility while the ALB delivers smart HTTP(S) routing, WAF, and application-level logic.

**Exam clue:**
- “Need host-based routing for HTTP traffic *and* static IPs or multiple protocols on the same endpoint.”

In that case, think **NLB → ALB** rather than ALB in front alone.

Keep in mind that in this pattern, the ALB is often only one of several targets for the NLB — just for those handling HTTP traffic.

---

## ✅ Short decision matrix (use in the exam)

| Requirement                              |                                       Best pick | Why                                                          |
| ---------------------------------------- | ----------------------------------------------: | ------------------------------------------------------------ |
| Host/path routing, WAF, OIDC             |                           ALB. | Layer-7 features and TLS termination.                        |
| Millions of TCP connections, low latency |                           NLB. | Layer-4 performance, preserves source IP.                    |
| Inline security inspection across VPCs   |             GWLB + appliances. | Transparent GENEVE forwarding to appliance fleet.            |
| Private on-prem access, static IPs       | NLB (internal) or PrivateLink. | Works over DX/VPN, supports IP targets.                      |
| Global performance + static entry        |                Global Accelerator + regional NLB or ALB | Use GA when you need static anycast IPs and global failover. |

---

## 🧠 Exam tips and traps

* **Don’t use ALB for raw TCP/UDP** — it’s L7 only. If the workload is non-HTTP (gRPC over TLS can work on ALB if HTTP/2 is used) ALB is not the answer.
* **NLB and ALB both preserve source IP** — handy for firewall rules, logging, or client IP-based logic, but the targets must understand _how_ the IP is preserved as they each handle it differently (Proxy Protocol for NLB, X-Forwarded-For header for ALB)
* **GWLB is the right fit for inspection**, not for app routing — don’t pick it just because you want a “shared” entry point. For shared ingress, the common exam pattern is a central *security* VPC with GWLB.
* **Consider operational needs**: TLS certificate management (ACM), autoscaling target health behavior, cross-zone balancing costs, logging requirements.

---

## 🔧 Real quick examples (exam-style)

1. **Scenario:** Global web app that needs path-based routing, WAF, and TLS managed centrally.
   **Answer:** ALB (internet-facing) + ACM + AWS WAF.

2. **Scenario:** IoT gateway receiving millions of TCP connections with source IPs required for filtering.
   **Answer:** NLB with Elastic IPs and security group/ACL rules.

3. **Scenario:** Enterprise wants all VPC ingress traffic inspected by a third-party firewall farm.
   **Answer:** GWLB + firewall appliances deployed in a security VPC, route traffic via GWLBE endpoints.

---

## 🐿️ Bit’s final nut — quick checklist for the exam

Before you answer:

1. What **protocol** does the app use? (HTTP → ALB; TCP/UDP → NLB)
2. Do you need **L7 features** (WAF, host/path routing, header auth)? → ALB.
3. Need **static IPs**? → NLB.
4. Need to preserve client IP for an HTTP app? → ALB (X-Forwarded-For header)
4. Need to preserve client IP for an non-HTTP app? → NLB (Proxy Protocol)
5. Need **transparent inspection** for security appliances? → GWLB.
6. Does the scenario ask for **private connectivity** (DX/VPN/PrivateLink)? Think **internal** NLB/PrivateLink.

Answer with the LB that matches the principal requirement, and explain **why** in one sentence (that’s the exam style).

---

## 📚 Further reading

* [Application Load Balancers — User Guide (AWS Docs).][1]

* [Network Load Balancers — User Guide (AWS Docs).][2]
* [Gateway Load Balancers — User Guide (AWS Docs).][3]
* [Comparing Application, Network, and Gateway Load Balancers (AWS).][4]
* [AWS Networking Blog: Using load balancer target group health thresholds to improve availability.][6]
* [Getting started with Gateway Load Balancers (AWS).][7]

[1]: https://docs.aws.amazon.com/elasticloadbalancing/latest/application/introduction.html
[2]: https://docs.aws.amazon.com/elasticloadbalancing/latest/network/introduction.html
[3]: https://docs.aws.amazon.com/elasticloadbalancing/latest/gateway/introduction.html
[4]: https://aws.amazon.com/compare/the-difference-between-the-difference-between-application-network-and-gateway-load-balancing/
[6]: https://aws.amazon.com/blogs/networking-and-content-delivery/using-load-balancer-target-group-health-thresholds-to-improve-availability/
[7]: https://docs.aws.amazon.com/elasticloadbalancing/latest/gateway/getting-started.html