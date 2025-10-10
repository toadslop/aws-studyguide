+++
title="Content Delivery Networks"
date=2024-10-10

[taxonomies]
exams = ["Advanced Networking"]
topics = ["network-design", "cdn", "cloudfront", "edge networking"]
[extra]
toc = true
comments = true
+++

Learn design patterns for the usage of content distribution networks (for example, Amazon CloudFront)

<!--more-->

---

## 🧭 Overview

At a high level, the exam tests your ability to:

* **Design efficient, secure, and scalable architectures using CloudFront**
* **Optimize** both static and dynamic content delivery
* **Integrate** CloudFront correctly with origins (S3, ALB, API Gateway, etc.)
* **Secure and tune** behavior for latency, cost, and reliability

You’re expected to recognize when CloudFront is **the right tool**, what its **advantages and limitations** are, and how it **interacts with other AWS networking and security services**.

---

## ☁️ 1. Core Concepts of Amazon CloudFront

| Concept          | What You Need to Know for the Exam                                                                                           |
| ---------------- | ---------------------------------------------------------------------------------------------------------------------------- |
| **Purpose**      | A global content delivery network (CDN) that caches content at AWS edge locations to **reduce latency** and **improve performance**. |
| **Scope**        | CloudFront is a **global** service with **regional edge caches** (RECs) that sit between edge locations and the origin.      |
| **Origins**      | Common origins are **S3**, **ALB**, **EC2**, or **API Gateway**. Each has unique behavior (covered below).                   |
| **Protocols**    | Operates at **Layer 7 (HTTP/HTTPS)**. Accelerates both static and dynamic content.                                           |
| **Edge Network** | Uses the **AWS Global Edge Network**, not the public internet, for optimized routing back to origins.                        |

---

## 🧩 2. Design Patterns and Use Cases

### a. **Static Content Delivery**

**Pattern:**
CloudFront → S3 Origin

**Key design points:**

* Cache static objects (HTML, JS, images, video) globally.
* Use **Origin Access Control (OAC)** (replaces Origin Access Identity) to restrict S3 bucket access.
* Use **versioned file names** to control cache invalidation (e.g., `app.v2.js`).
* Integrate **AWS WAF** and **Shield** at the edge for DDoS protection.

**Exam Tip:**
If the content rarely changes and must be distributed globally → CloudFront + S3 is the **canonical answer**.

---

### b. **Dynamic or Personalized Content Delivery**

**Pattern:**
CloudFront → ALB → EC2 (or ECS/EKS services)

**Key design points:**

* CloudFront still accelerates **TCP connections** and **TLS handshakes** even if responses aren’t cached.
* Can cache **partial responses** (e.g., via cache keys or query string filtering).
* Use **Origin Groups** for automatic origin failover.
* Set **Minimum TTL = 0** for real-time responses (but reduces cache hit ratio).
* Combine with **Lambda@Edge** for request rewriting, header injection, or authentication.

**Exam Tip:**
Dynamic ≠ non-cacheable. CloudFront can still accelerate dynamic content by optimizing transport and reusing persistent TCP connections.

---

### c. **API Acceleration**

**Pattern:**
CloudFront → API Gateway (edge-optimized endpoint)

**Key design points:**

* API Gateway “edge-optimized” deployments *automatically* use CloudFront.
* “Regional” APIs require a **custom CloudFront distribution** if you want CDN acceleration.
* **Cache API responses** for GET requests to reduce latency and cost.
* **WAF integration** provides Layer 7 security.
* CloudFront preserves **HTTP methods, headers, and query strings**, allowing RESTful design.

**Exam Tip:**
Know when to use CloudFront with API Gateway vs. Global Accelerator:

* CloudFront = HTTP/HTTPS + caching
* Global Accelerator = TCP/UDP (non-HTTP) + static IPs

---

### d. **Video Streaming and Large File Delivery**

**Pattern:**
CloudFront → S3 or MediaPackage origin

**Key design points:**

* Supports **progressive download** and **live streaming protocols** (HLS, DASH, CMAF).
* Optimize cache behavior and TTLs for frequently accessed video segments.
* Use **signed URLs or cookies** for secure access.

**Exam Tip:**
AWS might test the difference between CloudFront and S3 Transfer Acceleration — the latter is for **uploads**, not downloads.

---

### e. **Multi-Region Active-Active Architecture**

