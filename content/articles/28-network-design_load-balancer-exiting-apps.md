+++
title="Adding a Load Balancer to an Existing App"
date=2024-10-26

[taxonomies]
exams = ["Advanced Networking"]
topics = ["network design", "load balancing"]
[extra]
toc = true
comments = true
+++

Hey there, cloud builders! Bit the Chipmunk here, ready to scamper into one of the trickier topics on the AWS Advanced Networking exam: **how to integrate load balancers into existing environments**. 🐾

You’ve already got running workloads—maybe EC2 fleets, containerized services, or even hybrid systems—and now it’s time to weave in a load balancer for higher availability, smarter scaling, or stronger security. The challenge? Doing it *without breaking what’s already working*.

<!--more-->

Let’s explore how to retrofit AWS load balancers into live deployments, from the simple to the super-sophisticated—complete with key exam clues along the way.

---

## 🧭 1. Why Integration Matters

Real-world environments rarely start from scratch. Often, you need to **insert a load balancer into an existing app**—for example:

* To scale EC2 instances across AZs.
* To enable HTTPS/TLS offload.
* To inspect or filter traffic via a security appliance.
* To migrate apps gradually (blue/green, canary).

For the exam, watch for keywords like:

> “Existing application needs to add load balancing for scalability and security with minimal downtime.”

---

## 🧩 2. Common Integration Patterns

### **a) Retrofitting an ALB for a Web Tier**

**Use Case:** Existing web servers or containers (HTTP/HTTPS).

**Integration steps:**

* Create an **Application Load Balancer (ALB)** in the same or a connected VPC.
* Configure **listeners** (ports 80/443) and routing rules (host or path-based).
* Create **target groups** using either **instance targets** (for EC2) or **IP targets** (for containers, hybrid, or cross-VPC targets).
* Gradually redirect traffic to the ALB via DNS (Route 53 alias).
* Integrate **AWS WAF** for added security or **ACM** for HTTPS offload.

**Exam clue:** “Need host/path routing, SSL termination, and WAF for existing EC2 app.”

> 💡 *Advanced pattern:* If your web servers are in another VPC (peered or via TGW), use **IP targets** to register them with the ALB.

---

### **b) Adding an NLB in Front of Legacy or Non-HTTP Services**

**Use Case:** TCP/UDP workloads needing low latency or client IP visibility.

**Integration steps:**

* Deploy a **Network Load Balancer (NLB)** (Internet-facing or internal).
* Define a **listener** for TCP, TLS, UDP, or TCP_UDP protocols.
* Create a **target group** with **instance** or **IP targets** (for cross-VPC, hybrid, or on-prem via Direct Connect).
* Assign **Elastic IPs (EIPs)** for static endpoints.
* Update clients or DNS to use the NLB DNS name or EIPs.

**Exam clue:** “Must preserve source IP for a legacy TCP app.”

> 💡 *Gotcha alert:* **Cross-zone load balancing is *disabled* by default on NLBs.**
> If each AZ doesn’t have healthy targets, traffic may fail. Enabling it improves resilience but can add inter-AZ data charges.

---

### **c) Inserting a Gateway Load Balancer (GWLB) for Centralized Inspection**

**Use Case:** You need to insert a security appliance layer (firewall, IDS, proxy) between the internet and app VPCs.

**Integration steps:**

* Deploy a **GWLB** in a **security/inspection VPC**.
* Create **GWLB endpoints (GWLBe)** in the *ingress/egress VPCs* to forward traffic transparently through the appliance fleet.
* Register the appliances as targets in the GWLB’s target group (protocol GENEVE).
* Route traffic via the GWLBe, ensuring symmetric paths.

**Exam clue:** “Centralized inspection layer using GWLB and endpoints.”

> 💡 GWLB supports **cross-account and cross-VPC** integration through **PrivateLink**, a powerful design for shared ingress/egress architectures.

---

### **d) Gradual Migration with Weighted Target Groups**

**Use Case:** Migrate an existing version to a new one with minimal downtime.

**Integration steps:**

* Configure an ALB with **two target groups** — one for the old app, one for the new version.
* Use **weighted routing** to shift traffic incrementally (e.g., 10 → 50 → 100%).
* Monitor metrics and roll back if needed.

