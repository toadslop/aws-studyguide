+++
title="Recommending Metrics for Network Status Visibility"
date=2024-10-31

[taxonomies]
exams = ["Advanced Networking"]
topics = ["network design", "visibility"]
[extra]
toc = true
comments = true
+++

Hey there, network watchers! Bit here, perched high in the branches of your cloud infrastructure. Today we’re going to dig into the **“what to monitor”** part—meaning which metrics you should pick so you can keep your network healthy, performant and ready for global/hybrid scale. If you’re prepping for the AWS Advanced Networking exam, this is one of the nuts you’ve got to crack.

<!-- more -->

---

## 🧭 1. Why Metric Selection Matters

Turning on logs or metrics willy-nilly doesn’t help much. What your architecture design needs is a **set of meaningful metrics** that answer questions like:

* Is this link healthy or degrading?
* Are we hitting capacity limits or bottlenecks?
* When did latency or packet losses spike—and where?
* Are the hybrid (on-prem ↔ AWS) paths performing within baseline?
* Are configuration changes or route-table updates impacting network health?

Selecting metrics is about **visibility**: giving your network team, your global architecture, and the exam grader proof that you *know* what to watch—and *why*.

---

## 📈 2. Core Network Metrics You Should Recommend

### a) Traffic & Throughput Metrics

* **BytesIn / BytesOut** (for AWS Transit Gateway attachments) — see volume of traffic flowing.
* **PacketsIn / PacketsOut** — count of packets. Helps when packet size changes but volume stays relatively constant.
* **BytesDropped or PacketsDropped** — especially for “no route” or “black-hole” drops in TGW.

**Why monitor:** High throughput might be fine—but if drops or blackholes are increasing, you’ve got a hidden issue.

---

### b) Latency & Loss Metrics

* **Round Trip Time (RTT)** and **Packet Loss Percentages** — for hybrid links or VPC-to-on-prem, using **Amazon CloudWatch Network Monitor** or similar.
* **Client Response Time**, **Target Processing Time**, **Request Processing Time** — for load balancers (from access logs and CloudWatch).
* **Network Performance Metrics on EC2 (ENA driver)** — e.g., when PPS (packages per second) limits are exceeded.

**Why monitor:** Latency and loss directly impact user experience. On the exam, a scenario might ask about degraded performance even though “traffic volume looks normal.”

---

### c) Health & Availability Metrics

* **Status and State Metrics** for attachments/tunnels/gateways (VPN tunnel UP/DOWN, TGW attachment status) via CloudWatch and TGW Network Manager.
* **Utilization Metrics** for interfaces or attachments nearing quota or capacity (TGW per-AZ quotas).
* **Baseline Deviation Alerts** – monitor deviation from historical baseline, not just absolute thresholds.
* **Route 53 Resolver Metrics** — for hybrid networks using Route 53 Resolver Endpoints, track `DNSQueries` and `HealthCheckStatus` to detect DNS failures or endpoint unavailability.

**Why monitor:** It’s not just “is the link up?” but “is the link healthy and performing as expected?”

---

### d) Hybrid Connectivity & Multi-Region Metrics

* Per-AZ metrics (for TGW) – differentiate traffic across Availability Zones.
* **Inter-Region Transit Metrics** – bytes transferred between regions and attachments in multiple accounts.
* **Direct Connect Link Metrics** – traffic, error rates, link flaps, and connection health over time.

**Why monitor:** Global architectures must handle failover, cross-region performance, and multi-account visibility. The exam will test your awareness of those dimensions.

---

## 🧩 3. How to Recommend These in a Design Scenario

When you are asked to *design monitoring* for a network (especially hybrid/multi-region), follow this flow:

1. **Define SLAs / KPIs:** e.g., “Global latency < 150 ms”, “Packet loss < 0.1%”, “No black-hole drops.”
2. **Map each KPI → metric(s):**

   * Latency → RTT / client_response_time
   * Availability → Tunnel status / attachment status
   * Throughput → BytesIn + BytesOut
   * Drops → PacketsDropped or BytesDropped
3. **Select & configure sources:** CloudWatch Metrics, Network Monitor, TGW Metrics, EC2 ENA metrics.
4. **Define alarm thresholds & dashboards:** e.g., average client_response_time > 200 ms for 5 minutes triggers an alarm.
5. **Ensure global/central visibility:** across accounts and regions—use **CloudWatch Metric Streams** to send metrics to S3 or Kinesis Firehose, or deploy the **CloudWatch Agent** on hybrid hosts for custom metrics.
6. **Document baseline and trend strategy:** measure initial baseline, monitor deviation over time.

---

## ✅ 4. Best Practices & Exam-Traps

**Best Practices:**

* Pick **meaningful metrics**, not *all* metrics. Focus on high-value ones (throughput, latency, drops, health).
* Maintain a **baseline** and monitor **deviations** rather than static thresholds.
* Use **per-AZ / per-region breakdowns** for global performance visibility.
* **Centralize metrics** using **CloudWatch Metric Streams**, **cross-account dashboards**, or **Kinesis Firehose** for hybrid/multi-region architectures.

**Exam Traps:**

* Choosing irrelevant metrics (e.g., `CPUUtilization` for a network-only SLA question).
* Ignoring packet drops or black-hole metrics (`BytesDropped` due to no route).
* Failing to monitor hybrid links or cross-region traffic when the architecture clearly includes them.
* Forgetting latency/loss metrics for user experience—throughput alone isn’t enough.

---

## 📚 Further Reading

* [CloudWatch metrics in AWS Transit Gateway](https://docs.aws.amazon.com/vpc/latest/tgw/transit-gateway-cloudwatch-metrics.html)
* [Monitor hybrid connectivity with Amazon CloudWatch Network Monitor](https://aws.amazon.com/blogs/networking-and-content-delivery/monitor-hybrid-connectivity-with-amazon-cloudwatch-network-monitor/)
* [Network performance metrics for EC2 instances (ENA)](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/monitoring-network-performance-ena.html)
* [Use CloudWatch Metric Streams for cross-account monitoring](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/CloudWatch-Metric-Streams.html)
* [Performance & metrics enhancements for AWS Transit Gateway and AWS Cloud WAN](https://aws.amazon.com/blogs/networking-and-content-delivery/performance-and-metrics-enhancements-for-aws-transit-gateway-and-aws-cloud-wan/)

---

### 🐿️ Bit’s Final Nut

Metrics are like the heartbeat and vitals of your network. If you pick the *right ones*, you’ll **see problems before users do**, **understand what’s happening**, and **answer the exam scenario with confidence**. Keep your metrics sharp, your dashboards ready, and your network healthy. Stay metric-wise and stay clever! 🌰
