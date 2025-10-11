+++
title="DNS Protocol Review"
date=2024-10-11

[taxonomies]
exams = ["Advanced Networking"]
topics = ["network design", "DNS"]
[extra]
toc = true
comments = true
+++

Hello again, cloud explorers! Bit here — ready to help you dig into one of the most important building blocks of the internet: **DNS (Domain Name System)**.

Whether your network is public, private, or a mix of both, understanding how DNS works is key to designing reliable architectures. This article focuses on the **core concepts of the DNS protocol** that you need to know for the **AWS Advanced Networking Specialty** exam — and for any serious networking work.

---

## 🌍 What Is DNS?

The **Domain Name System (DNS)** is like the phonebook of the internet. It translates human-friendly names like `bits-guides.com` into IP addresses that computers can understand (like `192.0.2.10`).

DNS uses a **hierarchical and distributed** structure — meaning no single server holds all the records. Instead, authority is divided into **zones**, each managed by its own name servers.

---

## 🧱 DNS Records

DNS data is stored in **resource records (RRs)** inside a zone file. Each record has a **type**, **name**, **value**, and **TTL** (time to live).

| Record Type | Purpose                                                     | Example                                        |
| ----------- | ----------------------------------------------------------- | ---------------------------------------------- |
| **A**       | Maps a hostname to an IPv4 address                          | `www.bits-guides.com → 192.0.2.10`             |
| **AAAA**    | Maps to an IPv6 address                                     | `www.bits-guides.com → 2001:db8::1`            |
| **CNAME**   | Alias one name to another                                   | `blog.bits-guides.com → www.bits-guides.com`   |
| **MX**      | Defines mail servers for a domain                           | `bits-guides.com → mail.bits-guides.com`       |
| **TXT**     | Holds arbitrary text data (e.g., SPF records, verification) | `v=spf1 include:_spf.google.com`               |
| **NS**      | Lists the authoritative name servers for a zone             | `bits-guides.com → ns1.dnsprovider.net`        |
| **SOA**     | Start of Authority record, defines the zone’s main settings | Primary server, contact, serial number, timers |

---

## ⏱️ Time To Live (TTL)

Each record has a **TTL**, which tells resolvers how long they can cache the record before re-querying the authoritative server.

* **Short TTLs** (e.g., 60 seconds) → faster updates, higher query volume.
* **Long TTLs** (e.g., 24 hours) → lower query load, slower propagation of changes.

Use short TTLs when testing or migrating services; longer TTLs for stable records.

---

## 🔐 DNSSEC (DNS Security Extensions)

DNSSEC protects the integrity of DNS responses. It doesn’t encrypt DNS traffic — instead, it **adds digital signatures** so that clients can verify the data wasn’t tampered with.

Here’s how it works:

1. The authoritative zone signs its records using a private key.
2. Resolvers verify the signatures using the corresponding public key.
3. A chain of trust is formed from the root zone (`.`) down to the domain’s zone.

DNSSEC helps prevent attacks like **DNS spoofing** or **cache poisoning**, ensuring users reach the genuine site.

---

## 🗂️ Zones and Delegation

A **zone** is a portion of the DNS namespace managed by a specific entity.

For example:

* The **root zone** (`.`) delegates to **top-level domains (TLDs)** like `.com` or `.org`.
* Each TLD delegates to authoritative name servers for registered domains (like `bits-guides.com`).

### DNS Delegation

Delegation happens via **NS records**:

* The parent zone lists which name servers are authoritative for the child zone.
* The child zone must also include matching **NS records** at its apex.

This distributed design allows organizations to manage their own subdomains (e.g., `dev.bits-guides.com`) independently.

---

## 🧭 Recursive vs. Authoritative Servers

There are two main types of DNS servers:

| Type                     | Description                                                                                          |
| ------------------------ | ---------------------------------------------------------------------------------------------------- |
| **Recursive Resolver**   | Finds the answer on behalf of a client by querying multiple servers, caching results for efficiency. |
| **Authoritative Server** | Holds the actual DNS records for a zone and provides official answers.                               |

A typical DNS lookup flows like this:

1. A client asks a recursive resolver (often your ISP or a public resolver).
2. The resolver checks its cache — if no match, it queries the root, then TLD, then authoritative servers.
3. The resolver returns the final answer to the client.

---

## Bit’s Study Notes

* **DNSSEC = authenticity + integrity**, not encryption.
* **NS + SOA = the core of zone authority.**
* **Delegation** is how the DNS hierarchy scales globally.
* **TTL** values affect caching and propagation delays.
* Know the **purpose of each record type** — they’re easy exam points!

---

Understanding DNS is like learning how the forest pathways connect — once you know the structure, everything else (like AWS Route 53) will make a lot more sense.

Stay tuned for the next guide, where we’ll explore **how DNS is implemented and managed in AWS environments.** 🐿️
