+++
title="Evaluating Global Network Requirements"
date=2024-10-11

[taxonomies]
exams = ["Advanced Networking"]
topics = ["network design", "CDN", "DNS", "CloudFront", "Global Accelerator", "Route53"]
[extra]
toc = true
comments = true
+++

Given specific requirements, choose the correct content distribution solution.

<!--more-->

---

## 1. Core Task

> **Goal:** Evaluate global traffic requirements and design a solution that leverages **edge network services** to optimize user performance, availability, and traffic management.

**Key AWS services to consider:**

* **Amazon CloudFront** – Global CDN, Layer 7 HTTP/HTTPS acceleration, caching, WAF/DDoS protection.
* **AWS Global Accelerator** – Layer 4 TCP/UDP acceleration, static anycast IPs, fast failover across regions.
* **Amazon Route 53** – DNS-based routing, geo/latency/weighted policies for directing traffic.

---

## 2. Step 1 — Identify User Requirements

When designing a solution, first identify **traffic and user requirements**:

| Requirement Example                                          | Design Implication                | Notes                                                                     |
| ------------------------------------------------------------ | --------------------------------- | ------------------------------------------------------------------------- |
| Users worldwide accessing a web app (HTTP/HTTPS)             | Low-latency delivery and caching  | CloudFront can cache static/dynamic content globally, reduce origin load. |
| Users need consistent IP addresses for whitelisting          | Static IPs                        | Global Accelerator provides static anycast IPs.                           |
| Non-HTTP protocols (e.g., gaming TCP/UDP)                    | Layer 4 acceleration              | Global Accelerator is appropriate.                                        |
| Traffic must be routed to nearest or healthiest region       | Latency-based routing or failover | Route 53 latency-based routing or weighted routing.                       |
| Multi-region app with failover                               | Automatic health-based failover   | CloudFront Origin Groups or Global Accelerator endpoint groups.           |
| API responses need caching and DDoS protection               | Edge caching and security         | CloudFront in front of API Gateway (edge-optimized).                      |
| Compliance requirement: users in EU only access EU resources | Geographic restriction            | CloudFront geo-restriction or Route 53 geolocation routing.               |

---

## 3. Step 2 — Map Requirements to AWS Edge Network Services

### a. **Amazon CloudFront**

**When to use:**

* Global distribution of HTTP/HTTPS content (static and dynamic).
* Caching content near users to reduce latency and origin load.
* Security: integrate **WAF**, **Shield**, **TLS**, **signed URLs/cookies**.

**Patterns:**

* CloudFront → ALB → EC2/ECS/EKS (dynamic apps)
* CloudFront → S3 (static content)
* CloudFront → API Gateway (REST APIs)

---

### b. **AWS Global Accelerator**

**When to use:**

* Applications using TCP/UDP protocols or non-cacheable dynamic content.
* Requirement for **static IP addresses**.
* Fast failover across multiple regions.

**Patterns:**

* Global Accelerator → ALB/NLB (multi-region)
* Global Accelerator → API Gateway (regional endpoints)
* Global Accelerator + CloudFront (when IP whitelisting is needed for cached HTTP content)

---

### c. **Amazon Route 53**

**When to use:**

* DNS-based global routing and traffic management.
* Requirements for latency-based, weighted, or geolocation routing.
* Compliance-driven regional routing.
* Budget is limited

**Patterns:**

* Route 53 → CloudFront (custom domain alias)
* Route 53 → Global Accelerator (domain pointing to static anycast IPs)
* Route 53 → ALB/API Gateway (multi-region traffic management)

---

## 4. Step 3 — Combined Design Patterns

| User Requirement                        | Service Pattern                                    | Why                                                    |
| --------------------------------------- | -------------------------------------------------- | ------------------------------------------------------ |
| Static + dynamic web content worldwide  | CloudFront → ALB → EC2                             | Low latency, caching, edge TLS, WAF protection         |
| REST API for global clients             | CloudFront → API Gateway                           | Edge caching, DDoS protection, low-latency HTTP access |
| Real-time gaming / TCP/UDP apps         | Global Accelerator → NLB                           | Static IPs, Layer 4 acceleration, sub-second failover  |
| Multi-region active-active architecture | Global Accelerator → multiple ALBs → EC2           | Fast failover, traffic weighting by region health      |
| Users must stay within specific regions | Route 53 geolocation routing → regional ALB/API GW | Regulatory or compliance control over traffic          |
| Static content + IP whitelisting        | Global Accelerator → CloudFront → S3               | Accelerated delivery + static IPs for firewall rules   |

---

## 5. Exam Tips

* **Layer awareness:**

  * CloudFront = Layer 7, caching + HTTP acceleration
  * Global Accelerator = Layer 4, IP-level acceleration, static IPs
  * Route 53 = DNS-level routing, latency/geolocation/weighted policies
* **Security layers:** CloudFront/WAF/Shield for HTTP, GA for TCP/UDP, TLS for encrypted delivery.
* **Failover & multi-region:** Use **Origin Groups** (CloudFront), **Endpoint Groups** (Global Accelerator), or **Route 53 routing policies**.
