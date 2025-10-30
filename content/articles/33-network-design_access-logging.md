+++
title="Access Logging"
date=2024-10-30

[taxonomies]
exams = ["Advanced Networking"]
topics = ["network design", "visibility", "flow logs", "traffic mirroring"]
[extra]
toc = true
comments = true
+++

Hello, visibility voyagers! Bit here, perched in the treetops of your cloud architecture. Today we’re grabbing our binoculars and diving into **access logs**—the detailed logs you capture from AWS services so you can trace who did what, when, and how. For the AWS Advanced Networking Exam, you’ll want to know *which services produce access logs*, *what those logs capture*, and *how they fit into network design and monitoring*.

<!--more-->

Let’s buckle up and log into those logs! 🌰

---

## 🧭 1. Why Access Logging Matters

Access logs give you a fine-grained view of traffic flow, request patterns, response codes, and user/client behavior. For networking, it means:

* Auditing origin access (who reached what resource)
* Troubleshooting latency, error spikes, security events
* Proving compliance and monitoring usage across global architectures

Knowing how to design systems so that access logs are captured, stored, analyzed—and knowing what they *don’t* capture—is a must for the exam.

---

## ☁️ 2. Key AWS Services & Their Access Logs

Let’s review the major AWS services where access logs are relevant, especially for global network design.

### a) Amazon CloudFront (CDN)

**What you get:**

* Standard access logs (viewer request time, edge-location, request URI, status, cache hit/miss, bytes, referrer, user agent) delivered to S3.
* Real-time logs (optional) for near-instant request insight, delivered through **Amazon Kinesis Data Firehose** for streaming analysis and near-real-time dashboards.

**Key exam points:**
* Must enable logging (disabled by default).
* Logs delivered on a “best effort” basis—entries may be delayed or omitted.
* For global performance monitoring, ingest these logs and correlate with edge location metrics.

**Use case for exam:** You need to correlate user locations, edge latency, and content delivery failures in a multi-region setup.

---

### b) AWS Application Load Balancer (ALB) & AWS Network Load Balancer (NLB)

**What you get (ALB example):**

* Access log entries stored in S3: request timestamp, client IP:port, target IP:port, **latencies**, status codes, bytes sent/received, rule/action executed.
* Disabled by default; you enable logging and provide S3 bucket/prefix.

**Advanced latency details (important for troubleshooting):**

ALB access logs include **three latency measurements** that can help pinpoint where performance bottlenecks occur:

* `request_processing_time` — time spent by the load balancer receiving and queuing the request before sending it to the target.
* `target_processing_time` — time from when the load balancer sent the request to the target until it received the response header.
* `client_response_time` — time spent sending the response from the load balancer back to the client.

Together, these values let you determine if the delay is at the **client**, **load balancer**, or **target**—a crucial exam-level troubleshooting skill.

**NLB specificity:**

* **Network Load Balancer access logs are only available for connections using a TLS listener.** Non-TLS TCP listeners do not produce access logs.
* These logs capture connection-level metadata, such as source/destination IPs, connection times, and TLS negotiation details.

**Key exam points:**

* Access logs capture traffic at the LB node before it hits the target—useful for catching malformed requests or load balancer-level errors.
* The `actions_executed` (for ALB) or `classification_reason` fields may help detect WAF block actions or authentication issues.

**Use case for exam:** If load balancers are in play and you need to determine the cause of latency or health check failures, then access logs are key.

---

### c) Amazon S3 & Other Storage / Web Services

**What you get:**

* S3 Server Access Logs (requests to S3 buckets) and CloudTrail logs (API calls) complement access logs.
* Though not purely networking logs, they support audit/trending of object access, ingress/egress patterns.

**Key exam points:**
* For global content distribution (e.g., CloudFront origin S3), you might combine CloudFront logs + S3 server access logs for end-to-end visibility.

 **Use case for exam:** You need to prove that content delivered from CloudFront origin came from the correct S3 bucket and was updated as expected.

---

### d) Other Services with Access Logging

* API Gateway: Access logs for API requests (intra-region globally distributed).
* Elastic Load Balancing “Classic” (if still referenced in legacy scenarios) also supports access logs.
  For the exam, focus primarily on CloudFront, ALB/NLB, and where relevant, API Gateway.

---

## 📋 3. How Logging Fits into Network Design

When designing a network architecture (especially globally/hybrid), access logging plays these roles:

* **Traffic management validation:** Are requests arriving at the correct region or edge? Logs show edge location (CloudFront) or LB endpoint region.
* **Failover/troubleshooting:** If multi-region failover is configured, logs across LBs/CloudFront can identify which region got the load, whether failover occurred correctly.
* **Security/Compliance:** Logs capture client IPs, request paths, status codes (e.g., 403 blocked by WAF) so you can prove or detect unusual activity.
* **Cost & optimization:** Analyzing logs shows cache miss rates, origin requests, target traffic volumes—helping you redesign to reduce origin load or shift traffic geographically.

Exam scenarios often ask: *“Which log source would you analyze to verify that edge caching is working, or to determine which region served a request, or to audit access from a specific country?”* Being able to answer “CloudFront standard logs” or “ALB access logs” is key.

---

## ✅ 4. Best Practices & Exam Traps

### Best Practices

* Enable logging early in design—make logs part of the architecture.
* Centralize logs across accounts/regions into a dedicated encrypted S3 bucket or centralized logging account.
* Use prefixes or tags by region/service to manage millions of log files.
* Use analytics (Athena, OpenSearch) on S3 logs and create dashboards for anomaly alerts.
* Retain logs according to retention/compliance policies—archive older logs to cheaper storage.

### Exam Traps

* Logging is **disabled by default** for many services (ALB/NLB) – forgetting to enable it is a common trap.
* Access logs capture **requests** but not necessarily full transaction payloads or deep application-level context—so don’t assume they show everything.
* Be clear on **which service** produced the log: CloudFront logs differ from ALB logs and give different fields and edge context.
* Don’t confuse **real-time logs** (CloudFront real-time logs via Kinesis Data Firehose) with standard logs—they have different latencies and use cases.
* For access logs to S3: They may not capture *every* request perfectly (some may be omitted) and delivery is often eventual.

---

## 📚 Further Reading

* [Standard logging (access logs) – Amazon CloudFront](https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/AccessLogs.html)
* [Access logs for your Application Load Balancer – Elastic Load Balancing](https://docs.aws.amazon.com/elasticloadbalancing/latest/application/load-balancer-access-logs.html)
* [Analyzing Amazon Load Balancer Access Logs](https://dev.to/aws-builders/analyzing-amazon-load-balancer-access-logs-2j50)
* [Formatting AWS CloudFront and ELB Logs for Easy Review](https://spin.atomicobject.com/format-aws-cloudfront-elb-logs/)
* [Correlating CloudFront and ALB Logs for End-to-End Transaction Tracing](https://repost.aws/articles/ARwIyE18vNTbWilWNBF5LBNw/correlating-cloudfront-and-alb-logs-for-end-to-end-transaction-tracing)

---

### 🐿️ Bit’s Final Nut

Access logs are like the footprints in snow: they tell you *who* came, *where*, *when*, and *how fast*. In the global/hybrid network world of AWS, knowing how to capture them, analyze them, and tie them into design is what separates a good engineer from an exam-ready one. Keep your logs flowing, your analytics sharp, and your network trail clearly visible. Stay logged, stay clever, and keep crunching those nuts! 🌰
