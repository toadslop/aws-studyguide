+++
title="Domain Registration"
date=2024-10-13

[taxonomies]
exams = ["Advanced Networking"]
topics = ["network design", "DNS", "Route 53"]
[extra]
toc = true
comments = true
+++

Hiya, Bit here! Let’s take a quick scamper through how **domain registration** works — both in general and specifically within **Amazon Route 53**.

This topic may sound basic, but it’s a common foundation question on the exam, especially when evaluating **public DNS architectures** or troubleshooting **domain resolution**.

<!--more-->

---

## 🏗️ 1. How Domain Registration Works (Refresher)

When you register a domain, you’re essentially reserving a name in the global **DNS namespace** — like *bits-guides.com*.

Here’s what happens under the hood:

| Step                            | What Happens                                                                          | Key Concept                                                                 |
| ------------------------------- | ------------------------------------------------------------------------------------- | --------------------------------------------------------------------------- |
| 1. Choose a Domain              | You pick a unique name under a top-level domain (TLD), like `.com` or `.net`.         | Registrars are authorized by ICANN or regional registries to sell domains.  |
| 2. Provide Contact & WHOIS Info | You supply owner, admin, and tech contact data.                                       | Required for ICANN compliance (may be private if WHOIS privacy is enabled). |
| 3. Specify Name Servers         | You point your domain at **authoritative name servers** that hold your DNS zone data. | These NS records are published to the TLD registry.                         |
| 4. DNS Propagation              | The TLD registry updates the root servers.                                            | Takes time (usually minutes to hours) before your domain resolves globally. |

🧠 **Exam tip:** Domain registration is distinct from hosting DNS records. Registering a domain only reserves the name — you still need a DNS service (like Route 53) to manage records.

---

## ☁️ 2. How Domain Registration Works in Route 53

Amazon Route 53 can act as both your **domain registrar** and your **DNS service**, but these are separate roles.

| Role            | What It Does                            | AWS Feature                  |
| --------------- | --------------------------------------- | ---------------------------- |
| **Registrar**   | Manages ownership of the domain.        | Route 53 Domain Registration |
| **DNS Service** | Stores records and answers DNS queries. | Route 53 Hosted Zones        |

### a. Registering a Domain

You can register a new domain directly from the **Route 53 console**.
When you do, AWS automatically creates a **public hosted zone** for that domain and pre-populates it with the correct **NS** and **SOA** records.

Supported TLDs are listed here: [Route 53 domain registration pricing](https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/registrar-tld-list.html).

---

### b. Using an External Registrar

If your domain was registered elsewhere, you can still:

1. Create a **public hosted zone** in Route 53.
2. Update your registrar’s **NS records** to point to the Route 53 name servers.

🧩 **Exam Clue Example:**

> “A company registered its domain with GoDaddy but wants to use Route 53 for DNS management.”
> ✅ The answer: Create a hosted zone in Route 53 and update the registrar’s NS records.

---

## 🔁 3. Domain Transfers and Delegation

Once a domain is registered, ownership and DNS control can be **moved** or **delegated**.
Understanding the difference is critical for exam questions.

### a. Domain Transfers

Transfers are about *ownership* — who manages the registration.

| Scenario         | What Happens                                         | Key Point                                                |
| ---------------- | ---------------------------------------------------- | -------------------------------------------------------- |
| **Transfer In**  | Move your domain from another registrar to Route 53. | Brings ownership under AWS billing and management.       |
| **Transfer Out** | Move your Route 53 domain to another registrar.      | Route 53 releases the domain; DNS hosting is unaffected. |

💡 **Exam Tip:**
A domain transfer doesn’t delete or move your hosted zone.
DNS service stays live unless you remove it.

---

### b. Domain Delegation

Delegation is about *DNS resolution control* — who answers queries for subdomains.

| Scenario                     | What Happens                                                                                        | Example                                                       |
| ---------------------------- | --------------------------------------------------------------------------------------------------- | ------------------------------------------------------------- |
| **Subdomain delegation**     | You create a new hosted zone for a subdomain and reference its NS records in the parent zone.       | Delegate `api.bitsguides.com` to a different account or team. |
| **Cross-account delegation** | You share DNS responsibility between AWS accounts by creating hosted zones and NS records manually. | Common in multi-account environments.                         |
| **Public-to-private split**  | You use separate hosted zones for public and private records of the same domain name.               | “Split-horizon DNS” setup.                                    |

🧩 **Exam Clue Example:**

> “The operations team wants to manage `dev.example.com` separately from `example.com`.”
> ✅ Answer: Create a new hosted zone for `dev.example.com` and add its NS records to the parent zone.

## 🧭 4. Domain Lifecycle and Ownership

Domains don’t last forever — they’re leased.
On the exam, you might see questions about expiration, transfer, or renewal.

| Stage                | What It Means                                              | Route 53 Behavior                               |
| -------------------- | ---------------------------------------------------------- | ----------------------------------------------- |
| **Active**           | Domain is registered and resolving.                        | Auto-renew enabled by default.                  |
| **Expiration grace** | Domain expired but can still be renewed (usually 30 days). | Route 53 emails owner before expiration.        |
| **Redemption**       | Domain deleted but can still be restored for a fee.        | Manual recovery required.                       |
| **Pending transfer** | Domain is being moved to or from Route 53.                 | DNS continues to work until transfer completes. |

🧠 **Exam tip:** Domain registration transfers are *management-level* — they don’t affect hosted zone data. Your DNS records remain in Route 53 unless you explicitly delete the hosted zone.

---

## 🌍 5. Route 53 and WHOIS Privacy

By default, Route 53 supports **WHOIS privacy protection** for most TLDs.
This hides registrant information from public WHOIS lookups — useful for compliance and spam reduction.

💡 **Exam angle:** Know that WHOIS privacy is managed per domain and doesn’t affect DNS behavior or availability.

---

## 🧠 Exam Summary — Key Takeaways

| Concept                            | What to Remember                                               |
| ---------------------------------- | -------------------------------------------------------------- |
| **Registrar vs DNS host**          | Route 53 can do both, but they’re separate services.           |
| **Name servers**                   | NS records define where DNS queries are answered.              |
| **External registrar integration** | Update NS records to point to Route 53 when using an outside registrar. |
| **Lifecycle**                      | Domains expire and can be renewed or transferred.              |
| **WHOIS privacy**                  | Hides owner info, no effect on DNS resolution.                 |

---

🌰 **Bit’s Final Nut of Wisdom**

> “Registering a domain just gives you the *name*.
> Hosting it in Route 53 gives it a *home*.” 🏡
