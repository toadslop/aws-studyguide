+++
title="Routing Fundamentals"
date=2024-11-02

[taxonomies]
exams = ["Advanced Networking"]
topics = ["network design", "routing"]
[extra]
toc = true
comments = true
+++

Hello network adventurers! Bit here, perched on a branch overlooking the meeting of your on-premises data center and your AWS cloud environment. Today, we’re diving into the plumbing of connectivity: **routing fundamentals**. Because before you pick a service or a link, you need to understand *how* traffic finds its way from your on-premises network into AWS — and back — using the right routing strategy.

<!-- more -->

Let’s map the paths together! 🌰

---

## 🧭 1. What Routing Means in Hybrid Networks

In a hybrid connectivity scenario (e.g., using AWS Site-to-Site VPN, AWS Direct Connect, or a combination), routing determines **which network traffic goes where, how fast, and via which path**.
Key decisions you’ll face:

* Do you use **static routes** (manually configured)?
* Or **dynamic routing** (automatic route exchange, such as with BGP)?
* How do you influence traffic flows (load-sharing, active/passive) using route attributes?
* How do you account for physical / Layer-2 interconnects (LAGs, optics, VLANs) and overlays (GRE, IPsec)?

These are *fundamental* questions for Task 1.5 of the exam.

---

## 🔀 2. Static vs. Dynamic Routing — Quick Comparison

### Static Routing

* Routes are manually configured and fixed.
* Best for simple networks, fixed connectivity, known paths.
* Pros: Predictable, low overhead, simpler to secure.
* Cons: Doesn’t adapt to link failures or topology changes automatically.

### Dynamic Routing (e.g., BGP)

* Uses protocols to exchange routing information automatically.
* Ideal for large/hybrid networks where links may fail, change, or you want redundancy/load-sharing.
* Pros: Automatic failover, route scaling, path adaptation.
* Cons: More complex, requires management of routing attributes and security.

👀 *Exam Clue:* If the scenario mentions “links may fail or we need active/active traffic across Regions”, lean toward **dynamic routing (BGP)**. If it says “single link, simple stub network”, static might suffice.

---

## 🌐 3. BGP & Route Attributes in Hybrid Designs

When you pick dynamic routing with BGP (commonly used for on-prem ↔ AWS via Direct Connect or VPN), you should know how BGP lets you **influence traffic flows** using attributes and policies:

* **AS_Path**: The shorter the path, the more preferred.
* **Local Preference**: Higher values are preferred within an AWS Region.
* **MED (Multi-Exit Discriminator)**: Lower values are preferred *if* all other attributes are equal — but note that AWS gives *very low priority* to MED for Transit/Private VIF path selection. It’s best not to rely on it for traffic engineering.
* **Community Tags**: AWS-specific BGP community tags control routing preferences and scope — see below.

### 🧩 AWS BGP Community Tags

AWS defines two main groups of BGP community tags that influence routing between your on-premises environment and AWS:

| **Community Tag** | **VIF Type**           | **Purpose**                                          |
| ----------------- | ---------------------- | ---------------------------------------------------- |
| **7224:7300**     | Private & Transit VIFs | High preference (preferred path)                     |
| **7224:7200**     | Private & Transit VIFs | Medium preference (load sharing)                     |
| **7224:7100**     | Private & Transit VIFs | Low preference (backup path)                         |
| **7224:9100**     | Public VIFs            | Local Region only                                    |
| **7224:9200**     | Public VIFs            | Continental scope (e.g., all North American regions) |
| **7224:9300**     | Public VIFs            | Global scope (all public AWS Regions)                |

💡 *Exam Tip:* These “local preference” communities (the 7x00 series) are used by AWS to decide **which path to use when sending traffic *from AWS to you***. The higher the number, the higher the preference.

### 🚦 VPN Routing and ECMP