**Exam clue:** “Migrate an application version with minimal downtime using load balancing.”

---

### **e) Cross-VPC or Cross-Account Integration**

**Use Case:** Centralized load balancing in a “hub” or “DMZ” VPC that fronts apps in “spoke” VPCs or other accounts.

**Integration patterns:**

* **ALB/NLB with IP targets:** Register private IPs of targets in other VPCs via **VPC peering** or **Transit Gateway**.
* **PrivateLink:** For NLB, you can expose its front end as a **PrivateLink endpoint service** to other VPCs (advanced pattern).
* **Shared VPCs:** Alternatively, deploy the load balancer in a shared network account via AWS RAM.

**Exam clue:** “Central ingress VPC must front applications in multiple spoke VPCs.”

---

### **f) EKS and Service Mesh Integrations**

**Use Case:** Existing Kubernetes services running on Amazon EKS.

**Integration options:**

* **AWS Load Balancer Controller:** Automatically provisions ALBs for `Ingress` resources or NLBs for `Service` objects of type `LoadBalancer`.
* Use **NLBs** for internal TCP, or UDP services; **ALBs** for external HTTP(S) or gRPC ingress with path or host routing.
* Combine with **App Mesh** or **GWLB** for advanced east-west traffic control and security inspection.

**Exam clue:** “Expose an EKS service to the internet securely using AWS Load Balancer Controller.”

---

## ⚙️ 3. Key Considerations & Exam Traps

| Topic                    | Key Insight                                                                                             |
| :----------------------- | :------------------------------------------------------------------------------------------------------ |
| **Health Checks**        | Match the correct endpoint (path and port). Wrong checks = target deregistration.                       |
| **AZ Coverage**          | Ensure the load balancer spans the same AZs as the backend targets for resilience.                      |
| **Cross-Zone LB**        | ALB: always enabled (no cost). NLB: disabled by default, may cause uneven load.                         |
| **Target Types**         | ALB/NLB: *Instance*, *IP*, or *Lambda* (ALB only). IP targets are key for hybrid and cross-VPC designs. |
| **Client IP Visibility** | Use NLB (native) or ALB with X-Forwarded-For / Proxy Protocol v2.                                       |
| **Security Groups**      | Remember: LBs have their own ENIs — allow inbound from LBs and outbound to targets.                     |
| **Session Management**   | Use sticky sessions (ALB) or token-based auth if migrating from sessionful backends.                    |
| **DNS and Migration**    | Use Route 53 weighted or alias records for safe traffic shifting during cutover.                        |

---

## 📚 Further Reading

* **[Blue/Green Deployments with Application Load Balancer](https://aws.amazon.com/blogs/devops/blue-green-deployments-with-application-load-balancer/)** — AWS DevOps Blog
* **[Best Practices for Deploying Gateway Load Balancer](https://aws.amazon.com/blogs/networking-and-content-delivery/best-practices-for-deploying-gateway-load-balancer/)** — AWS Networking Blog
* **[Using IP Targets for Cross-VPC Load Balancing](https://aws.amazon.com/blogs/networking-and-content-delivery/using-ip-targets-with-alb-and-nlb/)** — AWS Networking Blog
* **[AWS Load Balancer Controller on Amazon EKS](https://aws.amazon.com/blogs/networking-and-content-delivery/deploying-aws-load-balancer-controller-on-amazon-eks/)**
* **[Elastic Load Balancing Documentation](https://docs.aws.amazon.com/elasticloadbalancing/latest/userguide/what-is-load-balancing.html)** — official AWS reference

---

### 🐿️ Bit’s Final Nut

Integrating a load balancer into an existing deployment isn’t just “plug and play” — it’s about **smart placement**, **target flexibility**, and **cross-VPC awareness**.

For the exam, remember:

* Choose **ALB** for HTTP brains, **NLB** for TCP brawn, **GWLB** for inspection power.
* Watch for **cross-zone load balancing defaults**, **target type flexibility**, and **cross-account connectivity**.
* And always — always — match your health checks to the app’s heartbeat. ❤️‍🔥

Now go forth and balance wisely, little cloud adventurers! 🌩️🐿️
