+++
title="Capturing Baseline Network Performance"
date=2024-10-31

[taxonomies]
exams = ["Advanced Networking"]
topics = ["network design", "visibility"]
[extra]
toc = true
comments = true
+++

Hello network explorers! Bit here, perched up on a branch in the AWS forest, peering into your connectivity vines. Today we’re going to dig into a key exam-worthy topic: **capturing baseline network performance**. Because before you can detect a problem, you need to **know what “normal” looks like**—especially in global, hybrid architectures.

<!-- more -->

Let’s lay down that baseline so you can spot the unexpected! 🌰

---

## 🧭 1. Why Baseline Performance Matters

If you design a network and you don’t know what “good” looks like, you’ll miss the subtle stuff: packet loss creeping up, latency slowly climbing, link capacity dwindling. On the exam, you’ll see scenarios like:

> “Traffic volumes appear stable, but user complaints of slowness are increasing—what should you monitor?”
> “After deploying a second region, how do you know the failover path is performing as originally designed?”

The answer lies in having captured **baseline metrics**, then watching for deviations.

---

## 📊 2. What Baseline Metrics to Capture

When defining baseline performance, consider these categories:

### a) Throughput & Utilization

* Capture **BytesIn**, **BytesOut**, **PacketsIn**, **PacketsOut** for key resources (e.g., AWS Transit Gateway attachments).
* Identify **BytesDropped** or **PacketDropCount** (e.g., `BytesDropCountBlackhole`, `BytesDropCountNoRoute`) to distinguish between intended and unintended packet drops.
* Sample for enough time (weeks) across peak and off-peak to build a realistic baseline.

### b) Latency & Loss

* Use tools like **Amazon CloudWatch Network Monitor** to measure **round-trip time (RTT)** and **packet loss** in hybrid networks.
* For regional VPC/AZ paths, capture response times using **client_response_time** and **target_processing_time** metrics (from ALB logs) to separate network latency from application latency.
* Baseline per link, per AZ, and per region—global networks often hide “grey failures.”

### c) Health & Availability

* Capture **Tunnel Up/Down**, **Attachment Status**, and **Impaired Count** metrics via **AWS Transit Gateway Network Manager**.
* Baseline link availability (< 1% outage monthly?), percent time in “Up” state over a sample period.
* Monitor hybrid links: **AWS Direct Connect link utilization**, **error events**, and **link state changes**.
* For physical link health, include **Direct Connect optical light levels** (`connectionLightLevelTx`, `connectionLightLevelRx`) and **CRC/Link Error Counts** (`ConnectionErrorCount`) — these capture low-level degradation before a full outage occurs.

### d) Hybrid & Multi-Region Visibility

* Baseline per-AZ metrics for **TGW** and **Cloud WAN** using their enhanced performance metrics.
* Baseline inter-region traffic & delays to understand what “normal failover” looks like.
* Identify expected patterns: e.g., Region-A serves 80% traffic, Region-B 20% under normal load.
* Include data from **AWS Network Manager Infrastructure Performance**, which benchmarks AWS backbone latency across regions — your global baseline reference point.

---

## 🛠️ 3. How to Design a Baseline Strategy

1. **Define SLA / KPI**: e.g., “P95 latency < 150 ms globally”, “packet loss < 0.1%”, “packet drops < 100 MB/day in black-hole”.
2. **Select metrics**: Throughput (BytesIn/Out), drops (BytesDropped), latency (RTT/loss), availability (Up/Down), and link health (CRC errors, optical levels).
3. **Collect data**: Use CloudWatch, Network Manager, Synthetic Monitor, and custom agents if needed.
4. **Segment by dimension**: Region, AZ, link type (DX, VPN, Internet), account.
5. **Define baseline windows**: Peak vs off-peak, weekly patterns, seasonal patterns.
6. **Monitor deviation**: Create alarms for when metrics stray beyond the “normal envelope” — leveraging CloudWatch **Anomaly Detection** for smarter thresholds.
7. **Document and review**: Keep reports, visualizations, dashboards—so you can show what “normal” looked like when diagnosing issues.

---

## 🧠 4. Exam Scenarios & Traps

### Scenario

> A company recently expanded into a second region and uses a Transit Gateway with multiple attachments. Users report degraded performance in Region-B even though traffic volume matches Region-A.
> **What Baseline insight helps?**

If you captured **per-AZ packet drop counts** and **inter-region latency**, you’d see the baseline for Region-B is normally 20 ms greater than Region-A. A jump to 50 ms indicates an issue, even though overall volume looks fine.

### Exam Traps

* **Trap:** “Throughput is constant so the network is fine.”
  **Reality:** Without baseline drops or latency, hidden issues like blackholes or retransmits may exist.
* **Trap:** “One period of measurement equals baseline.”
  **Reality:** Baseline requires **adequate period** (weeks) and segmentation by link/region/AZ.
* **Trap:** “Use CPUUtilization for network baseline.”
  **Reality:** Network performance uses network-specific metrics (Bytes, Drops, Latency) — not CPU.
* **Trap:** “Only monitor AWS side.”
  **Reality:** Hybrid networks require **on-prem metrics too** (VPN, DX, synthetic probes) and **end-to-end baselining**.

---

## 📚 Further Reading

* [CloudWatch metrics in AWS Transit Gateway](https://docs.aws.amazon.com/vpc/latest/tgw/transit-gateway-cloudwatch-metrics.html)
* [Monitor your global network with Amazon CloudWatch metrics – Network Manager](https://docs.aws.amazon.com/network-manager/latest/tgwnm/monitoring-cloudwatch-metrics.html)
* [Monitor hybrid connectivity with Amazon CloudWatch Network Synthetic Monitor](https://aws.amazon.com/blogs/networking-and-content-delivery/monitor-hybrid-connectivity-with-amazon-cloudwatch-network-monitor/)
* [Performance and metrics enhancements for AWS Transit Gateway and AWS Cloud WAN](https://aws.amazon.com/blogs/networking-and-content-delivery/performance-and-metrics-enhancements-for-aws-transit-gateway-and-aws-cloud-wan/)
* [Direct Connect metrics reference – CRC errors and optical levels](https://docs.aws.amazon.com/directconnect/latest/UserGuide/monitoring-cloudwatch.html)
* [Troubleshoot performance issues between on-premises and AWS when using AWS Site-to-Site VPN](https://repost.aws/articles/ARsHcx7IJYQ3uT8vhLuyqiAA/troubleshoot-performance-issues-packet-drop-latency-or-slow-throughput-between-on-premises-and-aws-vpc-when-using-aws-site-to-site-vpn)

---

### 🐿️ Bit’s Final Nut

Capturing the baseline is like measuring your tree trunk before the storm hits. When you know what “normal” is, you’ll spot when something’s off. On the Advanced Networking exam, your answer must show the **how** and **why** of baselining—not just “monitor everything.” Keep your metrics clear (including those hidden CRCs and optical levels!), your benchmarks solid, and your network performance ready for anything. Stay alert, stay ahead, and keep cracking those nuts! 🌰
