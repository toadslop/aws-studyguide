+++
title="Load Balancer Target Groups"
date=2024-10-21

[taxonomies]
exams = ["Advanced Networking"]
topics = ["network design", "load balancing"]
[extra]
toc = true
comments = true
+++

Hey there, network navigators! Bit the Chipmunk here — ready to scamper through one of AWS’s trickier (but super important!) topics: **how target groups and listeners work across different types of load balancers.** ⚙️🌐

If you’re studying for the **AWS Advanced Networking – Specialty Exam**, this one’s a must. The exam loves to throw scenarios that hinge on whether you understand *how* each load balancer listens for requests and *where* it sends them.

<!--more-->

Let’s dig in.

---

## 🌰 1. Target Groups and Listeners — The Big Picture

Every AWS load balancer — whether **Application (ALB)**, **Network (NLB)**, or **Gateway (GWLB)** — has two key parts:

### 🧭 **Listeners**

* A listener is like the *doorman* of the load balancer.
* It listens for incoming connections on a **protocol + port** (for example, HTTPS:443).
* It then forwards matching traffic to one or more **target groups**, based on your rules.

### 🎯 **Target Groups**

* A target group defines *where* to send the traffic.
* Targets can be EC2 **instances**, specific **IP addresses**, **Lambda functions**, or even **other load balancers**.
* Each target group also defines:

  * **Protocol and port**
  * **Health check configuration** (optional)
  * **Target type** (Instance, IP, Lambda, or ALB appliance for GWLB)

💡 **Exam tip:** When the question describes a system where “different paths or hosts need different backends,” think **Application Load Balancer** — it supports listener rules for path-based and host-based routing.

---

## 🧩 2. Application Load Balancer (ALB)

### 👂 **Listener Configuration**

* **Protocols:** HTTP or HTTPS (Layer 7)
* **Rules:** Can route based on:

  * **Path** (e.g., `/images/*`)
  * **Host header** (e.g., `api.example.com`)
  * **Query strings**, **headers**, and **HTTP methods**
* You can attach **multiple target groups** and distribute traffic between them with weights (great for canary or blue/green deployments).

### 🎯 **Target Group Configuration**

* **Protocols:** HTTP or HTTPS
* **Target types:**

  * **Instance** – Routes to EC2 instances in the same VPC.
  * **IP** – Routes to IPs in any VPC or on-premises via PrivateLink or hybrid setup.
  * **Lambda** – Invokes AWS Lambda functions directly over HTTPS.

### 🩺 **Health Checks**

* Application-level checks (HTTP/HTTPS) against a path like `/health`.
* Status codes 200–399 = healthy.

### 💡 **Exam triggers:**

| Scenario                              | Correct Choice                                 |
| ------------------------------------- | ---------------------------------------------- |
| “Route traffic by hostname or path”   | ALB                                            |
| “Serverless backend, no EC2”          | ALB + Lambda target                            |
| “Blue/green deployments”              | ALB listener rules with multiple target groups |
| “Don't send traffic to failing targets” | ALB health check                               |

---

## ⚡ 3. Network Load Balancer (NLB)

### 🔌 **Listener Configuration**

* **Protocols:**

  * **TCP** – Standard transport for stateful applications (e.g., database connections).
  * **TLS** – Like TCP but with decryption handled at the load balancer.
  * **UDP** – For stateless or latency-sensitive workloads (e.g., DNS, VoIP, gaming).
  * **TCP_UDP** – Mixed-mode for apps using both protocols _on the same port_.
* NLBs operate at **Layer 4**, so they don’t inspect application headers.
* Listeners map directly to **target groups** by port and protocol.

### 🎯 **Target Group Configuration**

* **Protocols:** TCP, TLS, UDP, TCP_UDP
* **Target types:**

  * **Instance** – Routes to EC2 instances in the same VPC.
  * **IP** – Routes to specific private IPs (for example, container tasks or appliances in other VPCs).
  * **ALB** – Route traffic to an ALB for a second layer of HTTP-aware load balancing
* Health checks can be TCP, HTTP, or HTTPS (depending on your app).

### 💡 **Exam triggers:**

| Scenario                                               | Correct Choice               |
| ------------------------------------------------------ | ---------------------------- |
| “Low-latency, millions of requests per second”         | NLB                          |
| “Encrypted traffic but terminate SSL at load balancer” | NLB with **TLS listener**    |
| “Send UDP traffic for gaming or DNS”                   | NLB with **UDP listener**    |
| “Targets in another VPC or on-prem”                    | NLB with **IP target group** |
| “Layer 4 routing, not HTTP aware”                      | NLB                          |

### 🔒 **Security & Scaling**

* NLB preserves the **source IP** (good for logging and security rules).
  * Watch out! Source IP preservation is disabled by default if the **protocol is TCP** and the **target type is IP address**!
* Integrates with AWS PrivateLink for cross-VPC services.
* Supports **cross-zone load balancing** and **static IPs** or **Elastic IPs**.

---

## 🧱 4. Gateway Load Balancer (GWLB)

### 🧭 **Listener Configuration**

* **Protocol:** GENEVE (port 6081) only.
* Works at **Layer 3** (network layer).
* Routes traffic transparently — the client and server don’t even know a load balancer is there!

### 🎯 **Target Group Configuration**

* **Protocol:** GENEVE
* **Target type:** Instance or IP
* Targets are typically **security appliances** like:

  * Firewalls
  * Intrusion detection/prevention systems
  * Traffic analyzers or packet brokers

### 🩺 **Health Checks**

* HTTP, HTTPS, and TCP health checks ensure appliances are reachable.

### 💡 **Exam triggers:**

| Scenario                                                | Correct Choice                      |
| ------------------------------------------------------- | ----------------------------------- |
| “Traffic must pass through a security inspection layer” | GWLB                                |
| “Transparent bump-in-the-wire routing”                  | GWLB                                |
| “GENEVE encapsulation required”                         | GWLB                                |
| “Distribute traffic across firewalls or proxies”        | GWLB target group with multiple IPs |

### 🧠 **How it fits**

* GWLB integrates with **GWLB endpoints (GWLBe)** in customer VPCs.
* It encapsulates packets using **GENEVE**, sends them to the appliance fleet, then returns them to the flow — maintaining the same TCP session throughout.

---

## 🏁 5. Bit’s Exam Cheat Seeds 🌰

| **Question Trigger**                | **Right Load Balancer / Target Group** |
| ----------------------------------- | -------------------------------------- |
| “Route traffic by hostname or path” | ALB (HTTP/HTTPS)                       |
| “Lambda-based backend”              | ALB (Lambda target)                    |
| “Encrypted Layer 4 connections”     | NLB (TLS listener)                     |
| "TLS passthrough                    | NLB (TCP listener)                     |
| “UDP traffic”                       | NLB (UDP listener)                     |
| “DNS”                               | NLB (TCP_UDP listener)                 |
| “On-prem or other VPC targets”      | usually NLB (IP target)                |
| “Inline security appliances”        | GWLB                                   |
| “Transparent traffic inspection”    | GWLB                                   |

---

### 🐿️ Bit’s Final Thought

All AWS load balancers follow the same **listener → target group → target** pattern — but the *protocol layer* and *target type options* define what problems they solve.

So remember:

* **ALB = Smart Layer 7 routing**
* **NLB = Fast Layer 4 performance**
* **GWLB = Transparent Layer 3 inspection**

Crack that nut, and you’ll ace every load balancer question the exam throws at you. 🧠💥
