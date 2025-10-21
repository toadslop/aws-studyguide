+++
title="Load Balancer Configurations"
date=2024-10-21

[taxonomies]
exams = ["Advanced Networking"]
topics = ["network design", "load balancing"]
[extra]
toc = true
comments = true
+++


Every AWS load balancer has knobs and dials that tune its behavior:
how it routes traffic, maintains connections, and interacts with clients.
These configuration options often show up in *exam scenarios* that test your ability to spot subtle performance or architecture trade-offs.

<!--more-->

---

## 🔍 1. Proxy Protocol — Preserving the Client Source IP

**Applies to:** Network Load Balancer (NLB)

When an NLB proxies a TCP connection to a target, the backend **normally sees the source IP as the NLB’s IP**.
If your app needs the *real client IP* (e.g., for logging or firewall rules), you can enable **Proxy Protocol v2**, which adds connection metadata to the TCP header.

**Key points:**

* Carries client IP, destination IP, and port information.
* Targets must **support Proxy Protocol v2**; otherwise, they’ll misinterpret the data.
* Not needed for ALB — it preserves the original IP in `X-Forwarded-For`.
* Only applies to TLS connections with TLS termination — Proxy Protocol is never used for UDP or when passthrough occurs

✅ **Exam trigger:**

> “The backend must know the real client IP, but TLS termination happens at NLB.”
> → Enable **Proxy Protocol v2** on the target group.

---

## ♻️ 2. Cross-Zone Load Balancing — Even Distribution Across AZs

**Applies to:** ALB (always on), NLB (optional), GWLB (optional)

By default, each load balancer node only routes traffic to targets **in its own Availability Zone**.
When you turn on **Cross-Zone Load Balancing**, each node can send requests to **targets in all AZs** — improving balance when traffic isn’t evenly distributed.

| **Load Balancer** | **Default Behavior**            | **Cross-Zone Setting**                   |
| ----------------- | ------------------------------- | ---------------------------------------- |
| ALB               | Always enabled, no extra charge | Cannot be disabled                       |
| NLB               | Disabled by default             | Must enable; inter-AZ data charges apply |
| GWLB              | Disabled by default             | Optional; also adds data processing cost |

✅ **Exam trigger:**

> “Traffic is uneven because clients connect to one AZ more often.”
> → **Enable cross-zone load balancing** — but remember **NLB adds inter-AZ cost!**

---

## 🍪 3. Session Affinity (Sticky Sessions) — Keeping Users on One Target

**Applies to:** ALB, CLB (legacy)

Some applications (like shopping carts or legacy web apps) store session data locally instead of in a distributed store.
**Session stickiness** ensures that repeat requests from a client always go to the same backend.

**Key options:**

* **Application-based (ALB):** Uses a cookie named `AWSALB` (or custom cookie).
* **Duration:** Configurable (1 second – 7 days).
* **Scope:** Stickiness is per target group.
* **Cross-zone aware:** Still works when cross-zone balancing is enabled.

✅ **Exam triggers:**

> “Users are losing session state when the load balancer scales out.”
> → Enable **stickiness on ALB**.

> “You need to minimize session coupling for scalability.”
> → **Avoid stickiness**; use **distributed session storage (ElastiCache or DynamoDB)** instead.

---

## ⚖️ 4. Routing Algorithms — How Targets Are Chosen

**Applies to:** ALB, NLB, GWLB

Load balancers use **routing algorithms** to distribute connections across targets.

| **Algorithm**                  | **Applies To**   | **How It Works**                                   | **When To Use**                                       |
| ------------------------------ | ---------------- | -------------------------------------------------- | ----------------------------------------------------- |
| **Round Robin**                | ALB (HTTP/HTTPS) | Sequentially rotates through healthy targets.      | Even load; stateless apps.                            |
| **Least Outstanding Requests** | ALB (default)    | Routes to target with fewest in-flight requests.   | Best for uneven workloads or slow backends.           |
| **Flow Hash (5-tuple)**        | NLB              | Based on client IP, port, protocol, and target IP. | Predictable flow mapping; sticky at connection level. |
| **Hash-Based Distribution**    | GWLB             | Similar to flow hash for symmetric routing.        | Ensures bidirectional traffic hits same appliance.    |

---

## ⏱️ 5. Idle Timeouts — When the Connection Goes Quiet

**Applies to:** ALB, NLB

Idle timeouts define how long the load balancer keeps a connection open without traffic.

| **Load Balancer** | **Default Idle Timeout** | **Configurable?** | **Use Case**                       |
| ----------------- | ------------------------ | ----------------- | ---------------------------------- |
| ALB               | 60 seconds               | Yes               | Short HTTP requests.               |
| NLB               | 350 seconds              | Yes (TCP)         | Long-lived connections (IoT, SSH). |
| NLB               | 120 seconds              | No (UDP)          | Maintaining flow state.            |

If a connection exceeds the idle timeout, it’s dropped — **not throttled**, just closed silently.

✅ **Exam triggers:**

> “Clients report connections dropping after one minute of inactivity.”
> → Increase **ALB idle timeout**.

> App requires long-lived TCP connections.”
> → Use NLB (longer default idle window; extend up to 6000 seconds).

---

## 🔁 6. Connection Draining (a.k.a. Deregistration Delay)

**Applies to:** ALB, NLB

When you deregister a target or the instance scales down, active connections shouldn’t be dropped immediately.
**Connection draining** (also called *deregistration delay*) allows in-flight requests to finish gracefully.

* Default: **300 seconds (5 minutes)**
* Adjustable: **0–3600 seconds**
* Load balancer stops sending new requests but lets old ones complete.

✅ **Exam trigger:**

> “Scaling down causes users to get errors.”
> → Enable or lengthen **deregistration delay**.

---

## 🧩 7. Access Logs and Connection Logs

**Applies to:** ALB, NLB

Access logs are critical for visibility and compliance:

* Stored in **S3**; include request path, latency, target info, and client IP.
* **ALB logs** are HTTP-aware (request details).
* **NLB flow logs** are TCP connection-level data.

✅ **Exam trigger:**

> “Security team needs detailed request logs for compliance.”
> → **Enable access logging to S3** on the ALB.

---

## 🧠 Bit’s Quick-Reference Cheat Sheet

| **Feature**          | **Applies To** | **Exam Focus**      | **Key Pitfall**             |
| -------------------- | -------------- | ------------------- | --------------------------- |
| Proxy Protocol v2    | NLB            | Preserve source IP  | Backend must be able to parse header |
| Cross-Zone LB        | ALB/NLB        | AZ imbalance        | NLB adds inter-AZ data cost |
| Sticky Sessions      | ALB            | Session persistence | Reduces scalability         |
| Routing Algorithm    | ALB/NLB        | Flow control logic  | Hashing = static flows      |
| Idle Timeout         | ALB/NLB        | Dropped connections | NLB = longer                |
| Deregistration Delay | ALB/NLB        | Graceful scale-in   | Too short = 5xx errors      |
| Access Logs          | ALB/NLB        | Troubleshooting     | Must enable manually        |

---

## 🏁 Bit’s Final Thought

> “Configuring a load balancer is like tuning a race car —
> if you don’t know what each knob does, you’ll either go too slow or crash!” 🏎️🐿️

---

Would you like me to follow this up with the **Target Group Configuration** article next — covering health checks, target types, and advanced routing rules (like host/path-based and weighted targets)?
