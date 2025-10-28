+++
title="Analyzing Intra-VPC connectivity"
date=2024-10-26

[taxonomies]
exams = ["Advanced Networking"]
topics = ["network design", "visibility", "Transit Gateway Network Manager"]
[extra]
toc = true
comments = true
+++

Hello, network-trailblazers! Bit here, perched on a branch overlooking your VPC forest. Today we’re going to explore a powerful tool that helps you **see the paths** between your AWS network components—whether within one VPC, across peering, or even hybrid setups. The tool? VPC Reachability Analyzer!

If you’re prepping for the Advanced Networking exam, you’ll want to know how to use this service for **visibility, validation, and troubleshooting** of your AWS (and hybrid) network connectivity.

<!--more-->

---

## 🧭 1. What is Reachability Analyzer and why it matters

At its simplest, Reachability Analyzer lets you pick a **source** and a **destination** resource (e.g., an EC2 instance, NAT gateway, or Transit Gateway attachment) and asks: “Is there a valid path from source → destination for a given protocol and port?”
If yes → it shows the path.
If no → it shows **which component is blocking** the path (security group, route table, peering connection, etc.).

For the exam: when you see scenarios like:

> *“You need to validate connectivity between resources in different accounts/regions”*
> or
> *“Which AWS service helps you verify intended connectivity and identify misconfigurations?”* — you should think **Reachability Analyzer**.

---

## 🔍 2. Key Features & Use Cases

### ✅ a) Connectivity Validation

You can test reachability within a VPC, or between VPCs, Transit Gateway attachments, peering, VPNs, etc. It supports many resource types: ENIs, IGWs, NAT gateways, TGWs, load balancers, VPC endpoints.

Use case:

> “Verify that workload A in VPC1 can reach database B in VPC2 over TGW route table” → use Reachability Analyzer.

### 🛠 b) Troubleshooting Misconfiguration

If the path is *Not reachable*, the tool provides an **explanation code** such as `ENI_SG_RULES_MISMATCH`, `NO_ROUTE`, `TGW_RTB_CANNOT_ROUTE`, etc.

Use case:

> “Why can’t traffic flow to the backup server after the peering was created?” → run analyzer, inspect explanation.

### 🔄 c) Automation & Multi-Account Visibility

Support for cross-account analyses: you can enable trusted access with AWS Organizations, designate a delegated administrator, and run path analyses across accounts.

Use case:

> “Network admin wants central visibility of connectivity across all accounts in his organization.” → Reachability Analyzer + Organizations.

### 📋 d) Hybrid & Complex Network Paths

Works with TGWs, peering connections, NATs, VPC endpoints; can include or exclude intermediate components for granular analysis.
It can even handle resources which connect to on premises networks such as Site-to-Site VPN and Direct Connect. But remember! It cannot cross the boundary to an on-premise network: it can only use these components as destinations or intermediate components to other resources hosted in AWS!

Use case:

> “Exclude this firewall appliance when analysing a direct path for compliance audit” → use include/exclude option.

---

## 🧩 3. How to Use It (Exam-Style Steps)

1. Decide **Source** and **Destination**—choose the resource type (ENI, IGW, TGW) and specify IPv4 (note: IPv6 not supported).
2. Optionally define **protocol** (TCP/UDP) and **port**—helps refine the path.
3. Optionally **Include** or **Exclude** intermediate components (e.g., exclude a firewall if you want to test bypass).
4. Run **Create and analyze path**. The result shows “Reachable” or “Not reachable”.
   * If reachable, you can see the path hops.
   * If not reachable, you get explanation codes guiding what’s blocked.
5. Fix configuration, then re-run the analysis to validate.

---

## ✅ 4. Best Practices & Exam Traps

### Best Practices

* **Use across accounts**: Enable trusted access with AWS Organizations, designate a delegated admin account so you can analyse paths across multiple accounts.
* **Use filters**: By specifying source/dest IP, port or components, you reduce “false positives” and focus your analysis.
* **Include/exclude components**: Useful for auditing “was my firewall bypassed?” or “did my path avoid the inspection appliance?”
* **Regular validation**: As network configs change (routes, firewalls, TGWs), rerun analysis as part of compliance checks.

### Exam Traps

* **IPv6 is not supported** — the tool currently supports only IPv4.
* **Path exists doesn’t guarantee data-plane health** — it’s a configuration model only, not actual packet capture.
  * Reachability Analyzer checks Security Groups, Network ACLs, and Route Tables.
  * It does NOT check things like operating system firewalls, application-layer misconfigurations, or interface status (e.g., if a VPN tunnel is actually up and passing traffic, which TGW Network Manager or CloudWatch would check).
* **Gateway Load Balancer limitations** — GWLBe paths need special attention (e.g., GENEVE protocol) and some paths aren’t supported.
* **Cross-account needs trusted access** — trying to analyse across accounts without enabling trusted access will fail.
* **Explanation codes matter** — you may need to interpret a code like `NO_ROUTE` or `ELBV2_LISTENERS_MISMATCH`. Knowing those codes gives you an edge.

---

## 📚 Further Reading

* [What is Reachability Analyzer? — AWS Docs](https://docs.aws.amazon.com/vpc/latest/reachability/what-is-reachability-analyzer.html) 
* [Getting started with Reachability Analyzer — AWS Docs](https://docs.aws.amazon.com/vpc/latest/reachability/getting-started.html)
* [Cross-account analyses for Reachability Analyzer — AWS Docs](https://docs.aws.amazon.com/vpc/latest/reachability/multi-account.html) 
* [Explanation codes for Reachability Analyzer — AWS Docs](https://docs.aws.amazon.com/vpc/latest/reachability/explanation-codes.html)

---

### 🐿️ Bit’s Final Nut

When the exam mentions a network path between resources—especially across accounts, VPCs, or regions—and asks you to verify connectivity or find misconfigurations, **Reachability Analyzer** is your go-to tool. Use it to *see* the path, *identify* blocks, and *validate* your changes.

Keep your visibility sharp, your nuts stored, and your packet paths unblocked! 🌰🐿️

[1]: https://docs.aws.amazon.com/vpc/latest/reachability/what-is-reachability-analyzer.html?utm_source=chatgpt.com "What is Reachability Analyzer? - Amazon Virtual Private Cloud"
[2]: https://docs.aws.amazon.com/vpc/latest/reachability/how-reachability-analyzer-works.html?utm_source=chatgpt.com "How Reachability Analyzer works - Amazon Virtual Private Cloud"
[3]: https://docs.aws.amazon.com/vpc/latest/reachability/explanation-codes.html?utm_source=chatgpt.com "Reachability Analyzer explanation codes - AWS Documentation"
[4]: https://www.amazonaws.cn/en/blog-selection/visualize-and-diagnose-network-reachability-across-aws-accounts-using-reachability-analyzer/?nc2=h_mo_ls&utm_source=chatgpt.com "Visualize and diagnose network reachability across Amazon Web ..."
[5]: https://docs.aws.amazon.com/vpc/latest/reachability/getting-started.html?utm_source=chatgpt.com "Getting started with Reachability Analyzer - AWS Documentation"
[6]: https://docs.aws.amazon.com/organizations/latest/userguide/services-that-can-integrate-ra.html?utm_source=chatgpt.com "Amazon VPC Reachability Analyzer and AWS Organizations"
[7]: https://docs.aws.amazon.com/vpc/latest/reachability/multi-account.html?utm_source=chatgpt.com "Cross-account analyses for Reachability Analyzer"
