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

Hi there, fellow cloud builders! Bit here — your trusty chipmunk pal scurrying through the caching layers of AWS networking. Today, we’re diving into one of my favorite topics: **Amazon CloudFront**, the content delivery network (CDN) that keeps your users happy and your latency low.

<!--more-->

If you’re studying for the **AWS Advanced Networking Specialty** exam, you’ll need to know **how CloudFront fits into network design** — when to use it, how it behaves, and what makes it so fast, secure, and cost-effective.

Let’s crack open the acorn of CloudFront knowledge together! 🌰

---

## 🧭 Overview

At a high level, you’ll be tested on your ability to:

* **Design efficient, secure, and scalable architectures using CloudFront**
* **Optimize** delivery for static, dynamic, and API-based content
* **Integrate** CloudFront with different origins like S3, ALB, and API Gateway
* **Tune and secure** distributions for latency, reliability, and cost

In short: know when CloudFront is the **right tool**, understand its **advantages and limits**, and how it **interacts with other AWS services** like Route 53, WAF, and Shield.

---

## ☁️ 1. Core Concepts of Amazon CloudFront

| Concept          | What You Need to Know                                                                           |
| ---------------- | ----------------------------------------------------------------------------------------------- |
| **Purpose**      | A **global CDN** that caches content close to users, reducing latency and boosting performance. |
| **Scope**        | A **global** service built on AWS edge locations and **Regional Edge Caches** (RECs).           |
| **Origins**      | Common origins: **S3**, **ALB**, **EC2**, **API Gateway** — each behaves differently.           |
| **Protocols**    | Works at **Layer 7 (HTTP/HTTPS)** and handles both static and dynamic content.                  |
| **Edge Network** | Uses AWS’s private backbone — not the public internet — for fast, reliable routing.             |

---

## 🧩 2. Design Patterns and Use Cases

### a. **Static Content Delivery**

**Pattern:** CloudFront → S3 Origin

**Key ideas:**

* Cache static assets (HTML, JS, images, video) globally.
* Protect your bucket using **Origin Access Control (OAC)** — replaces OAI.
* Use **versioned file names** for cache control (e.g., `style.v3.css`).
* Add **WAF and Shield** for DDoS protection at the edge.

**Bit’s Tip:**
If the data rarely changes and must reach users worldwide → **CloudFront + S3** is your best nut in the stash.

---

### b. **Dynamic or Personalized Content**

**Pattern:** CloudFront → ALB → EC2 (or ECS/EKS services)

**Key ideas:**

* CloudFront still speeds up connections, even when content isn’t cached.
* Use **cache keys** or **query string filtering** to cache partial responses.
* **Origin Groups** can provide automatic failover.
* Set **Minimum TTL = 0** for truly dynamic data.
* Use **Lambda@Edge** for request rewrites or authentication.

**Bit’s Tip:**
Even “dynamic” doesn’t mean “uncacheable”! CloudFront helps with **connection reuse and TLS optimization**, too.

---

### c. **API Acceleration**

**Pattern:** CloudFront → API Gateway (edge-optimized endpoint)

**Key ideas:**

* Edge-optimized APIs already include CloudFront under the hood.
* Regional APIs need a custom CloudFront distribution if you want caching.
* Cache **GET** responses to reduce latency and cost.
* Integrate **WAF** for extra security.

**Bit’s Tip:**

* **CloudFront =** HTTP/HTTPS + caching.
* **Global Accelerator =** TCP/UDP + static IPs (no caching).

---

### d. **Video Streaming and Large Files**

**Pattern:** CloudFront → S3 or MediaPackage

**Key ideas:**

* Supports HLS, DASH, and CMAF streaming.
* Tune TTLs and cache behavior for frequently watched segments.
* Use **signed URLs or cookies** for controlled access.

**Bit’s Tip:**
Don’t confuse this with **S3 Transfer Acceleration** — that’s for **uploads**, not streaming!

---

### e. **Multi-Region Active-Active**

