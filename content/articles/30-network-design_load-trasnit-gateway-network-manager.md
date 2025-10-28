+++
title="Network Visibility with CloudWatch and Related Services"
date=2024-10-26

[taxonomies]
exams = ["Advanced Networking"]
topics = ["network design", "visibility"]
[extra]
toc = true
comments = true
+++

Hello cloud explorers! Bit here again, ready to climb higher into the treetops of advanced network design. 🌲
Today we’re diving deep into how you can **see, monitor, and automate** your global and hybrid network infrastructure using **Transit Gateway Network Manager (TGW NM)**. If you have multiple VPCs, regions, accounts, and on-premises sites, this article helps you tie it all together—visibility is the first step to control.

<!--more-->

---

## 🚀 1. What is TGW Network Manager and Why You Need It

At its heart, TGW NM is the **management plane** for your AWS network backbone—including VPCs, Transit Gateways (TGWs), on-premises links, VPNs, and SD-WAN tunnels.

The foundational piece here is the **Global Network**:

* It’s a logical container that you create to hold **all** your TGWs, Connect attachments, sites, and devices across all accounts and regions.
* Every TGW you want monitored and managed must be registered into this Global Network.
* Think of it like the scroll of your cloud map—it holds the inventory, relationships, and topology data.

Without the Global Network, you don’t get the centralized visibility or the automation capabilities. For the exam, when you see "register TGWs from multiple accounts/regions," that means **Global Network first**.

---

## 🔍 2. Core Capabilities You Must Know

### 🧭 a) Topology & Inventory Views

* Once TGWs, VPC attachments, VPN/Direct Connect links, and on-prem “sites” are registered, TGW NM builds a **topology map** and **geographic map** so you can visually explore your global network.
* Sites and Devices let you bring on-premises hubs and SD-WAN equipment into the picture.
* Inventory tab shows you which TGW attachments exist, in which account/region, and their status.

**Exam clue:** “Single console to view TGWs in all accounts and on-premises links” → Global Network via TGW NM.

---

### 📈 b) Metrics & Health Monitoring

* TGW NM provides metrics per TGW and attachment: Bytes/Packets In/Out, Packets Dropped – No Route, Tunnel Down, BGP session status for TGW Connect.
* These metrics roll into **Amazon CloudWatch** where you can graph them, alarm on them, or create dashboards.
* Especially critical: Attachments that have "No Route" drops often indicate mis-routed traffic or a broken path.

**Exam clue:** “Detect packet black-holes between VPCs” → Use TGW NM metric “Packets Dropped – No Route” + CloudWatch alarm.

---

### 🛠️ c) Event Logging & Automation via EventBridge

* TGW NM emits **events** (via AWS EventBridge) for key state changes: e.g., TGW attachment state changes, Connect tunnel status changes, BGP session disruptions, route propagation issues.
* You can use these events to trigger automation workflows: Lambda functions to re-route traffic, send Slack/Email alerts, or start fail-over procedures.
* This is a major exam requirement: visibility *and* automation.

**Exam clue:** “Automate response when TGW Connect tunnel goes down” → TGW NM event → EventBridge → Lambda/Step Functions.

---

### 🌐 d) Hybrid & SD-WAN Integration

* TGW NM supports **TGW Connect** attachments (GRE tunnels + BGP) designed for SD-WAN destinations.
* You can monitor those BGP sessions, see latency/jitter metrics, and include on-premises devices in topology.
* Use IP targets, Connect peers, Link Aggregations, and see them side-by-side with your VPCs.

**Exam clue:** “Visualize SD-WAN fabric and AWS TGW connections together” → TGW NM Topology + Connect metrics.

---

### 🤝 e) Multi-Account / Multi-Region Governance

* TGW NM works with **AWS Organizations**: designate a **Delegated Administrator account** to manage the Global Network for all member accounts.
* This enables cross-account registration of TGWs and sites without logging into each account.
* You can then build unified dashboards in the central account or allow read-only views to appropriate teams.

**Exam clue:** “Single operational view across all accounts/regions” → TGW NM Global Network + Organizations integration.

---

## 🧩 3. Example Exam-Friendly Scenarios

Here are a few you’re likely to see:

**Scenario A:**

> “A company uses TGWs in 3 regions and a data centre via Direct Connect. They need a single console to monitor the entire network health and automatically alert when a tunnel fails.”

> **Answer:** Use TGW NM in central network account → register TGWs and on-prem site → enable CloudWatch metrics + EventBridge alerts.

**Scenario B:**

> “An SD-WAN vendor has GRE tunnels to AWS TGW Connect attachments. The network team wants to see BGP session state, route propagation, and per-tunnel packet drops.”

> **Answer:** Use TGW NM Connect attachment monitoring + “Packets Dropped – No Route” metric + topology view.

**Scenario C:**

> “During a regional outage, traffic must auto-shift to other regions. The network team wants archive of route table changes and be notified when traffic is rerouted incorrectly.”

> **Answer:** TGW NM Global Network for visibility + CloudTrail/Config for route changes + EventBridge for auto-alert.

---

## ✅ 4. Best Practices & Exam Traps

* **Always create the Global Network first**, then register all assets—TGWs, Connect attachments, sites, devices.
* **Cross-account setup** is not optional; if TGWs are in other accounts, use a delegated admin via AWS Organizations.
* **EventBridge matters**: Without it you have visibility but not automation—many exam questions expect auto-response.
* **Don’t assume presence equals correct routing**: A TGW attachment may show “Up” but still have “No Route” drops—use the specific metric.
* **Watch cost of metrics/logs**: Only enable metrics for high-priority attachments; “enable all” might break budget.
* **Topology view latency**: The view may lag; do not assume instant update.
* **TGW Connect vs VPN**: Connect attachments show different metrics (BGP, GRE) than traditional VPN—choose the right one.
* **Exam trick:** If question says “Visualize and automate across accounts/regions and on-prem” → Look for **Transit Gateway Network Manager**, not just CloudWatch or VPC Flow Logs.

---

## 📚 Further Reading

* [Get started with AWS Global Networks (Transit Gateway Network Manager) — AWS Docs](https://docs.aws.amazon.com/network-manager/latest/tgwnm/gnw-getting-started.html)
* [Use Transit Gateway Network Manager to visualize TGWs across all accounts — AWS Blog](https://aws.amazon.com/blogs/networking-and-content-delivery/how-to-use-aws-network-manager-to-visualize-transit-gateways-across-all-accounts-in-the-aws-organization/)
* [Monitor Transit Gateway and Site-to-Site VPN in Network Manager — AWS Knowledge Center](https://repost.aws/knowledge-center/network-manager-monitor-transit-gateway)
* [AWS Transit Gateway Network Manager API Reference — events, metrics, attachments](https://docs.aws.amazon.com/network-manager/latest/tgwnm/reference.html)
* [Blog: AWS Transit Gateway Network Manager for SD-WAN visibility](https://netcraftsmen.com/aws-transit-gateway-network-manager/?utm_source=chatgpt.com)

---

### 🐿️ Bit’s Final Nut

With TGW NM you’re not just monitoring bits and bytes—you’re watching your entire network ecosystem: global, hybrid, multi-account. It’s your **command centre** for connectivity. When the exam asks: *“How do you see TGWs, on-prem links, and SD-WAN tunnels in one place and automate responses?”* — you’ll know the answer. Stay visible, stay proactive, and may your network nuts always fall into place. 🌰🐿️
