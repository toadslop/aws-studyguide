+++
title="Load Balancers on EKS"
date=2024-10-21

[taxonomies]
exams = ["Advanced Networking"]
topics = ["network design", "load balancing"]
[extra]
toc = true
comments = true
+++

Hey there, cloud critters! Bit the Chipmunk here, ready to scurry into the intersection of **Kubernetes and AWS networking** — one of the exam’s sneakiest acorns: the **AWS Load Balancer Controller (LBC)**! 🐾⚙️

If your exam question mentions **EKS**, **Ingress**, or **Service of type LoadBalancer**, this is your signal to think:

> “Aha — that’s the AWS Load Balancer Controller at work!”

Let’s dig into how it works and how to spot the right pattern under exam pressure. 🌰

<!--more-->

---

## 🌎 1. What the AWS Load Balancer Controller Does

The AWS Load Balancer Controller is a **Kubernetes controller** that automatically provisions and manages **AWS Elastic Load Balancers** for your cluster:

| **Kubernetes resource**         | **AWS resource created**            |
| ------------------------------- | ----------------------------------- |
| `Ingress`                       | **Application Load Balancer (ALB)** |
| `Service` (type `LoadBalancer`) | **Network Load Balancer (NLB)**     |

That’s the key idea:

* **Ingress → ALB (Layer 7 routing)**
* **Service → NLB (Layer 4 routing)**

💡 **Exam trigger:** When you see “EKS cluster must expose applications to the internet using path-based routing,” the correct answer is **AWS Load Balancer Controller (ALB Ingress)** — not manually creating a load balancer.

---

## 🧱 2. ALB for Ingress — Smart Layer 7 Routing in Kubernetes

When you define a Kubernetes **Ingress** resource, the controller automatically creates and configures an **Application Load Balancer** with:

* Listener rules that match your Ingress paths and hosts
* Target groups mapped to your **Kubernetes pods**
* Security groups and subnets assigned based on annotations

### 🧩 Example: Path-Based Routing

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: my-app
  annotations:
    alb.ingress.kubernetes.io/scheme: internet-facing
spec:
  rules:
  - host: app.example.com
    http:
      paths:
      - path: /api/*
        backend:
          service:
            name: api-service
            port:
              number: 80
      - path: /web/*
        backend:
          service:
            name: web-service
            port:
              number: 80
```

With the above configuration, the controller:

* Creates **one ALB**
* Adds **two listener rules** (`/api/*` and `/web/*`)
* Registers **pods** in each service as **targets**

💡 **Exam triggers:**

| Scenario                                               | What to choose                       |
| ------------------------------------------------------ | ------------------------------------ |
| “Path- or host-based routing for microservices in EKS” | ALB via AWS Load Balancer Controller |
| “Integrate EKS with WAF or Shield”                     | ALB (supports Layer 7 features)      |
| “Terminate HTTPS at the load balancer”                 | ALB with ACM certificate             |

---

## ⚡ 3. NLB for Services — Fast Layer 4 Access

When you define a **Kubernetes Service of type LoadBalancer**, the controller creates a **Network Load Balancer (NLB)** instead of an ALB.

This pattern is ideal for:

* **gRPC, TCP, UDP**, or **custom protocols**
* **Internal or hybrid connectivity** (private IPs)
* **High-performance ingress for microservices**

### Example: Service of Type LoadBalancer

```yaml
apiVersion: v1
kind: Service
metadata:
  name: db-service
  annotations:
    service.beta.kubernetes.io/aws-load-balancer-type: "nlb"
spec:
  type: LoadBalancer
  ports:
    - port: 5432
      targetPort: 5432
      protocol: TCP
  selector:
    app: database
```

The controller provisions:

* One **NLB**
* Target group with your **EC2 worker nodes** or **pods** (depending on IP mode)
* DNS entry pointing to the NLB’s endpoint

💡 **Exam triggers:**

| Scenario                                          | Correct Choice                     |
| ------------------------------------------------- | ---------------------------------- |
| “Expose non-HTTP workloads (TCP/UDP)”             | NLB via LoadBalancer service       |
| “EKS workload must be reachable over private IPs” | Internal NLB                       |
| “Minimal latency for Layer 4 traffic”             | NLB                                |
| “Pod IPs registered directly”                     | IP target mode in NLB target group |

---

## 🧠 4. Target Registration Modes — Instance vs IP

The controller supports **two modes** for how pods are registered as targets:

| **Mode**          | **How it works**                                                                       | **When to use**                                           |
| ----------------- | -------------------------------------------------------------------------------------- | --------------------------------------------------------- |
| **Instance mode** | Registers the **EKS worker node** as the target. Traffic is forwarded from node → pod. | Default for EC2 worker nodes.                             |
| **IP mode**       | Registers **pod IPs** directly in the target group.                                    | Required for **Fargate** or fine-grained scaling per pod. |

💡 **Exam tip:**
If the question mentions **“pod IPs appear as targets”** or **“EKS on Fargate”**, the correct mode is **IP target mode**.

---

## 🕸️ 5. Networking & IAM Considerations

### 🌐 **Subnets**

* The ALB or NLB must be created in **at least two subnets** across **different AZs**.
* Use subnet annotations like:

  ```
  alb.ingress.kubernetes.io/subnets: subnet-aaa,subnet-bbb
  ```

### 🔐 **Security Groups**

* The controller attaches security groups automatically.
* You can override with annotations such as:

  ```
  alb.ingress.kubernetes.io/security-groups: sg-abc123
  ```

### 🧾 **IAM Role for Service Account (IRSA)**

* The controller needs AWS permissions (ELBv2, EC2, ACM, IAM).
* You assign them via **IRSA**, not node IAM roles.

💡 **Exam trigger:**
When the question says “grant the Kubernetes controller permissions to create and tag load balancers,” the right answer involves **IRSA for AWS Load Balancer Controller**.

---

## 🧰 6. Key Integrations

| **Integration**               | **Use Case**                                  | **Load Balancer** |
| ----------------------------- | --------------------------------------------- | ----------------- |
| **AWS WAF / Shield**          | Protect EKS ingress traffic                   | ALB               |
| **ACM**                       | Manage TLS certs automatically                | ALB               |
| **CloudWatch Metrics**        | Monitor request count, latency, target health | ALB / NLB         |
| **PrivateLink**               | Private access from VPCs                      | NLB               |
| **Cross-Zone Load Balancing** | Better traffic spread across AZs              | NLB               |

---

## 🏁 7. Bit’s Exam Cheat Seeds 🌰

| **Question Trigger**                                   | **Right Answer**                     |
| ------------------------------------------------------ | ------------------------------------ |
| “Expose multiple EKS services by hostname or path”     | ALB via AWS Load Balancer Controller |
| “EKS service must support TCP/UDP”                     | NLB via LoadBalancer Service         |
| “Pods on Fargate need to receive traffic directly”     | IP target mode                       |
| “Pod IPs appear as registered targets”                 | IP mode                              |
| “Allow controller to manage AWS resources”             | IAM Role for Service Account (IRSA)  |
| “Use AWS-native load balancers for Kubernetes ingress” | AWS Load Balancer Controller         |

---

### 🐿️ Bit’s Final Thought

Kubernetes on AWS doesn’t reinvent load balancing — it **extends** AWS’s native LBs into your cluster.
So whether it’s an **ALB** smartly routing by path or an **NLB** blasting packets at wire speed, the AWS Load Balancer Controller keeps your cluster connected, secure, and exam-ready. ⚡

Crack that nut, and the next time the exam asks about “Ingress on EKS,” you’ll squeak out the right answer in seconds. 🧠💪
