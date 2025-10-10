+++
title="Global Traffic Management"
date=2024-10-10

[taxonomies]
exams = ["Advanced Networking"]
topics = ["network-design", "global-accelerator", "edge-networking"]
[extra]
toc = true
comments = true
+++

How to choose the *right global traffic management pattern* for **performance, availability, failover, and cost**.

<!--more-->

Here’s a detailed, exam-focused explanation of what you should know:

---

## 🧭 **1. The Core Problem: Global Traffic Management**

When you have users distributed globally, you need to:

* Minimize latency (by routing users to the nearest healthy endpoint)
* Improve availability (automatic failover between Regions)
* Handle complex routing (e.g., weighted, geo-based)
* Integrate with hybrid or multi-Region backends

The exam expects you to **know which AWS services and design patterns to use** in these situations, and their **pros / cons**.

---

## 🌐 **2. Main AWS Services / Patterns**

### **A. AWS Global Accelerator**

* **What it is**: A global networking service that routes user traffic over the AWS global network (not the public internet) to the optimal regional endpoint.
* **Traffic direction**: Uses **anycast IPs** (two static IPv4 addresses) that are advertised globally.
* **Routing**: Routes to the nearest AWS edge location, then uses the AWS backbone to reach the best (healthy, low-latency) endpoint.

**Key exam points:**

* Works at **Layer 4 (TCP/UDP)**, not Layer 7 (HTTP).
* Provides **static IPs** that don’t change, even if you update endpoints.
* Integrates with ALB, NLB, EC2 instances, and Elastic IPs as endpoints.
* Supports **traffic dials** and **weights** to control distribution across Regions or endpoints.
* **Health checks** are regional; if a Region becomes unhealthy, traffic fails over automatically to another healthy Region.
* Improves performance for TCP and UDP apps by avoiding slow public internet paths.
* Supports **client IP preservation** (important for apps relying on IP).
* Ideal for:

  * Multi-Region active-active or active-passive architectures
  * Gaming, VoIP, real-time apps, low latency requirements
  * Global enterprise applications where stable IP addresses are required

---

### **B. Amazon Route 53**

* **What it is**: A scalable DNS service with built-in **routing policies** that can direct users to different endpoints based on rules.
* Works at **Layer 7 (DNS)**, not L4.
* Routes user traffic based on DNS resolution policies.

**Routing policies to remember for the exam**:

* **Latency-based routing** → sends user to the Region with the lowest latency.
* **Geolocation routing** → routes based on user’s location (e.g., send EU users to EU endpoint).
* **Geo-proximity routing** → similar to geolocation but allows bias adjustments.
* **Weighted routing** → distribute traffic proportionally across endpoints (e.g., 80/20 for canary).
* **Failover routing** → primary / secondary configuration with health checks.
* **Multivalue answer** → return multiple healthy records, relies on client retry.

**Key exam points:**

* DNS changes rely on **TTL** values → not immediate failover unless TTL is low.
* No performance improvement on the transport layer — just picks which endpoint to use.
* Good for simple global routing where DNS-based control is enough.
* Works well with CloudFront or load balancers.

---

### **C. Amazon CloudFront**

* Primarily a **content delivery network (CDN)**, but relevant to global routing:
* Users connect to the **nearest edge location**, CloudFront fetches content from the **origin**.
* For dynamic content acceleration, CloudFront uses **TCP optimizations and persistent connections** back to the origin.
* You can use **origin failover** within CloudFront for multi-origin architectures.

**Key exam points:**

* Improves global latency for both static and dynamic content.
* CloudFront DNS is managed by AWS — users don’t need to know origin Regions.
* Can integrate with Global Accelerator if needed (e.g., Global Accelerator → CloudFront → ALB).

---

## 📝 **3. Common Design Patterns to Study**

| Pattern                               | Description                                                                   | Pros                                                         | Cons / Notes                                          |
| ------------------------------------- | ----------------------------------------------------------------------------- | ------------------------------------------------------------ | ----------------------------------------------------- |
| **Route 53 latency-based routing**    | Direct users to lowest-latency Region                                         | Simple; DNS-based                                            | TTL affects failover speed; no transport acceleration |
| **Route 53 geo/geoproximity routing** | Route based on user geography                                                 | Good for regulatory / localization                           | Static; doesn't adapt to changing latency             |
| **Global Accelerator active-active**  | Multiple Regions behind Global Accelerator; routing based on latency & health | Fast failover (seconds), stable IPs, transport acceleration  | Slightly higher cost                                  |
| **Global Accelerator active-passive** | One Region active, one standby                                                | Automatic failover; preserves IPs                            | Underutilized standby unless dialed differently       |
| **CloudFront as front door**          | Edge termination; origin in one or multiple Regions                           | CDN + dynamic acceleration; good for HTTP(S)                 | Not suited for non-HTTP protocols                     |
| **GA + CloudFront**                   | GA static IPs → CloudFront DNS → origin                                       | Useful when you need static IPs for CloudFront distributions | More complex setup                                    |

---

## ⚠️ **4. Exam Tips**

* ✅ **Know when to pick Global Accelerator vs Route 53**:

  * GA for **transport acceleration**, static IPs, real-time apps
  * Route 53 for **DNS-based routing**, lightweight control, or when GA isn’t supported
* ✅ GA is not a replacement for CDN (CloudFront) — they complement each other.
* ✅ Route 53 failover depends on **TTL** and **health checks**.
* ✅ GA failover is **much faster** (seconds) because it’s not DNS-based.
* ✅ Understand how **traffic dials** in GA let you gradually shift or split traffic between Regions.
* ✅ Know that GA routes traffic into the AWS backbone network at the edge.
* ✅ Know how GA integrates with ALB/NLB and EC2 endpoints.
* ✅ GA works with **IPv4** anycast only (for now), so IPv6 clients are routed through DNS resolution.

---

## 🧠 **Summary Table**

| Feature             | Global Accelerator                       | Route 53                          | CloudFront                      |
| ------------------- | ---------------------------------------- | --------------------------------- | ------------------------------- |
| Layer               | 4 (TCP/UDP)                              | 7 (DNS)                           | 7 (HTTP/CDN)                    |
| Latency improvement | ✅ (AWS backbone)                         | ❌                                 | ✅ (edge network)                |
| Failover speed      | Seconds                                  | TTL dependent                     | Edge-origin failover            |
| Static IPs          | ✅                                        | ❌                                 | ❌                               |
| Protocols           | TCP/UDP                                  | Any (DNS-based)                   | HTTP/HTTPS                      |
| Use cases           | Low-latency, multi-Region, non-HTTP apps | DNS-based routing, global control | Static/dynamic content delivery |

---

### 📌 In short for the exam:

> **Design patterns for global traffic management** = choosing between **Route 53 routing policies**, **CloudFront distribution**, and **Global Accelerator** to achieve the best combination of **latency**, **availability**, **control**, and **failover behavior** for global applications.