**Pattern:**
CloudFront → ALBs in multiple Regions (via Origin Groups)

**Key design points:**

* Origin Groups allow failover if one region becomes unavailable.
* DNS (Route 53) or Global Accelerator can also distribute load between multiple CloudFront origins.
* Combine with **Lambda@Edge** for region-based routing logic.

**Exam Tip:**
Understand that CloudFront failover is **origin-level**, not DNS-level — it’s faster than Route 53 failover.

---

## 🔐 3. Security and Access Control

| Feature                          | Description                                                                 | Exam Relevance                                      |
| -------------------------------- | --------------------------------------------------------------------------- | --------------------------------------------------- |
| **Origin Access Control (OAC)**  | Restricts access so only CloudFront can read from S3 origins. Replaces OAI. | Frequently tested; know it well.                    |
| **Signed URLs / Cookies**        | Provide time-limited or user-specific access to restricted content.         | Use case: premium video or user-specific downloads. |
| **Field-Level Encryption**       | Encrypt sensitive data (e.g., PII) at edge before sending to origin.        | Know it exists, but rarely used.                    |
| **AWS WAF Integration**          | Protects against SQLi/XSS at edge.                                          | Often part of best-practice architecture.           |
| **AWS Shield Standard/Advanced** | DDoS protection built-in (standard); advanced adds metrics and SLA.         | Frequently mentioned in scenario questions.         |

---

## ⚙️ 4. Performance Optimization

| Mechanism                      | Description                                                             |
| ------------------------------ | ----------------------------------------------------------------------- |
| **Regional Edge Caches (REC)** | Larger, mid-tier caches that reduce origin load.                        |
| **Cache Behaviors**            | You can configure path-based behaviors (e.g., `/api/*` vs `/images/*`). |
| **Compression**                | Automatically compresses responses with Gzip/Brotli.                    |
| **Persistent TCP Connections** | CloudFront reuses connections to origins, reducing handshake latency.   |
| **HTTP/2 and HTTP/3 Support**  | Improves performance for modern clients.                                |
| **Connection Reuse**           | One CloudFront → origin connection may serve many viewers.              |

**Exam Tip:**
If latency to origin is high but content isn’t cacheable, CloudFront still helps — **because it optimizes TCP and TLS at the edge**.

---

## 💸 5. Cost Optimization Patterns

| Pattern                                                 | Reason                                                             |
| ------------------------------------------------------- | ------------------------------------------------------------------ |
| **Cache longer TTLs**                                   | Reduces origin load and data transfer cost.                        |
| **Use price classes**                                   | Restrict to fewer edge locations for cost control.                 |
| **Use CloudFront Functions for lightweight edge logic** | Cheaper than Lambda@Edge for simple rewrites or header injection.  |
| **Avoid excessive invalidations**                       | Each invalidation request costs after the first 1,000 paths/month. |

**Exam Tip:**
Expect scenario questions that force you to balance **cost vs latency** (e.g., “Company wants global acceleration but must minimize CloudFront charges → use smaller price class”).

---

## 🌍 6. Comparison with Similar Services

| Service                      | When to Use                                          |
| ---------------------------- | ---------------------------------------------------- |
| **CloudFront**               | HTTP/HTTPS, caching, DDoS protection, edge logic.    |
| **Global Accelerator**       | TCP/UDP acceleration, static IPs, no caching.        |
| **Route 53**                 | DNS-based routing (latency, geo, weighted).          |
| **S3 Transfer Acceleration** | Optimizing **uploads** into S3, not general CDN use. |

**Exam Tip:**
If the question involves caching, content delivery, or WAF → CloudFront.
If it involves static IPs or non-HTTP protocols → Global Accelerator.
If it involves routing users between regions → Route 53.

---

## 🧠 7. Typical Exam Scenarios

You should be ready to answer questions like:

> A company delivers both static and dynamic web content globally. They want to minimize latency and reduce load on their origin servers. Which architecture is best?
> ✅ **CloudFront → ALB → EC2**

> A financial company needs to securely distribute reports to users for 24 hours only.
> ✅ **CloudFront with signed URLs and Origin Access Control**

> An API is deployed in one Region and needs global low-latency access with caching and DDoS protection.
> ✅ **CloudFront in front of API Gateway**

> A game server uses UDP protocol for real-time updates.
> ❌ CloudFront (HTTP only)
> ✅ **Global Accelerator**
