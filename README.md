# Distributed AI Inference Platform

## Overview

Distributed AI Inference Platform is a production-style DevOps project built using AWS, Terraform, Docker, FastAPI, and distributed worker services.

This project demonstrates:

* Infrastructure as Code (Terraform)
* AWS VPC Networking
* Public and Private Subnets
* Secure Worker Isolation
* Dockerized Microservices
* FastAPI API Gateway
* Distributed AI Inference Workflow
* Internal RPC Communication
* Infrastructure Automation

---

# Tech Stack

| Technology         | Purpose                |
| ------------------ | ---------------------- |
| AWS EC2            | Virtual Machines       |
| Terraform          | Infrastructure as Code |
| Docker             | Containerization       |
| FastAPI            | API Gateway            |
| Python             | Worker Services        |
| TypeScript/Node.js | Intermediate Worker    |
| Ubuntu             | Operating System       |
| VPC/Subnets        | Networking             |

---

# Architecture Diagram

```text
                    Internet
                        │
                        ▼
              ┌─────────────────┐
              │   API Gateway   │
              │ Public EC2 VM   │
              │ FastAPI + Docker│
              └────────┬────────┘
                       │
              Private Subnet RPC
                       │
                       ▼
        ┌────────────────────────────┐
        │     Worker EC2 Instance    │
        │                            │
        │  Python Worker :8001       │
        │          ↓                 │
        │  TS Worker :8002           │
        │          ↓                 │
        │  Model Worker :8003        │
        └────────────────────────────┘
```

---

# Workflow Diagram

```text
Client Request
      ↓
FastAPI API Gateway
      ↓
Python Worker
      ↓
TypeScript Worker
      ↓
Model Worker
      ↓
AI Response Generated
      ↓
JSON Response Returned
```

---

# Project Structure

```text
distributed-ai-inference-platform/
│
├── terraform/
│   ├── provider.tf
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   ├── vpc.tf
│   ├── subnet.tf
│   ├── security.tf
│   ├── ec2.tf
│   └── terraform.tfvars
│
├── docker/
│   ├── api/
│   │   ├── Dockerfile
│   │   ├── requirements.txt
│   │   └── app.py
│   │
│   └── workers/
│       ├── Dockerfile.python
│       ├── Dockerfile.ts
│       ├── Dockerfile.model
│       ├── docker-compose.yml
│       ├── requirements.txt
│       ├── python_worker.py
│       ├── ts_worker.js
│       └── model_worker.py
│
├── scripts/
│   ├── install_docker.sh
│   └── deploy.sh
│
└── README.md
```

---

# AWS Infrastructure

## Components Created

* Custom VPC
* Public Subnet
* Private Subnet
* Internet Gateway
* NAT Gateway
* Security Groups
* API EC2 Instance
* Worker EC2 Instance

---

# Security Design

## Public Access

Only API Gateway EC2 has public internet access.

## Private Access

Worker EC2 instance is isolated inside private subnet.

## Internal Communication

RPC communication occurs through private IP addresses only.

---

# Terraform Deployment Steps

## Step 1 — Clone Repository

```bash
git clone https://github.com/your-username/distributed-ai-inference-platform.git
cd distributed-ai-inference-platform/terraform
```

---

## Step 2 — Initialize Terraform

```bash
terraform init
```

---

## Step 3 — Validate Configuration

```bash
terraform validate
```

---

## Step 4 — Review Infrastructure Plan

```bash
terraform plan
```

---

## Step 5 — Deploy Infrastructure

```bash
terraform apply -auto-approve
```

---

## Step 6 — Get Outputs

```bash
terraform output
```

Example Output:

```text
api_server_public_ip = "3.xx.xx.xx"
worker_server_private_ip = "10.0.2.xx"
```

---

# SSH Access

## Connect to API EC2

```bash
ssh -i your-key.pem ubuntu@<API_PUBLIC_IP>
```

---

## Connect to Worker EC2

```bash
ssh -i your-key.pem ubuntu@<API_PRIVATE_IP>
```

Then:

```bash
ssh ubuntu@10.0.2.xx
```

---

# Worker Deployment Steps

## Step 1 — Go to Worker Directory

```bash
cd ~/distributed-ai-inference-platform/docker/workers
```

---

## Step 2 — Start Worker Containers

```bash
sudo docker compose up -d --build
```

---

## Step 3 — Verify Containers

```bash
sudo docker ps
```

Expected Services:

* python-worker
* ts-worker
* model-worker

---

## Step 4 — Verify Health

```bash
curl http://localhost:8001/health
curl http://localhost:8003/health
```

---

# API Deployment Steps

## Step 1 — Go to API Directory

```bash
cd ~/docker/api
```

---

## Step 2 — Build API Container

```bash
sudo docker build -t api-server .
```

---

## Step 3 — Start API Container

```bash
sudo docker run -d \
-p 80:8000 \
-e WORKER_SERVICE_URL=http://10.0.2.23:8001 \
--name api-server \
api-server
```

---

## Step 4 — Verify Running Container

```bash
sudo docker ps
```

---

# API Testing

## Health Check

```bash
curl http://<API_PUBLIC_IP>/health
```

---

## Inference Request

### Linux/macOS

```bash
curl -X POST http://<API_PUBLIC_IP>/infer \
-H "Content-Type: application/json" \
-d '{"prompt":"Explain DevOps"}'
```

---

### Windows PowerShell

```powershell
Invoke-RestMethod -Uri "http://<API_PUBLIC_IP>/infer" `
-Method POST `
-Headers @{"Content-Type"="application/json"} `
-Body '{"prompt":"Explain DevOps"}'
```

---

# Sample Response

```json
{
  "response": "DevOps combines software development and IT operations using automation.",
  "status": "success",
  "model": "default"
}
```

---

# Docker Commands

## View Containers

```bash
sudo docker ps
```

---

## View Logs

```bash
sudo docker logs api-server
```

---

## Stop Containers

```bash
sudo docker compose down
```

---

# Destroy Infrastructure

## Remove AWS Resources

```bash
cd terraform
terraform destroy -auto-approve
```

---

# Production Improvements

## Security Improvements

* HTTPS with Load Balancer
* IAM Roles for EC2
* AWS Secrets Manager
* WAF Protection
* Private Container Registry
* Security Monitoring

---

## Scalability Improvements

* Kubernetes Deployment
* Auto Scaling Groups
* ECS or EKS Migration
* Redis Caching
* Load Balancer Integration
* Centralized Logging

---

# Future Enhancements

* Real LLM Integration
* CI/CD Pipeline
* Monitoring with Prometheus/Grafana
* Kubernetes Migration
* Terraform Modules
* Multi-region Deployment

---

# Screenshots To Add

Add screenshots for:

* Terraform Apply Success
* AWS EC2 Dashboard
* Docker Running Containers
* API Curl Response
* Architecture Diagram
* Worker Health Checks

---

# Final Result

This project successfully demonstrates:

* Distributed AI inference architecture
* Private subnet worker isolation
* API Gateway routing
* Infrastructure automation using Terraform
* Dockerized microservices deployment
* End-to-end RPC communication
* AWS cloud networking and security

---

# Author

Chaitanya Bhosale
