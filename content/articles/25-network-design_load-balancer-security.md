+++
title="Load Balancer Encryption and Authentication"
date=2024-10-21

[taxonomies]
exams = ["Advanced Networking"]
topics = ["network design", "load balancing", "security"]
[extra]
toc = true
comments = true
+++

Hey cloud explorers — Bit the Chipmunk here! 🐿️
Today we’re nibbling into one of the juiciest nuts in the exam forest: **encryption and authentication patterns** for AWS load balancers.

You’ll see words like *TLS termination*, *mTLS*, *ACM*, and *inspection* scattered all over exam questions. They’re testing whether you know **where encryption happens**, **who owns the certs**, and **what visibility each pattern gives you**. So, let’s break it down clearly — no crumbs left behind!

<!--more-->

---

## 🧩 1. TLS Termination — “Offload it at the Load Balancer”

**What happens:**
The load balancer (ALB or NLB TLS listener) decrypts TLS traffic. It can inspect headers, apply routing rules, and optionally re-encrypt before sending traffic to targets.

**Why you’d do it:**

* Enables **L7 features**: WAF, path/host routing, header rules.
* Centralized certificate management using **AWS Certificate Manager (ACM)**.
* Simplifies backend configuration.

**Watch out:**

* Traffic between LB → target is *unencrypted* unless you re-encrypt.
* The LB must hold valid certificates.

**Exam clue:**

> “Need WAF or path-based routing with centralized certificate management.”

---

## 🔁 2. TLS Re-Encryption — “Terminate, Then Re-Encrypt”

**What happens:**
The LB terminates client TLS for inspection, then opens a **new TLS session** to the target.

**Why you’d do it:**

* Maintains end-to-end encryption for compliance.
* Lets the LB inspect traffic while keeping back-end confidentiality.

**Exam clue:**

> “Inspect headers but require encryption all the way to backend.”

---

## 🧱 3. TLS Passthrough — “Don’t Touch It!”

**What happens:**
The LB simply forwards encrypted bytes. The TLS handshake happens **at the target**, not the LB.

**Where it fits:**

* Common with **NLB (TCP listener)**. _Note possible for ALB_
* Used for non-HTTP protocols or strict end-to-end encryption.

**Trade-offs:**

* Can’t use WAF, routing rules, or inspect headers.
* Backend must manage certs and termination.

**Exam clue:**

> “Must maintain end-to-end encryption and backend handles TLS.”

---

## 🤝 4. Mutual TLS (mTLS) — “Trust Both Sides”

There are two flavors here:

### 🧭 a. Client → ALB mTLS

* **ALB verifies client certificates** against a trusted CA (ACM Private CA or custom).
* Ensures only trusted clients (e.g., corporate partners) connect.

**Exam clue:**

> “Only devices with client certificates may access the API.”

### 🐝 b. Service-to-Service mTLS (Mesh)

* Within an **App Mesh** or service mesh, **Envoy proxies** use mTLS to authenticate services.
* Certificates issued by ACM Private CA or mesh controller.

**Exam clue:**

> “Authenticate internal microservices using certificates.”

---

## 🔍 5. TLS Inspection — “Decrypt, Inspect, Re-Encrypt”

**What happens:**
Traffic is decrypted for **deep inspection** by a security appliance, then re-encrypted before continuing. Implemented with:

* **Gateway Load Balancer (GWLB)** + inspection appliances.
* Or **AWS Network Firewall** with TLS inspection.

**Why use it:**

* Enterprise IDS/IPS, malware scanning, or DLP on encrypted traffic.
* GWLB steers traffic transparently using GENEVE encapsulation.

**Exam clue:**

> “Centralized TLS inspection across all VPC ingress/egress.”

---

## 🎓 6. Certificate & TLS Policy Management

**Best practices:**

* Use **ACM** for certificate provisioning & automatic renewal.
* Use **ACM Private CA** for internal certificates.
* Apply **TLS security policies** (cipher suites, TLS 1.2/1.3) at listeners.

**Exam clues:**

- “Automate cert rotation” → ACM.
- “Disable weak ciphers” → Choose correct TLS policy.

---

## ⚙️ 7. Extra Patterns to Watch

* **ALPN & SNI**: Multiple TLS services on one listener.
* **VPC Lattice TLS Passthrough**: Newer service-mesh-style pattern for end-to-end TLS across accounts.

**Exam clue:**

> “Route by SNI without decrypting traffic” → VPC Lattice or TLS passthrough with NLB.

---

## 🚀 8. Performance & Scaling Effects

| Pattern         | Load Balancer Workload        | Backend Workload           | Typical Use              |
| --------------- | ----------------------------- | -------------------------- | ------------------------ |
| **Termination** | High (CPU for TLS handshakes) | Low                        | Offload crypto from apps |
| **Passthrough** | Low                           | High (backends decrypt)    | End-to-end TLS           |
| **mTLS**        | Moderate (handshakes + auth)  | Moderate (cert validation) | Zero-trust meshes        |

**Exam clue:**

- Reduce CPU burden on servers from SSL handshake” → Offload to LB (ALB/NLB TLS).

---

## 🗺️ 9. Quick Decision Map

| Requirement                     | Best Pattern                            | Typical Service |
| ------------------------------- | --------------------------------------- | --------------- |
| WAF, routing, header inspection | TLS termination (ALB)                   | ALB + ACM       |
| End-to-end encryption           | TLS passthrough (NLB TCP) or re-encrypt (ALB/NLB) | NLB   |
| Client certificate auth         | mTLS (ALB mTLS or API Gateway)          | ALB / API GW    |
| Service identity inside VPC     | mTLS with App Mesh                      | App Mesh        |
| Enterprise TLS inspection       | GWLB + appliances or Network Firewall   | GWLB            |

---

## 🐿️ Bit’s Final Exam Tips

* **If you need WAF or path rules:** TLS must terminate (ALB).
* **If you need end-to-end encryption:** Use NLB passthrough or re-encrypt.
* **If you need client certs:** ALB mTLS.
* **If you need service-to-service identity:** App Mesh mTLS.
* **If you need centralized TLS inspection:** GWLB + appliances.

---

**Further Reading**

* [ALB Mutual TLS auth docs](https://docs.aws.amazon.com/elasticloadbalancing/latest/application/mutual-authentication.html?utm_source=chatgpt.com)
* [NLB Listener types(TCP/TLS/UDP/TCP_UDP)](https://docs.aws.amazon.com/elasticloadbalancing/latest/network/load-balancer-listeners.html?utm_source=chatgpt.com)
* [ACM cert management best practices](https://docs.aws.amazon.com/acm/latest/userguide/acm-bestpractices.html?utm_source=chatgpt.com)
* [App Mesh mTLS overview](https://docs.aws.amazon.com/app-mesh/latest/userguide/mutual-tls.html?utm_source=chatgpt.com)
* [TLS inspection patterns (AWS Network Firewall / GWLB)](https://aws.amazon.com/blogs/security/tls-inspection-configuration-for-encrypted-traffic-and-aws-network-firewall/?utm_source=chatgpt.com)