**Pattern:** CloudFront → ALBs in multiple Regions

**Key ideas:**

* **Origin Groups** provide region-level failover.
* You can combine CloudFront with **Route 53** or **Global Accelerator** for global balancing.
* **Lambda@Edge** can route users by geography or custom headers.

**Bit’s Tip:**
CloudFront failover happens at the **origin layer**, which is faster than waiting for DNS failover.

---

## 🔐 3. Security and Access Control

| Feature                         | Description                                        | Why It Matters                             |
| ------------------------------- | -------------------------------------------------- | ------------------------------------------ |
| **Origin Access Control (OAC)** | Lets only CloudFront reach your S3 bucket.         | Commonly tested! Know it well.             |
| **Signed URLs / Cookies**       | Time-limited or user-specific access.              | Used for paid or private content.          |
| **Field-Level Encryption**      | Encrypts sensitive data at the edge.               | Rare but worth knowing.                    |
| **AWS WAF Integration**         | Protects from SQLi and XSS.                        | Best practice for web security.            |
| **AWS Shield**                  | DDoS protection (standard = free, advanced = SLA). | Expect at least one exam question on this. |

---

## ⚙️ 4. Performance Optimizations

| Feature                        | What It Does                                                |
| ------------------------------ | ----------------------------------------------------------- |
| **Regional Edge Caches (REC)** | Intermediate caches reduce origin load.                     |
| **Cache Behaviors**            | Configure path-based caching (e.g., `/api/*`, `/images/*`). |
| **Compression**                | Gzip/Brotli support for smaller payloads.                   |
| **Persistent Connections**     | CloudFront reuses TCP/TLS connections.                      |
| **HTTP/2 and HTTP/3**          | Faster for modern browsers.                                 |

**Bit’s Tip:**
Even if nothing is cacheable, CloudFront can **still help** — because it shortens the distance for TCP/TLS handshakes.

---

## 💸 5. Cost Optimization

| Strategy                 | Why It Helps                               |
| ------------------------ | ------------------------------------------ |
| **Longer TTLs**          | Fewer origin requests → lower cost.        |
| **Price Classes**        | Use fewer edge locations to save money.    |
| **CloudFront Functions** | Cheaper than Lambda@Edge for simple logic. |
| **Limit Invalidations**  | Beyond 1,000 paths/month, they cost extra. |

**Bit’s Tip:**
On exam day, if you see a trade-off between **latency vs. cost**, think about **price class** or **TTL adjustments**.

---

## 🌍 6. Comparing CloudFront with Other Services

| Service                      | Use Case                                            |
| ---------------------------- | --------------------------------------------------- |
| **CloudFront**               | HTTP/HTTPS delivery, caching, WAF, DDoS, edge logic |
| **Global Accelerator**       | TCP/UDP acceleration with static IPs                |
| **Route 53**                 | DNS-based traffic control                           |
| **S3 Transfer Acceleration** | Faster S3 uploads only                              |

**Bit’s Tip:**
Caching or WAF = CloudFront.
Static IPs or non-HTTP = Global Accelerator.
Routing between regions = Route 53.

---

## 🧠 7. Common Exam Scenarios

**Scenario 1:**

> A company delivers static and dynamic web content globally and wants to minimize latency.
> ✅ **CloudFront → ALB → EC2**

**Scenario 2:**

> A finance app must share reports securely for 24 hours only.
> ✅ **CloudFront with signed URLs and OAC**

**Scenario 3:**

> An API needs global caching and DDoS protection.
> ✅ **CloudFront in front of API Gateway**

**Scenario 4:**

> A multiplayer game uses UDP for real-time updates.
> ❌ CloudFront (HTTP only)
> ✅ **Global Accelerator**

---

And there you have it — a CloudFront crash course straight from the forest floor! 🌲
Keep these patterns and principles in your pouch, and you’ll be ready for anything the ANS-C01 exam tosses your way.

Until next time — stay cached and stay clever! 🐿️
