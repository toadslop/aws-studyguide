+++
title="Public Hosted Zones"
date=2024-10-14

[taxonomies]
exams = ["Advanced Networking"]
topics = ["network design", "DNS", "Route 53", "public hosted zones"]
[extra]
toc = true
comments = true
+++

It’s me, Bit the Chipmunk! Let’s talk about one of the most *visible* parts of AWS DNS design — **Route 53 Public Hosted Zones (PHZs)**.
Public hosted zones are your go-to for making **domain names resolvable on the public internet** — whether you’re mapping a static website, an API endpoint, or a multi-region failover setup.

When the exam asks about **public access**, **global availability**, or **internet-facing architectures**, your chipmunk senses should start tingling for **Route 53 Public Hosted Zones**!

<!--more-->

---

## 🧭 1. What’s a Public Hosted Zone?

A **hosted zone** is a container for DNS records.

* A **Public Hosted Zone** routes traffic on the **public internet**.
* A **Private Hosted Zone** routes traffic only within **VPCs**.

When you register a domain in Route 53 (or elsewhere) and want the world to resolve it — you create a **public hosted zone** and delegate it using **name servers (NS records)** at the registrar.

---

## 💡 2. Common Exam Use Cases and Clues

| **Exam Clue**                                                         | **What It’s Testing**                                   | **Likely Answer**                                             |
| --------------------------------------------------------------------- | ------------------------------------------------------- | ------------------------------------------------------------- |
| “Public users can’t resolve the company’s domain hosted in Route 53.” | Missing or misconfigured public hosted zone delegation. | Update NS records at registrar.                               |
| “Website must be accessible globally via HTTPS.”                      | Internet-facing DNS resolution.                         | Public Hosted Zone with Alias record → CloudFront or ALB.     |
| “Need to direct global users to the nearest AWS Region.”              | Geographic routing for global applications.              | Public Hosted Zone + Latency or Geoproximity policy. |
| “Need DNS failover between two public endpoints.”                     | Health checks with DNS-based failover.                  | Public Hosted Zone + Health check + Failover routing policy.  |
| “App hosted in EC2 behind an NLB.”                                    | Alias records for AWS-managed endpoints.                | Use Alias A record → NLB DNS name.                            |

🧠 **Exam tip:** Questions about routing to the nearest region may include both Latency and Geoproximity policies as the answers. If **failover** is part of the scenario, think Latency (Geoproximity does not failover); on the other hand, if the scenario includes **load balancing across AWS and on premise**, think Geoproximity.

---

## 🧱 3. Key Record Types and Exam Traps

| **Record Type** | **Purpose**                                           | **Exam Tip**                                                           |
| --------------- | ----------------------------------------------------- | ---------------------------------------------------------------------- |
| **A / AAAA**    | Map domain to IP (IPv4/IPv6).                         | Don’t manually enter AWS IPs for services like ALB or CloudFront — those are dynamic. Use Alias records instead. |
| **CNAME**       | Map one name to another.                              | Can’t use CNAME at the zone apex (e.g., example.com).                  |
| **Alias**       | AWS magic record — resolves to AWS-managed endpoints. | Works at zone apex. Use for ALB, NLB, CloudFront, S3 static site, etc. |
| **MX / TXT**    | Email or verification records.                        | Sometimes needed for SES or ACM certificate validation.                |

---

### 🧭 When to Use A / AAAA Records in AWS

Even though AWS Alias records are powerful, **A/AAAA records still have their place**, especially in **hybrid or custom architectures**.

| **Use Case**                                 | **Example Scenario**                                                                | **Why A/AAAA (not Alias)**                                                                        |
| -------------------------------------------- | ----------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------- |
| **On-premises or external servers**          | Your company runs a legacy app in an on-prem data center reachable via a static IP. | Alias targets can’t point to external IPs. You must use a standard **A/AAAA record**.             |
| **Third-party CDN or service**               | You’re using a non-AWS CDN (like Cloudflare or Akamai).                             | Those use external DNS names — Alias works only with AWS resources.                               |
| **Static Elastic IP**                        | You manually assigned an Elastic IP to an EC2 instance or NLB.                      | Alias works for AWS-managed DNS names, not directly for Elastic IPs — so an **A record** is fine. |
| **Private hosted zone with custom services** | Internal app hosted on a fixed EC2 IP within a VPC.                                 | Alias targets can’t point to arbitrary private IPs — use **A records**.                           |

💡 **Exam Tip:**
If the question says something like:

> “The company hosts a legacy application in an on-premises data center and needs to make it resolvable from a Route 53 hosted zone.”

✅ The correct answer is an **A record** (or AAAA for IPv6), *not* an Alias — because the target is **not an AWS-managed endpoint**.

---

## 🏗️ 4. Routing Policies in Public Hosted Zones

AWS loves to test your ability to pick the **right routing policy** for a given requirement.
Here’s your cheat sheet:

| **Routing Policy**     | **What It Does**                         | **Typical Use Case**                 |
| ---------------------- | ---------------------------------------- | ------------------------------------ |
| **Simple**             | One record → one endpoint                | Small site, static content           |
| **Weighted**           | Split traffic across endpoints           | Canary deploys, load testing         |
| **Latency-Based**      | Route users to lowest latency region     | Multi-region web apps                |
| **Failover**           | Active-passive DNS failover              | DR scenarios                         |
| **Geolocation**        | Route by user location                   | Compliance or language-based routing |
| **Geoproximity**       | Route by user and resource location bias | Gradual traffic migration            |
| **Multi-Value Answer** | Return multiple healthy IPs              | Basic load balancing (no ELB)        |

📝 **Exam Tip:** Health checks only work in **public hosted zones** — they can’t directly check private endpoints (unless you use CloudWatch alarms or custom Lambda checks).

---

## 🧩 5. Public Hosted Zones and Other AWS Services

* **CloudFront / ALB / NLB** → Use **Alias** for clean, managed integration (not A/AAAA records!)
* **S3 Static Website Hosting** → Use Alias record to the S3 website endpoint (only for *website-enabled* buckets).
* **Global Accelerator** → Also supports Alias records.
* **ACM Certificates** → Often verified through DNS TXT records in your hosted zone.
* **Route 53 Resolver Query Logging** → You can enable logs even for public zones, to track resolution activity.

---

## 🧠 6. Key Exam Takeaways

* **Public Hosted Zones = Internet-facing DNS.**
* Know how **alias vs CNAME** behaves at the **zone apex**.
* **Delegation** must be correct at the registrar — NS records must match.
* **Health checks** only apply to **public endpoints**.
* **Routing policies** are key to scenario-based questions.
* If the question mentions **multi-region**, **public traffic**, or **latency-based routing**, it’s almost always **a public hosted zone**.

---

## 🌰 Bit’s Closing Thoughts

When in doubt, ask yourself:

> “Is this DNS record meant for the *internet* or for *internal AWS use*?”

If it’s for internet-facing traffic — that’s a **public hosted zone** problem.
If it’s for your private workloads — think **private hosted zone** or **Route 53 Resolver**.

Keep your nuts organized and your name servers delegated correctly — and you’ll ace these DNS questions, one query at a time! 🐿️💪
