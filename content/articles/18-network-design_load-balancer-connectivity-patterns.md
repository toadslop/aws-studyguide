+++
title="Load Balancer Connectivity Patterns Part 1: Internal"
date=2024-10-17

[taxonomies]
exams = ["Advanced Networking"]
topics = ["network design", "load balancing"]
[extra]
toc = true
comments = true
+++

Hey there, cloud burrowers! Bit the Chipmunk here, digging into one of the trickier corners of AWS networking: **internal load balancers**.

Many developers think “load balancer = public entry point.”
But in real AWS environments, *most* load balancers never touch the internet — they live deep inside private networks, keeping traffic organized, secure, and scalable behind the scenes.

<!--more-->

Let’s explore the key **connectivity patterns** you’ll need to recognize on the AWS exam for **internal** load balancers.

---

## 🧠 What Makes a Load Balancer “Internal”?

An internal load balancer isn’t reachable from the internet. It only has **private IPs** and **resolves to private DNS names**.

You’ll use it to route traffic:

* Between tiers of an application (e.g., web → app → database)
* Between VPCs (via PrivateLink or Peering)
* From on-prem networks through VPN or Direct Connect

**Exam clue:**
If a question says “no public endpoint,” “private connectivity,” or “traffic must stay within the VPC,” the answer probably involves an **internal ALB** or **internal NLB**.

---

## 🧩 1. Single-VPC Internal Load Balancing

This is the simplest internal pattern — everything lives in one VPC.

| **Use Case**                      | **Pattern**                             | **Key Points**                                              |
| --------------------------------- | --------------------------------------- | ----------------------------------------------------------- |
| Multi-tier app (web → app → DB)   | **Internal ALB or NLB**                 | Front-end servers send traffic to backend tiers privately.  |
| ECS or EKS service communication  | **Service-to-service via Internal NLB** | Load balances containers or pods within private subnets.    |
| Simple microservices deployments | **Internal ALB + Service Discovery**    | Each service has its own target group; DNS handles routing. |

---

## 🌉 2. Cross-VPC: Shared Service or Consumer Patterns

As organizations grow, it’s common to isolate workloads into separate VPCs (per environment, team, or account).
But what happens when one app in VPC-A needs to access services another in VPC-B — privately? That's where cross-VPC patterns come in. These patterns are more complex because we're not just talking about load balancers -- we have to choose the correct network connectivity solution as well.

### Option 1: **VPC Peering + Internal Load Balancer**

**Scenario**: Services in VPC A must be able to communicate with services in VPC B.

**Pattern**: Connect VPCs using VPC peering; front services with a load balancer to improve availability and resiliency

💡 **Key Notes:**

* The consumer VPC must add route table entries to the producer’s subnets via the peering connection.
* If using DNS for routing, DNS resolution must be enabled for private zones or manually configured.

⚠️ **Exam trap 1:**
Peering doesn’t scale well — no transitive routing. For many-to-one or hub-spoke topologies, look at PrivateLink or Transit Gateway instead.

⚠️ **Exam trap 2:**
Peering enables full connectivity between the two VPCs — it is not an option if only the services backed by the load balancer should be accessible. If this is a requirement, PrivateLink is the correct pattern.

---

### Option 2: **PrivateLink (Endpoint Service)**

**Scenario**: Services in a VPC must be accessible to services in other VPCs without exposing full network connectivity.

**Common Use Case**: One company provides a SaaS application to other companies; they want to provide access to the service only, without providing full network access to their VPC

**Pattern**: Front services with an NLB and expose them to consumer VPCs via PrivateLink.

💡 **Why PrivateLink Shines:**

* Scales across many consumers.
* Consumers see the service as a private IP in their own subnet.
* Traffic never leaves the AWS backbone.

⚠️ **Exam trap:**
Only **NLBs** can be used as PrivateLink *endpoint services* — not ALBs.
If a question says “service must be shared privately across accounts,” **PrivateLink** is the answer.

---

### Option 3: **Transit Gateway + Internal Load Balancers**

When you have multiple VPCs and networks (including on-prem) that need to interconnect, **AWS Transit Gateway (TGW)** acts as the central hub. Use this pattern when you need more scale than VPC peering can offer.

**Scenario**: Services in a VPC need to be reachable from a large number of other VPCs across a large organization.

**Common Use Case**: Shared services VPC — a VPC that hosts common services needed across an organization

💡 **Why This Matters:**

* Simplifies routing — you don’t need full mesh peering.
* Enables hybrid routing (DX/VPN to AWS).

