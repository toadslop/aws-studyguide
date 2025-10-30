+++
title="Identifying Logging and Monitoring Requirements"
date=2024-10-30

[taxonomies]
exams = ["Advanced Networking"]
topics = ["network design", "visibility"]
[extra]
toc = true
comments = true
+++

Hey there, network explorers! Bit the Chipmunk here — reporting live from deep within the AWS forest of logs, metrics, and alarms! 🌲

In **Domain 1.4** of the AWS Certified Advanced Networking – Specialty exam, we’re not just flipping switches to “turn on logging.” Nope! We’re designing systems that answer key *operational questions*:

* Who accessed what?
* What changed?
* Is it healthy?
* And when did that latency spike start?! 😱

<!--more-->

Let’s break this down into the major categories of **logging and monitoring requirements** — with a focus on *how to map each need to the right AWS service* and *how to think like a network specialist during the exam.*

---

## 🧭 Step 1: Identify the Core Requirement Categories

Every network design should consider **four major logging and monitoring categories**:

| Requirement Type                    | What You’re Trying to Answer                             | AWS Services to Use                                                                                            |
| ----------------------------------- | -------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------- |
| **Access & Traffic Flow**           | Who’s talking to whom? What traffic patterns exist?      | **VPC Flow Logs**, **ELB Access Logs**, **CloudFront Logs**, **Route 53 Resolver Query Logs**                  |
| **Configuration & Change Tracking** | What configuration changed? Who made it?                 | **AWS CloudTrail**, **AWS Config**, **IAM Access Analyzer**                                                    |
| **Health & Performance Monitoring** | Is the network working as expected? What’s the baseline? | **CloudWatch Metrics**, **CloudWatch Alarms**, **Transit Gateway Network Manager**, **Direct Connect Metrics** |
| **Security Visibility**             | Are we under attack? Are our defenses catching it?       | **AWS WAF Logs**, **GuardDuty**, **Route 53 Resolver DNS Firewall Logs**, **Security Hub**                     |

---

## Step 2: Match the Tool to the Requirement

### 🧩 Access & Traffic Flow

* **VPC Flow Logs**: Capture IP-level traffic data for ENIs, subnets, and VPCs.
  * Great for identifying rejected packets or troubleshooting blackholes.
* **Elastic Load Balancer Access Logs**: Log client requests, target IPs, and latencies.
* **CloudFront Access Logs**: Perfect for global edge visibility — know what’s cached and what’s not.
* **Route 53 Resolver Query Logs**: See DNS queries made inside your VPCs (crucial for hybrid environments).

> 🐿️ *Exam Tip:* In hybrid designs, ensure on-premises DNS logs and Route 53 Resolver logs are collected together to see full end-to-end query paths.

---

### ⚙️ Configuration & Change Tracking

* **AWS CloudTrail** records all API calls and console actions — critical for identifying *who changed what* in your network.
  * Example: “Who modified that route table?” CloudTrail knows.
* **AWS Config** complements this by tracking resource states and compliance over time.

> 💡 *Best Practice:* Store CloudTrail logs centrally in an **S3 bucket** within a **dedicated logging account**. Use **organization trails** for consistent visibility across accounts.

---

### 📈 Health & Performance Monitoring

Here’s where things get interesting! For the exam, “monitoring” means understanding *performance baselines* as well as *reactive alerting*.

#### Establishing the Baseline

To capture **baseline network performance**, you should monitor key **CloudWatch metrics**:

* **Transit Gateway (TGW)** and **VPC Peering**: Track **packet rejections**, **bytes in/out**, and **packet drops**.
* **Direct Connect**: Use **CloudWatch metrics** to monitor link performance — latency, errors, and throughput — and establish your hybrid network’s baseline.

#### Ongoing Health

* **CloudWatch Metrics** and **Alarms** track latency, packet loss, and error counts.
* **AWS Transit Gateway Network Manager** provides a global view of VPNs, SD-WANs, and Direct Connect attachments.
* Combine metrics with **CloudWatch Dashboards** for operational visibility.

> 🐿️ *Exam Trap:* Don’t confuse **CloudWatch Metrics (monitoring)** with **CloudWatch Logs (logging)**. Metrics = quantitative time series. Logs = detailed event data.

---

### 🔐 Security and Threat Detection

Security visibility is a distinct requirement, even for network-focused designs.

* **AWS WAF Logs**: Capture traffic rejected at the edge by WebACLs.
* **GuardDuty**: Provides continuous threat detection based on VPC Flow Logs, CloudTrail, and DNS query data.
* **Route 53 Resolver DNS Firewall Logs**: Audit blocked or allowed DNS queries across VPCs — a must for hybrid designs that integrate on-prem DNS.
* **Security Hub**: Aggregates findings from GuardDuty, WAF, and others for centralized analysis.

> 🐿️ *Pro Tip:* These security logs often tie into **SIEM pipelines** via **Kinesis Data Firehose** or **CloudWatch Log Subscriptions** for analysis in OpenSearch or Splunk.

---

## 🏗️ Step 3: Centralize and Correlate

Logging is useless if it’s scattered across accounts or regions. You need to **centralize** and **correlate** your data for effective troubleshooting and auditing.

* Use **CloudWatch Log Subscriptions** to forward logs (e.g., VPC Flow Logs, WAF Logs) to a **central logging account** via **Kinesis Data Firehose** or **S3**.
* Apply **tiered retention**: recent logs in CloudWatch Logs Insights; historical data in S3 with Athena queries.
* For hybrid networks, ensure on-prem devices (e.g., firewalls, routers) export logs to AWS via syslog or a collector in the same centralized S3 bucket.

> 🧠 *Exam Mindset:* “Where are my logs stored, who can access them, and how do I correlate them across environments?” These are *design* questions, not configuration ones.

---

## 🧠 Exam Traps and Best Practices

| Category          | Trap                                                                              | Solution                                                                 |
| ----------------- | --------------------------------------------------------------------------------- | ------------------------------------------------------------------------ |
| Logging           | Forgetting that many AWS logs (like ELB, CloudFront) are **disabled by default**. | Always enable and store in centralized S3.                               |
| Monitoring        | Confusing metrics with logs.                                                      | Metrics = “what’s happening now”; Logs = “what exactly happened.”        |
| Hybrid Visibility | Ignoring on-premises monitoring.                                                  | Use Direct Connect metrics, hybrid DNS logging, and TGW Network Manager. |
| Security          | Overlooking edge data sources like WAF or DNS Firewall.                           | Always integrate these logs into your central system.                    |

---

## 📚 Further Reading

* [Amazon CloudWatch User Guide](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/WhatIsCloudWatch.html)
* [AWS CloudTrail User Guide](https://docs.aws.amazon.com/awscloudtrail/latest/userguide/cloudtrail-user-guide.html)
* [AWS Config Documentation](https://docs.aws.amazon.com/config/latest/developerguide/WhatIsConfig.html)
* [VPC Flow Logs Guide](https://docs.aws.amazon.com/vpc/latest/userguide/flow-logs.html)
* [AWS WAF Logging and Metrics](https://docs.aws.amazon.com/waf/latest/developerguide/logging.html)
* [Route 53 Resolver Query Logging](https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/resolver-query-logs.html)

---

**In short:**
To ace Domain 1.4, think like a *designer of observability.* Your job is to ensure every layer of your network — from DNS to Direct Connect — tells a consistent story when something goes wrong.

Or as Bit the Chipmunk says:

> “You can’t troubleshoot what you can’t see — so make sure your logs and metrics paint the *whole forest*, not just one tree!” 🌲🐿️
