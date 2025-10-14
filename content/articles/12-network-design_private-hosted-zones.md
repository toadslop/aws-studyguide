+++
title="Private Hosted Zones"
date=2024-10-14

[taxonomies]
exams = ["Advanced Networking"]
topics = ["network design", "DNS", "Route 53", "private hosted zones"]
[extra]
toc = true
comments = true
+++

Hiya, folks! Bit the Chipmunk here — your bushy-tailed buddy for all things networking!
Today we’re diving deep underground (like a good chipmunk) into the **Private Hosted Zone**, one of the trickier — but absolutely essential — Route 53 topics for the Advanced Networking exam.

Let’s get digging.

<!--more-->

---

## 🧩 1. What’s a Private Hosted Zone?

A **Private Hosted Zone (PHZ)** is a **DNS zone that’s only visible within one or more Amazon VPCs**.
Think of it as your *private phonebook* for internal AWS resources — it’s DNS, but with restricted visibility.

**Key facts to remember:**

| Feature               | Description                                                                           |
| --------------------- | ------------------------------------------------------------------------------------- |
| **Scope**             | Private — resolvable only by VPCs associated with the zone                            |
| **VPC Association**   | Each PHZ must be associated with at least one VPC (can be across accounts or Regions) |
| **Resolution Path**   | Handled via the **Amazon Provided DNS Resolver** in the VPC (at `x.x.x.2`)    |

---

## 🏗️ 2. Typical Exam Scenarios

Here’s what to watch for on the test — each of these clues hints that **PHZs** are part of the right answer.

| **Exam Clue**                                                           | **Likely Design Solution**                              | **Why**                                                     |
| ----------------------------------------------------------------------- | ------------------------------------------------------- | ----------------------------------------------------------- |
| “DNS names should only be resolvable from within specific VPCs.”        | Create a **Private Hosted Zone**                        | Public zones expose records to the internet.                |
| “Need to share internal DNS across multiple VPCs or accounts.”          | Use **VPC associations** or **Route 53 Resolver rules** | PHZs can be shared directly or through a central DNS hub.   |
| “Hybrid DNS between AWS and on-premises networks.”                      | Use **Route 53 Resolver endpoints + PHZ**               | Private zone for AWS, inbound resolver for on-prem queries. |
| “VPCs in multiple Regions need to resolve the same internal DNS names.” | **Inter-Region PHZ association** (supported feature)    | Enables cross-Region internal name resolution.              |

---

## 🌐 3. Multi-Account and Multi-Region PHZ Design Patterns

Here’s how AWS lets you scale private DNS as your environment grows.

### a. **Centralized DNS Hub**

One “shared services” VPC owns the PHZ. Other VPCs (even across accounts) associate to it.

* Simplifies management and prevents record drift.
* Often combined with **AWS RAM** (Resource Access Manager).

**Exam clue:**

> “The company uses a shared services account to host centralized DNS for all environments.”

✅ Answer: Use **PHZ in shared account** + **VPC association** via **AWS RAM**.

---

### b. **Multi-Region Private DNS**

You can now **associate a single PHZ with VPCs across Regions** (a newer AWS feature).
This helps avoid duplicate zones or manual syncs between Regions.

**Exam clue:**

> “Resources in us-east-1 and ap-northeast-1 must resolve the same internal DNS names.”

✅ Answer: Use **Inter-Region PHZ associations**.

---

## 🧭 4. Split-Horizon DNS

Also called **split-view DNS**, this is when you host **both public and private zones for the same domain name** — for example:

* Public zone for `example.com` (public website)
* Private zone for `example.com` (internal services like `db.example.com`)

**Exam clue:**

> “The same domain name must resolve to different IPs depending on whether the query comes from inside the VPC or the public internet.”

✅ Answer: Use **split-horizon DNS** (a public + private hosted zone pair).

---

## ⚙️ 5. How DNS Resolution Works

When an EC2 instance makes a query:

1. It forwards the query to the **VPC DNS resolver** (`.2` address).
2. The resolver checks if the queried name matches a PHZ.

   * If yes → resolves from the PHZ.
   * If not → forwards to public DNS or custom forwarding rules.
3. Optionally, **Resolver endpoints** can integrate with on-prem DNS.

---

## 💡 6. Exam Tips from Bit

* **Private != isolated** — PHZs can span accounts and Regions via associations.
* **Hybrid DNS** → PHZ + Resolver endpoints.
* **Same hostname for public and private** → split-horizon setup.
* **Remember limits:** 10,000 records per hosted zone by default.
* **TTL values still matter** — caching can affect failover behavior.

---

### 🧩 Sample Exam Question

> A company runs workloads in multiple VPCs across two Regions. Internal DNS names must be consistent across Regions and resolvable only inside AWS.
>
> What’s the simplest solution?

**✅ Correct Answer:**
Create a **single Private Hosted Zone** and associate it with VPCs in both Regions.

**Exam Trap:**
Creating separate PHZs per Region causes DNS drift — names can fall out of sync.

---

### 🐿️ Bit’s Closing Thought

If public hosted zones are billboards on the internet highway,
then **Private Hosted Zones** are the **trail markers deep in your forest** — only visible to your own network. 🌲
Understand how they connect across accounts and Regions, and you’ll be ready for every PHZ question that comes your way!
