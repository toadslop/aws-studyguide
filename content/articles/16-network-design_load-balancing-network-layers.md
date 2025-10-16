+++
title="Load Balancing At Different Network Layers"
date=2024-10-17

[taxonomies]
exams = ["Advanced Networking"]
topics = ["network design", "load balancing"]
[extra]
toc = true
comments = true
+++

Hiya, it’s **Bit the Chipmunk** again!
Today we’re diving into one of my favorite topics — **load balancing** — the art of keeping traffic happy, healthy, and evenly spread out across multiple servers.

Load balancing is all about **distributing traffic** to improve **availability**, **scalability**, and sometimes even **security**. But not all load balancers are created equal — each layer of the OSI model adds its own flavor of smarts.

<!--more-->

Let’s scurry through the layers together 🐾

---

## 🌍 Layer 3: Network Layer Load Balancing (IP-Level Routing)

At **Layer 3**, load balancing happens at the **IP packet level**.
The balancer doesn’t care about TCP ports or HTTP headers — just **source and destination IP addresses**.

### 🧠 How it works

* Traffic is distributed using **routing rules** (for example, ECMP – Equal-Cost Multi-Path routing).
* Each packet’s **destination IP** is mapped to one of several backend instances.
* Often implemented in **routers, gateways, or appliances** that handle packet forwarding.

### 🧩 Characteristics

| Feature                 | Description                                                                                    |
| ----------------------- | ---------------------------------------------------------------------------------------------- |
| **Protocol Awareness**  | IP-only (no awareness of TCP, HTTP, etc.)                                                      |
| **Use Case**            | Very high throughput environments like VPN concentrators, NAT gateways, or data center routers |
| **Health Checks**       | Typically done at the next layer (L4 or above)                                                 |
| **Performance**         | Extremely high — minimal inspection overhead                                                   |
| **Example AWS Service** | *Gateway Load Balancer* (GWLB) works at this layer for network appliance insertion             |

### 💡 Exam Scenario Clue

> “The solution must distribute packets between multiple network firewalls without inspecting sessions or modifying traffic.”
> → **Layer 3 / GWLB** is the match.

---

## ⚙️ Layer 4: Transport Layer Load Balancing (TCP/UDP-Level)

Layer 4 is where load balancing starts to **understand connections** — TCP, UDP, and ports come into play.

### 🧠 How it works

* Balancer listens on a specific **port** (like TCP 443).
* Routes entire **connections or flows** to a target based on rules like:

  * 5-tuple (source/destination IP + port + protocol)
  * Hash-based distribution
  * Least-connections or round-robin algorithms

The balancer **doesn’t care what’s inside the packets** (no HTTP inspection), so it’s super fast.

### 🧩 Characteristics

| Feature                 | Description                                                       |
| ----------------------- | ----------------------------------------------------------------- |
| **Protocol Awareness**  | TCP, UDP                                                          |
| **Use Case**            | Scaling stateless app servers, database proxies, or gRPC backends |
| **Health Checks**       | TCP or ICMP checks                                                |
| **Performance**         | High — connection-level awareness but not content-level           |
| **Example AWS Service** | *Network Load Balancer (NLB)* operates here                       |

### 💡 Exam Scenario Clue

> “The application uses custom TCP-based protocols and needs to handle millions of requests per second with minimal latency.”
> → That’s **Layer 4** load balancing.

Another clue:

> “Clients connect via UDP for gaming or real-time streaming.”
> → Layer 4 again — HTTP balancers can’t handle raw UDP.

---

## 🧁 Layer 7: Application Layer Load Balancing (HTTP/HTTPS-Level)

Now we’re at **Layer 7**, where load balancers become **application-aware**.
They understand **URLs, headers, cookies, and session data** — perfect for web applications.

### 🧠 How it works

* Balancer **terminates** client connections (TLS offload).
* Parses the request to apply smart routing rules, such as:

  * “Send `/api/*` requests to microservice A”
  * “Route images to servers with caching”
  * “Redirect HTTP → HTTPS”
* Can add headers, rewrite URLs, and perform authentication checks.

### 🧩 Characteristics

| Feature                 | Description                                |
| ----------------------- | ------------------------------------------ |
| **Protocol Awareness**  | HTTP, HTTPS, WebSocket                     |
| **Use Case**            | Web front ends, REST APIs, content routing |
| **Health Checks**       | Application-level (HTTP 200 OK)            |
| **Performance**         | Slightly lower — but flexible and smart    |
| **Example AWS Service** | *Application Load Balancer (ALB)*          |

### 💡 Exam Scenario Clue

> “Traffic must be routed based on the URL path or HTTP header.”
> → That’s **Layer 7**.

Or:

> “The balancer must terminate TLS and perform user-based routing.”
> → Layer 7 — **ALB** or similar.

---

## Layer Comparison at a Glance

| **Layer**           | **Awareness**      | **Typical Use Case**                        | **Performance**     | **Example AWS Service** |
| ------------------- | ------------------ | ------------------------------------------- | ------------------- | ----------------------- |
| **3 – Network**     | IP packets         | Appliance load sharing (firewalls, IDS)     | ⚡⚡⚡ Fastest           | GWLB                    |
| **4 – Transport**   | TCP/UDP sessions   | Custom protocols, extreme scale             | ⚡⚡ Very fast        | NLB                     |
| **7 – Application** | HTTP/HTTPS content | Web apps, microservices, path-based routing | ⚡ Smart but slower | ALB                     |

---

## 🧩 Realistic Exam Scenarios

| **Scenario**                                     | **Likely Layer** | **Reasoning**                        |
| ------------------------------------------------ | ---------------- | ------------------------------------ |
| Distribute traffic between third-party firewalls | L3               | No connection tracking needed        |
| Scale out database proxies (TCP-based)           | L4               | Works with non-HTTP protocols        |
| Route users to `/api` vs `/images` endpoints     | L7               | Content-based routing                |
| Offload TLS and add custom headers               | L7               | Application-aware capabilities       |
| Support 10 million concurrent TCP connections    | L4               | Raw performance and minimal overhead |
| Insert network security appliances transparently | L3               | GWLB-style design pattern            |

---

## 🧠 Bit’s Final Burrow Notes

When you see a question on the AWS exam:

* If it mentions **URLs, headers, or cookies** → Layer 7
* If it mentions **TCP, UDP, or custom ports** → Layer 4
* If it mentions **firewalls, inspection appliances, or transparent routing** → Layer 3

Now you can tell the difference without gnawing on the cables 🐿️💻