⚠️ **Exam tip:**
TGW + Internal Load Balancer ≠ PrivateLink.
PrivateLink is *service exposure*; TGW is *network-level connectivity*.

---

## 🏢 3. Hybrid Connectivity: Bridging AWS and On-Prem

Hybrid load balancing patterns make sure traffic flows smoothly between AWS and on-prem environments — securely, privately, and resiliently.

### 🏠 Pattern 1: AWS → On-Prem Services

**Scenario:**
You have AWS-based workloads (like EC2 apps or Lambda functions) that need to call **on-prem services** — maybe a legacy database or authentication service — over a **VPN or Direct Connect** link.

**Design Pattern:**
Use an **Internal NLB** in AWS to represent your on-prem endpoints.
The NLB targets are the **private IPs of the on-prem systems**, reachable via DX or VPN.

**Why this works:**

* Keeps routing **simple** — AWS resources see a local endpoint (the NLB), not the remote IP.
* Supports **health checks and failover** across multiple on-prem targets.
* Enables **VPC service discovery** (e.g., via PrivateLink or Route 53 Private Hosted Zone).

**Exam Trigger:**

> “AWS workloads must connect to on-prem services over Direct Connect using private IPs.”
> ✅ **Answer:** Internal NLB targeting on-prem IPs.

---

### ☁️ Pattern 2: On-Prem → AWS Services

**Scenario:**
You have **on-prem clients or applications** that access **services hosted in AWS** — maybe a REST API or a private web tier — over a **private connection (VPN or DX)**.

**Design Pattern:**
Deploy an **Internal ALB or NLB** in AWS to front those AWS services.
On-prem clients resolve a **private DNS name** that maps to the load balancer’s private IPs.

**Why this works:**

* Keeps all traffic **off the public internet**.
* The load balancer provides **high availability** and **multi-AZ failover** inside AWS.
* Simplifies **network policy management** — you point all traffic to one endpoint instead of individual EC2 instances.

**Exam Trigger:**

> “On-prem clients must access AWS-hosted services privately via Direct Connect without exposing a public endpoint.”
> ✅ **Answer:** Internal ALB or NLB fronting the AWS service.

---

### 🧠 Bit’s Exam Tip

Remember, in both hybrid patterns:

* You’re using **private IP addressing** — no public DNS or internet gateways involved.
* **Internal load balancers** act as stable endpoints on the AWS side of the connection.
* The key clue in the question is usually **“must use private connectivity (VPN/DX)”** or **“no internet exposure.”**


---

## 🧱 5. Internal Load Balancers for Service Mesh and Microservices

Modern architectures often use **ECS**, **EKS**, or **App Mesh**, where internal LBs provide stable entry points for services.

| **Pattern**                  | **Platform**                                  | **Use Case**                                          |
| ---------------------------- | --------------------------------------------- | ----------------------------------------------------- |
| ECS with multiple services   | ALB with multiple listeners and target groups | Layer 7 routing between services.                     |
| EKS with ingress controllers | ALB or NLB managed by controller              | Ingress for Kubernetes workloads.                     |
| App Mesh with NLB endpoints  | NLB as mesh entry point                       | Consistent TCP routing in microservice architectures. |

💡 **Exam Clue:**
When the question says *“services discover each other via DNS”* or *“containerized workloads scale automatically”*, internal LBs are often in play — usually managed automatically by ECS/EKS controllers. We'll talk more about these scenarios in future articles.

---

## 🧩 6. Internal Load Balancers in Multi-Region Designs

Internal LBs don’t talk directly to the internet, but you can still create **multi-region private architectures** — for example, using **VPC peering across regions** or **Transit Gateway inter-region peering**.

| **Pattern**                                          | **Use Case**                             | **Exam Clue**                                    |
| ---------------------------------------------------- | ---------------------------------------- | ------------------------------------------------ |
| Internal ALBs per region + Route 53 weighted routing | Private multi-region HA                  | “Must fail over privately across regions.”       |
| Shared internal APIs in each region                  | PrivateLink endpoint services per region | “Private access from other accounts or regions.” |

💡 **Key takeaway:**
DNS-based failover still works for private endpoints — as long as you manage the Route 53 health checks and routing policies correctly.

---

## 🌰 Bit’s Final Bite

Internal load balancers are the **backbone** of private AWS networks.
They make hybrid apps scalable, secure, and reliable without ever exposing a single public IP.

When you see “private,” “no internet,” or “cross-account access,” think **internal ALB**, **internal NLB**, or **PrivateLink** — and you’ll stay ahead of those tricky exam questions.
