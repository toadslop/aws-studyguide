+++
title="Load Balancer Integrations"
date=2024-10-21

[taxonomies]
exams = ["Advanced Networking"]
topics = ["network design", "load balancing"]
[extra]
toc = true
comments = true
+++

Load balancers seldom operate entirely on their own — they integrate with a host of other AWS services. Let's dive into the details on some of the most important integrations for the Advanced Networking Specialty exam!

<!--more-->

---

## 🌍 1. Route 53 — The Traffic Director

**Integration purpose:** DNS-based routing to load balancers.

* Route 53 maps **domain names to ALB/NLB DNS names** (CNAME or alias).
* **Alias records** are preferred — no cost, native AWS integration, and automatic updates when LB IPs change.
* Supports **routing policies** for resilience and performance:

  * **Failover:** Send traffic to standby region/LB when health check fails.
  * **Weighted:** Gradually shift traffic between LBs (e.g., blue/green deployments).
  * **Latency-based:** Route clients to the lowest-latency region.
  * **Geolocation / GeoProximity:** Control user placement by region.
* ✅ **Exam trigger:** “Traffic must fail over automatically if Region A is down.” → **Route 53 + Health Checks + alias record.**

---

## 🚀 2. AWS Global Accelerator — Global Anycast Entry Point

**Integration purpose:** Improve performance and availability for global users.

* Provides **static anycast IPs** that route users to the nearest healthy AWS edge location.
* Integrates directly with **ALB, NLB, or EC2** as endpoints.
* Health checks run continuously across regions.
* Reduces **DNS caching issues**, because clients connect to the same IPs, not region-specific DNS.
* Supports **traffic dials** for gradual cutovers between regions (e.g., migration, testing).
* ✅ **Exam trigger:** “Users in multiple continents; DNS caching causes imbalance.” → **Use Global Accelerator, not Route 53 latency routing.**

---

## ☁️ 3. CloudFront — Edge Caching and TLS Offload

**Integration purpose:** Content delivery and security at the edge.

* CloudFront sits **in front of ALB/NLB** to cache content and terminate TLS.
* Reduces load on backend and accelerates global response time.
* Protects backend from DDoS via **AWS Shield Standard** (included).
* Integrates with **WAF** and **ACM** for layered protection.
* ✅ **Exam trigger:** “Static + dynamic content; global users; minimize latency.” → **Use CloudFront in front of ALB.**

---

## 🔒 4. AWS WAF — Web Layer Security Shield

**Integration purpose:** Protect web apps from malicious HTTP(S) traffic.

* Attaches directly to **ALB**, **CloudFront**, or **API Gateway**.
* Filters at **Layer 7 (HTTP)** with managed rules (SQLi, XSS, bots, etc.).
* You can combine **WAF + ALB** for app-level filtering inside a VPC, or **WAF + CloudFront** for global edge filtering.
* ✅ **Exam trigger:** “Need to block malicious requests before reaching app.” → **WAF at ALB or CloudFront.**

---

## 🔑 5. AWS Certificate Manager (ACM) — TLS Simplified

**Integration purpose:** Manage and deploy SSL/TLS certificates.

* Directly integrates with **ALB, NLB (TLS listeners), and CloudFront**.
* Issues free public certificates for AWS-managed domains.
* Automatically renews certificates — no manual rotation.
* Private certificates (ACM PCA) can secure **internal ALBs/NLBs**.
* ✅ **Exam trigger:** “Need automatic certificate renewal and rotation.” → **Use ACM with LB listener.**

---

## ☸️ 6. Amazon EKS / ECS — Container Service Integration

**Integration purpose:** Route traffic to containers managed by AWS.

### For EKS (Kubernetes):

* Use **AWS Load Balancer Controller** to automatically provision ALB/NLB for Kubernetes `Ingress` or `Service` objects.
* Supports **Ingress routing rules** and **target group binding**.
* Uses **service annotations** to control LB type (internal vs. internet-facing).

### For ECS (Fargate or EC2):

* Integrates directly with ALB/NLB target groups.
* ALB routes HTTP/S traffic to ECS tasks using **dynamic port mapping**.
* NLB supports TCP-based ECS services for high-throughput workloads.
* ✅ **Exam trigger:** “ECS service must scale dynamically behind an ALB.” → **Use ALB with dynamic port mapping.**

---

## 🧱 7. Gateway Load Balancer (GWLB) — The Traffic Inspector

**Integration purpose:** Centralized ingress/egress for network inspection.

* Integrates with **third-party appliances** (firewalls, IDS/IPS) via **GWLB endpoints (GWLBe)**.
* Routes traffic transparently to inspection layer before reaching ALB/NLB or EC2.
* Works across VPCs using **PrivateLink**.
* ✅ **Exam trigger:** “Traffic must be inspected before reaching workloads.” → **Use GWLB + GWLBe in inspection VPC.**

---

## 🧩 8. Putting It All Together

| **Integration**    | **Main Purpose**                | **Common Pairing**     | **Exam Tip**                          |
| ------------------ | ------------------------------- | ---------------------- | ------------------------------------- |
| Route 53           | DNS-based routing, failover     | ALB/NLB                | “Alias record for LB DNS name.”       |
| Global Accelerator | Global entry point, performance | ALB/NLB                | “Static IPs, multi-region app.”       |
| CloudFront         | Edge caching & TLS offload      | ALB                    | “Reduce origin load, add Shield/WAF.” |
| WAF                | Web app protection              | ALB / CloudFront       | “Block malicious HTTP requests.”      |
| ACM                | SSL/TLS lifecycle               | ALB / NLB / CloudFront | “Automatic cert renewal.”             |
| EKS/ECS            | Service discovery               | ALB/NLB                | “Dynamic scaling for containers.”     |
| GWLB               | Central inspection              | NLB or PrivateLink     | “Inspect before reaching app.”        |

---

## 💡 Bit’s Final Exam Tips

* “**Traffic from multiple countries needs static IPs**” → **Global Accelerator.**
* “**Need to block SQL injection at edge**” → **CloudFront + WAF.**
* “**Internal microservices over HTTPS**” → **Private ALB + ACM PCA.**
* “**Dynamic container ports**” → **ALB + ECS Service discovery.**
* “**Traffic must be inspected before backend**” → **GWLB + PrivateLink.**
* “**Failover to backup region**” → **Route 53 Failover Policy.**
