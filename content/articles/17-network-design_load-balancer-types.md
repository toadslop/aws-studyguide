+++
title="Load Balancer Types"
date=2024-10-17

[taxonomies]
exams = ["Advanced Networking"]
topics = ["network design", "load balancing"]
[extra]
toc = true
comments = true
+++

When your app grows busier than a chipmunk in acorn season, you need a way to spread the traffic around — evenly, securely, and without hiccups.
That’s where **AWS load balancers** come in. They’re not one-size-fits-all — each is tuned for specific layers, traffic patterns, and resilience needs.

<!--more-->

In exam questions, expect to choose **which load balancer best fits the requirement**, not how to configure it. So let’s review what each does and what traps to avoid!

---

### 2. ⚙️ Types of Load Balancers in AWS

| **Type**                            | **OSI Layer**  | **Best For**                                                   | **Example Exam Scenario**                                                                                       | **Exam Tip / Trap**                                                                                      |
| ----------------------------------- | -------------- | -------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------- |
| **Application Load Balancer (ALB)** | Layer 7        | HTTP/HTTPS, modern web apps, microservices                     | You need to route based on hostnames (`api.example.com` vs `app.example.com`) or paths (`/login`, `/checkout`). | ALB supports **content-based routing** and **WebSocket** — but is not aware of **TCP/UDP**!                  |
| **Network Load Balancer (NLB)**     | Layer 4        | High-performance, low-latency apps (TCP, UDP, TLS passthrough) | You must handle millions of requests per second or use static IPs for whitelisted clients.                      | Use NLB for **static IPs** or **TLS termination with private certs** — not ALB.                          |
| **Gateway Load Balancer (GWLB)**    | Layer 3        | Network appliances (firewalls, packet inspection)              | You need to insert security appliances transparently between VPCs or on ingress.                                | **GWLB = Traffic steering layer.** It doesn’t terminate connections — it tunnels them (GENEVE protocol)! |
| **Classic Load Balancer (CLB)**     | L4/L7 (retired) | Nothing -- this legacy option is no longer available | A legacy system originally used CLB and must migrate to ALB or NLB. | CLB has been retired — if mentioned, the correct design choice is to migrate to ALB (Layer 7) or NLB (Layer 4). It may still appear in exam distractors.                        |

---

### 3. 🌍 Designing for **High Availability**

AWS load balancers are **Regional** services — automatically spanning multiple **Availability Zones (AZs)**.
To design for HA:

| **Design Requirement**  | **Solution / Load Balancer Behavior**    | **Exam Cue**                                            |
| ----------------------- | ---------------------------------------- | ------------------------------------------------------- |
| Survive AZ failure      | Register targets in at least **two AZs** | “Ensure web app remains available if one AZ goes down.” |
| Multi-Region HA         | Pair with **Route 53 failover routing**  | “Need automatic DNS failover between Regions.”          |

💡 **Exam Tip:** Load balancers don’t replicate *state* — so for session-based apps, use **sticky sessions (cookies)** on ALB or **session persistence** via Redis or DynamoDB.

---

### 4. 📈 Designing for **Scalability**

Load balancers scale differently:

* **ALB/NLB** scale *automatically* with load. No manual tuning required.
* **GWLB** scales with **target groups** — the more appliances, the more throughput.

📘 **Exam Cue:**

> “Traffic surges unpredictably and you need a managed service that automatically scales without pre-provisioning capacity.”
> ✅ Answer: **ALB** or **NLB**, not a custom EC2 proxy.

But remember: load balancer's _targets_ do not scale automatically -- you need auto-scaling groups for that. We'll talk more about those in a later article.

---

### 5. 🛡️ Designing for **Security**

Each load balancer integrates differently with AWS security tools:

| **Security Feature** | **Available On** | **Purpose / Exam Cue**                               |
| -------------------- | ---------------- | ---------------------------------------------------- |
| AWS WAF              | ALB, CloudFront  | “Filter malicious HTTP requests.”                    |
| Security Groups      | ALB, NLB         | “Restrict inbound traffic.”                          |
| PrivateLink          | NLB              | “Expose internal service privately across accounts.” |
| TLS Termination      | ALB, NLB         | “Centralize certificate management.”                 |
| VPC Flow Logs        | All (via ENIs)   | “Audit network access patterns.”                     |

💡 **Exam Trap:** **GWLB** doesn’t terminate connections or handle TLS — it simply forwards packets through security appliances.

---

### 6. 🧭 When Not to Use a Load Balancer

Sometimes, the exam wants you to recognize *when not to reach for one*:

| **Scenario**                     | **Better Solution**                        |
| -------------------------------- | ------------------------------------------ |
| Static website or cached content | **CloudFront**                             |
| DNS-based regional routing       | **Route 53 latency/geo routing**           |
| Packet filtering or IDS          | **GWLB + Firewalls**, not ALB/NLB directly |

---

### 7. 🐿️ Bit’s Final Thoughts

When you see a question about **“resilience,” “scaling,” or “security boundaries,”** — that’s your clue it’s load-balancer territory.
Just remember:

- **ALB = HTTP Smart** 🧠
- **NLB = Network Fast** ⚡
- **GWLB = Security Path** 🛡️
- **CLB = History Lesson** 📜
