+++
title="Route 53 for Global Traffic Management"
date=2024-10-14

[taxonomies]
exams = ["Advanced Networking"]
topics = ["network design", "DNS", "Route 53"]
[extra]
toc = true
comments = true
+++

Hey squeak-mates! 🐿️ Bit here, digging into one of my favorite topics — **how Route 53 helps manage global user traffic**. But beware — not every “global” problem in AWS is solved with Route 53. Let’s learn where it shines… and where you should scurry away to another service!

<!--more-->

---

### 🧭 What Route 53 Global Traffic Management *Really* Means

When we say **global traffic management**, we’re talking about **making intelligent routing decisions at the DNS layer** to direct users to the best AWS endpoint (or on-prem) based on performance, location, or availability.

Route 53 does this with **Routing Policies**, not actual traffic forwarding.
So remember: Route 53 tells clients *where* they should connect — not *how* packets get there.

---

## ⚙️ Common Routing Policies and Exam Use Cases

| **Routing Policy**     | **What It Does**                                      | **Exam-Relevant Use Case**                 | **Exam Trap**                                                                                      |
| ---------------------- | ----------------------------------------------------- | ------------------------------------------ | -------------------------------------------------------------------------------------------------- |
| **Simple**             | One record → one target                               | Static site, no failover                   | No health checks → single answer always                                                            |
| **Failover**           | Active-Passive routing                                | Backup server in another Region                  | Route 53 **cannot fail over CloudFront or Global Accelerator**, since they expose single endpoints |
| **Latency-Based**      | Chooses the Region with lowest latency to the user    | Multi-Region ALB or EC2 web apps           | Must deploy **identical stacks** in multiple Regions                                               |
| **Geolocation**        | Routes by user’s country or continent                 | Regional compliance (EU vs. US)            | **Country match** ≠ latency optimization                                                           |
| **Geoproximity**       | Routes by geographic bias (requires [**Traffic Flow**](https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/traffic-flow.html)) | Custom steering (e.g., shift 20% to APAC)  | Does not support failover or optimize for latency                           |
| **Weighted**           | Distributes traffic by percentage                     | Canary deployments or A/B testing          | Weight only affects DNS responses, not session stickiness                                          |
| **Multi-Value Answer** | Returns multiple healthy IPs                          | Client-side load distribution with health checks | Not true load balancing like ALB/NLB                                                               |

---

## 🚫 When Route 53 Is *Not* the Right Global Tool

| **Scenario**                                                      | **Better AWS Service**       | **Why Route 53 Isn’t Right**                                    |
| ----------------------------------------------------------------- | ---------------------------- | --------------------------------------------------------------- |
| Need **real-time routing** with **instant failover**              | **AWS Global Accelerator**   | Route 53 changes propagate via DNS TTLs — not instant           |
| Need **content caching or global edge presence**                  | **Amazon CloudFront**        | Route 53 only resolves names — doesn’t deliver or cache content |
| Need **static IPs** for TCP/UDP applications                     | **Global Accelerator**       | Route 53 gives DNS names, not static IPs                        |
| Need **ingress routing within a region** or **session managment control** | **ALB**        | Route 53 can’t inspect requests or balance sessions             |

---

## 🧠 Bit’s Exam Nuggets

* **Route 53 = DNS-layer control**, not packet-level control.
  → If the question talks about *“latency-based user redirection”*, that’s **Route 53 Latency Routing**.
  → If it talks about *“instant failover without DNS TTL delay”*, that’s **Global Accelerator**.
* **Alias records** are the default choice for AWS targets (ALB, CloudFront, S3 website endpoints).
* **Health checks** can monitor endpoints outside AWS — exam questions love this detail!
* **Traffic Flow policies** can combine multiple routing types (e.g., weighted + geolocation).

---

### 🐿️ Bit’s Quick Recap

* Route 53 is your **DNS-based global traffic manager** — perfect for user redirection between AWS Regions or endpoints.
* It **doesn’t route packets or cache content** — that’s Global Accelerator or CloudFront territory.
* Expect exam questions comparing Route 53 vs. Accelerator or CloudFront for global architectures — the winner depends on *whether DNS latency tolerance is acceptable*.