For AWS Site-to-Site VPNs (especially those terminating at a **Transit Gateway**), AWS supports **Equal-Cost Multi-Path (ECMP)** routing when BGP attributes (AS_Path, Local Pref, etc.) are identical. This allows **active/active** routing across redundant tunnels — great for resilience and load-balancing.

---

## 🧭 4. The AWS BGP Path Selection Priority

When multiple routes exist, AWS follows this exact order of evaluation for choosing the best path **for traffic leaving the AWS network** (for example, from AWS to your data center):

1. **Longest Prefix Match (LPM)** — The most specific prefix always wins. A /27 route will beat a /24 route every time, regardless of community tags or other attributes.
2. **BGP Local Preference** — Higher local preference (for example, via 7224:7300) is preferred.
3. **AS_Path Length** — Shorter AS paths are preferred.
4. **MED (Multi-Exit Discriminator)** — Lower MED wins, but AWS may not consider MED in many cases, particularly on Public VIFs.
5. **Tie-Breaker** — If all attributes are identical, AWS picks the path with the lowest peering IP address.

🎓 *Exam Reminder:* Always remember that **LPM beats everything else** — even your fancy community tags.

---

## 🏗️ 5. Hybrid Connectivity Architecture Considerations

When designing connectivity between on-premises and AWS, remember routing is just one piece — you must also think about physical and overlay layers:

* **Layer 1 & 2**: For example, a Link Aggregation Group (LAG), optical fibre light-levels, jumbo frames.
* **Encapsulation/Encryption**: GRE tunnels, IPsec over VPN, Transit Gateway Connect overlays.
* **Resource Sharing**: Multi-account, multi-Region topologies require careful routing design (avoiding overlapping CIDRs, using route-tables, propagation).

---

## 🧠 6. Exam Traps & Study Tips

### 🚧 Exam Traps

* **Trap:** “Use static routing for all hybrid links because it’s simpler.”
  **Truth:** In large/hybrid networks with fail-over or dynamic links, static won’t scale or adapt.
* **Trap:** “BGP automatically solves everything — you don’t need policies.”
  **Truth:** BGP gives control but you must design attributes (Local Pref, AS_Path, Communities) to shape traffic.
* **Trap:** “Routing alone makes connectivity redundant.”
  **Truth:** You must design both physical/overlay connectivity + routing strategy.
* **Trap:** “Using one Direct Connect link is enough if you configure routing.”
  **Truth:** Redundancy often requires multiple links, dynamic routing, and fail-over paths.
* **Trap:** “Use the High Preference Community Tag (7224:7300) to guarantee traffic always uses Link A.”
  **Truth:** **LPM always wins** — if Link B advertises a more specific prefix, traffic will prefer Link B even if Link A has higher local preference.

### ✅ Study Tips

* Memorize the AWS **BGP path selection order** — it’s often tested.
* Be able to **explain when to use BGP** (hybrid, multi-link, active/active) vs static.
* Understand **AWS-specific community tags** for local preference and scope.
* Know that **MED is weak** in AWS path selection — don’t rely on it for critical routing.
* Remember **ECMP** is supported on VPN tunnels for load sharing.
* Always think about **LPM** before any other attribute when predicting traffic paths.

---

## 📚 Further Reading

* [Dynamic Routing using Amazon VPC Route Server – AWS Blog](https://aws.amazon.com/blogs/networking-and-content-delivery/dynamic-routing-using-amazon-vpc-route-server/)
* [AWS Direct Connect BGP Communities – AWS Documentation](https://docs.aws.amazon.com/directconnect/latest/UserGuide/routing-and-bgp.html)

---

### 🐿️ Bit’s Final Nut

Think of routing like your forest trail system. Static trails are fixed paths you build and maintain; dynamic trails adjust when trees fall or new branches grow. But even in Bit’s forest, the **narrowest, most specific trail (LPM)** always gets you there fastest! So, when you see community tags, AS paths, or MEDs, remember — specificity rules the woods. 🌲

Stay routed, stay ready, and keep scrambling toward that certification! 🌰
