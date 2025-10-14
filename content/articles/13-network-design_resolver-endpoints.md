+++
title="Resolver Endpoints"
date=2024-10-14

[taxonomies]
exams = ["Advanced Networking"]
topics = ["network design", "DNS", "Route 53", "resolver endpoints"]
[extra]
toc = true
comments = true
+++

Hey there, network nut!

When you mix **AWS networks** with **on-premises DNS systems**, you need a way for the two to talk — securely, efficiently, and without breaking name resolution.

That’s where **Route 53 Resolver Endpoints** come in.
They’re the *bridge* between AWS and external DNS systems, and understanding how to use them is **critical for hybrid exam scenarios**.

<!--more-->

---

## 🧩 1. The Basics — What Are Resolver Endpoints?

By default, every VPC has a built-in **Amazon-provided DNS resolver** (at `VPC CIDR + 2`, like `10.0.0.2`), which handles:

* Internal name resolution (private hosted zones)
* Public DNS lookups via recursive resolution

But for **hybrid setups**, that’s not enough.
You need to send DNS queries **in or out** of AWS.
That’s exactly what **Resolver Endpoints** do.

| Endpoint Type         | Direction     | Use Case                                |
| --------------------- | ------------- | --------------------------------------- |
| **Inbound Endpoint**  | On-prem → AWS | On-prem systems query AWS private zones |
| **Outbound Endpoint** | AWS → On-prem | AWS resources resolve on-prem DNS names |

---

## 🏗️ 2. Architecture Overview

Here’s the mental picture to keep in mind (no need to draw it on a napkin this time, promise!):

```
On-prem DNS ⇄ (VPN / Direct Connect) ⇄ VPC with Resolver Endpoints ⇄ Route 53 Private Hosted Zones
```

**Key points:**

* Each endpoint is deployed **into subnets across multiple AZs** for resilience.
* Endpoints use **ENIs with private IPs** that your DNS traffic targets.
* **Security groups** control access to these ENIs (important for exam security clues!).
* Endpoints support both **IPv4 and IPv6**.

---

## 🧠 3. Common Exam Use Cases

Let’s look at how Resolver Endpoints appear in AWS exam scenarios:

| Scenario                                                                       | AWS Solution                                                           | Why It Matters                                                           |
| ------------------------------------------------------------------------------ | ---------------------------------------------------------------------- | ------------------------------------------------------------------------ |
| 🧭 **On-prem servers need to resolve AWS private records**                     | Create an **Inbound Resolver Endpoint** in your VPC                    | Allows queries from on-prem DNS to reach PHZs via the endpoint IPs       |
| 🏢 **EC2 instances need to resolve on-prem hostnames (e.g., `db.corp.local`)** | Create an **Outbound Resolver Endpoint** + **Forwarding Rules**        | Forward queries for specific domains to on-prem DNS servers              |
| 🕸️ **Multiple VPCs share one DNS hub**                                        | Centralize Resolver Endpoints in a “DNS VPC” and share via **AWS RAM** | Reduces operational overhead and supports multi-account designs          |
| 🌍 **Multi-Region hybrid setup**                                               | Create endpoints in each Region                                        | Resolver Endpoints are *regional*; no cross-Region resolution by default |
| 🧱 **Firewall blocks DNS from AWS to on-prem**                                 | Ensure security groups and on-prem firewalls allow UDP/TCP 53          | Common exam gotcha!                                                      |

---

## ⚙️ 4. Conditional Forwarding Rules

Outbound endpoints don’t just blast queries everywhere — they’re smart!

You can define **rules** that tell AWS where to send queries based on domain name:

| **Rule Type** | **Example / Domain**          | **Behavior / Purpose**                                                                                                                                                                                            | **Exam Clue**                                           |
| ------------- | ----------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------- |
| **Forward**   | `corp.local → 192.168.1.10`   | Forward queries for the specified domain and its subdomains to on-prem DNS servers via the outbound endpoint.                                                                                                     | “Queries for corp.local should use on-prem DNS”         |
| **Delegate**  | `sub.corp.local → 10.0.0.53`  | Delegate authority for a *subdomain* (e.g. `sub.corp.local`) to a resolver (on-prem or another VPC). Requires NS records in the hosted zone.                                                                      | “Manage `subdomain.company.com` separately outside AWS” |
| **System**    | `acme.example.com` (override) | Override forwarding rules for a subdomain. If you have a Forward rule for `example.com` but want local resolution for `acme.example.com`, you define a System rule to handle it inside AWS instead of forwarding. | “Don’t forward queries for acme.example.com”            |

### 🐿️ Bit’s Note on Use

- A **Forward** rule is the typical use case — send specific domain queries off to your on-prem DNS.
- A **Delegate** rule is more advanced: you’re handing control of a subdomain to a different DNS “owner” (on-prem or another VPC).
- A **System** rule is AWS’s way to intercept subdomain queries you don’t want forwarded, even though there’s a broader forward rule.

If a question says “forward everything except X,” that’s a classic System rule override use case.

---

## 🧩 5. Integration Patterns

| Pattern                      | Description                                              | Key Design Tip                                                |
| ---------------------------- | -------------------------------------------------------- | ------------------------------------------------------------- |
| **Hybrid DNS resolution**    | On-prem and AWS resolve each other’s domains             | Requires both inbound & outbound endpoints                    |
| **Centralized DNS hub**      | One VPC handles DNS for all others                       | Use AWS Resource Access Manager (RAM) to share endpoints      |
| **Multi-Region private DNS** | Duplicate PHZs with regional resolvers                   | No cross-region propagation; manage records per region        |

---

## 💡 Exam Tips

🐿️ **Bit’s Burrow of Wisdom:**

1. **Inbound = On-prem to AWS. Outbound = AWS to On-prem.**
   (The simplest way to remember it!)

2. **Resolvers are regional.**
   Cross-region queries require per-Region endpoints.

3. **Endpoints can have security groups.**
   If queries aren’t reaching, check SGs and firewalls first.

4. **Forwarding rules = targeted DNS routing.**
   Think of them as “DNS routing tables.”

5. **Centralized patterns show up in multi-account questions.**
   The correct answer often involves **one DNS hub** shared across accounts via **RAM**.

---

## 🧩 Quick Exam Example

> **Question:**
> A company has on-premises data center connected to a VPC using Site-to-Site VPN. The data center hosts servers using Active Directory DNS (`corp.local`), and workloads in the VPC need to resolve these names. What’s the simplest way to enable this?

✅ **Correct Answer:**
Create an **Outbound Resolver Endpoint** in the VPC and a **forwarding rule** for `corp.local` to the on-prem DNS server.

---

## 🌰 In a Nutshell

Route 53 Resolver Endpoints are how you *extend DNS across the AWS boundary*.
If you see keywords like **“hybrid,” “on-prem,” “Active Directory DNS,” “conditional forwarding,”** or **“cross-account DNS hub”**, that’s your cue to look for **Resolver Endpoints** in the answer options.
