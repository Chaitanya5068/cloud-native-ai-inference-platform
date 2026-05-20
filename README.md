# Distributed AI Inference Platform

A production-grade DevOps project demonstrating a distributed AI inference infrastructure on AWS with fully automated infrastructure as code using Terraform, containerized services with Docker, and internal worker communication.

## 📋 Project Overview

This project creates a complete distributed inference system where:
- **Public API Gateway** (EC2) exposes a REST API for inference requests
- **Private Worker Servers** (EC2) process requests through a multi-step pipeline
- **Internal Communication** happens securely within AWS VPC
- **Complete Automation** using Terraform, Docker, and Shell scripts

### Architecture Highlights

- **AWS VPC** with public and private subnets
- **Two EC2 Instances** (t2.micro) running Ubuntu 22.04
- **API Gateway** built with FastAPI running in Docker
- **Worker Pipeline** with Python, TypeScript, and Model services
- **Docker Compose** orchestrating worker services
- **Security Groups** implementing least privilege access
- **NAT Gateway** for private subnet internet access

---

## 🏗️ Architecture Diagram

```
┌─────────────────────────────────────┐
│        AWS VPC (10.0.0.0/16)        │
│                                     │
│  ┌─────────────────────────────┐   │
│  │  PUBLIC SUBNET (10.0.1.0/24)│   │
│  │                             │   │
│  │  ┌─────────────────────┐    │   │
│  │  │  API Server (EC2)   │    │   │
│  │  │  ├─ FastAPI        │    │   │
│  │  │  ├─ Port 80/443    │    │   │
│  │  │  └─ Public IP      │    │   │
│  │  └────────────┬────────┘    │   │
│  │               │             │   │
│  └───────────────┼─────────────┘   │
│                  │ VPC              │
│  ┌───────────────▼─────────────┐   │
│  │ PRIVATE SUBNET (10.0.2.0/24)│   │
│  │                             │   │
│  │  ┌─────────────────────┐    │   │
│  │  │ Worker Server (EC2) │    │   │
│  │  │ ├─ Python Worker    │    │   │
│  │  │ ├─ TS Worker        │    │   │
│  │  │ ├─ Model Worker     │    │   │
│  │  │ └─ No Public IP     │    │   │
│  │  └─────────────────────┘    │   │
│  │                             │   │
│  └─────────────────────────────┘   │
│                                     │
└─────────────────────────────────────┘
```

See `diagrams/architecture.txt` for detailed architecture diagram.

---

## 🚀 Quick Start

### Prerequisites

- **Local Machine:** 
  - Terraform >= 1.0
  - AWS CLI configured with credentials
  - Docker (for local testing)

- **AWS Account:** 
  - Appropriate IAM permissions (EC2, VPC, NAT Gateway)
  - Region selected (default: us-east-1)

### Step 1: Clone or Navigate to Project

```bash
cd distributed-ai-inference-platform
```

### Step 2: Configure Terraform Variables

Edit `terraform/terraform.tfvars`:

```hcl
aws_region = "us-east-1"
my_ip = "YOUR_IP/32"  # IMPORTANT: Change this for security
```

Replace `YOUR_IP` with your actual IP address (e.g., 203.0.113.1/32).

### Step 3: Initialize Terraform

```bash
cd terraform
terraform init
```

### Step 4: Review Infrastructure Plan

```bash
terraform plan
```

Review the planned resources before applying.

### Step 5: Deploy Infrastructure

```bash
terraform apply
```

Confirm with `yes` and wait for infrastructure to be created (5-10 minutes).

### Step 6: Get Outputs

```bash
terraform output
```

Save these values:
- `api_server_public_ip` - Use this for API requests
- `worker_server_private_ip` - For reference
- `api_server_ssh_command` - For SSH access

---

## 📦 Project Structure

```
distributed-ai-inference-platform/
│
├── terraform/                    # Infrastructure as Code
│   ├── main.tf                   # Entry point
│   ├── provider.tf               # AWS provider configuration
│   ├── variables.tf              # Input variables
│   ├── outputs.tf                # Output values
│   ├── vpc.tf                    # VPC and IGW
│   ├── subnet.tf                 # Subnets and route tables
│   ├── security.tf               # Security groups
│   ├── ec2.tf                    # EC2 instances
│   └── terraform.tfvars          # Configuration file
│
├── docker/                       # Container configurations
│   ├── api/                      # API Gateway service
│   │   ├── Dockerfile           # API container image
│   │   ├── app.py               # FastAPI application
│   │   └── requirements.txt      # Python dependencies
│   │
│   └── workers/                  # Worker services
│       ├── docker-compose.yml    # Orchestration
│       ├── Dockerfile.python     # Python worker image
│       ├── Dockerfile.ts         # TypeScript worker image
│       ├── Dockerfile.model      # Model worker image
│       ├── python_worker.py      # Python worker code
│       ├── ts_worker.js          # TypeScript worker code
│       ├── model_worker.py       # Model worker code
│       └── requirements.txt      # Python dependencies
│
├── scripts/                      # Deployment scripts
│   ├── install_docker.sh         # Docker installation
│   ├── deploy_api.sh             # Deploy API container
│   ├── deploy_workers.sh         # Deploy worker services
│   └── start-containers.sh       # Restart containers
│
├── diagrams/                     # Documentation
│   └── architecture.txt          # Architecture diagram
│
├── curl-examples/                # API usage examples
│   └── infer.sh                  # Example curl requests
│
├── .gitignore                    # Git ignore rules
└── README.md                     # This file
```

---

## 📡 API Endpoints

### Health Check

Check if API is running:

```bash
curl http://PUBLIC-IP/health
```

Response:
```json
{
  "status": "healthy",
  "service": "api-gateway",
  "version": "1.0.0"
}
```

### Inference Endpoint

Send an inference request:

```bash
curl -X POST http://PUBLIC-IP/infer \
  -H "Content-Type: application/json" \
  -d '{"prompt":"Hello","model":"default"}'
```

Response:
```json
{
  "response": "Hello! I'm an AI inference service. How can I help you today?",
  "status": "success",
  "model": "default"
}
```

### API Documentation

Interactive documentation available at:
- **Swagger UI:** `http://PUBLIC-IP/docs`
- **ReDoc:** `http://PUBLIC-IP/redoc`

---

## 🔄 Worker Pipeline

The request flows through three workers:

### 1. **Python Worker** (Port 8001)
- Receives request from API Gateway
- Validates input
- Adds processing metadata
- Forwards to TypeScript Worker

### 2. **TypeScript Worker** (Port 8002)
- Receives from Python Worker
- Performs intermediate processing
- Forwards to Model Worker

### 3. **Model Worker** (Port 8003)
- Final processing step
- Simulates AI model inference
- Returns mock response
- Response flows back through pipeline

---

## 🐳 Docker Deployment

### On API Server (Public Instance)

SSH into API server:
```bash
ssh -i your-key.pem ubuntu@PUBLIC-IP
```

Run Docker installation and API deployment:
```bash
bash /tmp/install_docker.sh
bash scripts/deploy_api.sh
```

Verify API:
```bash
curl http://localhost:8000/health
```

### On Worker Server (Private Instance)

SSH via bastion (API server acts as bastion):
```bash
ssh -i your-key.pem -J ubuntu@API-PUBLIC-IP ubuntu@WORKER-PRIVATE-IP
```

Run Docker installation and workers deployment:
```bash
bash /tmp/install_docker.sh
bash scripts/deploy_workers.sh
```

Verify workers:
```bash
docker-compose ps
docker-compose logs
```

---

## 📝 Example Usage

### 1. Simple Inference Request

```bash
curl -X POST http://PUBLIC-IP/infer \
  -H "Content-Type: application/json" \
  -d '{"prompt":"What is DevOps?"}'
```

### 2. Model-Specific Request

```bash
curl -X POST http://PUBLIC-IP/infer \
  -H "Content-Type: application/json" \
  -d '{"prompt":"Explain distributed systems","model":"advanced"}'
```

### 3. Batch Processing

```bash
prompts=("Hello" "How are you?" "What is AI?")
for prompt in "${prompts[@]}"; do
  curl -s -X POST http://PUBLIC-IP/infer \
    -H "Content-Type: application/json" \
    -d "{\"prompt\":\"$prompt\"}" | jq '.response'
done
```

### 4. Run Provided Examples

```bash
bash curl-examples/infer.sh PUBLIC-IP 80
```

---

## 🔐 Security Explanation

### Network Security

1. **VPC Isolation**
   - Resources contained within AWS VPC
   - Public and private subnets separate traffic

2. **Public Subnet (API Server)**
   - Connected to Internet Gateway
   - Has public IP address
   - Accessible from internet on ports 80/443
   - SSH restricted to your IP

3. **Private Subnet (Worker Servers)**
   - No direct internet access
   - No public IP address
   - Only accessible from within VPC
   - Internet access via NAT Gateway (outbound only)

4. **Security Groups**
   - API SG: Allows SSH (restricted IP), HTTP/HTTPS (any)
   - Worker SG: Allows only VPC internal traffic
   - No direct internet exposure for workers

### Application Security

1. **Input Validation**
   - FastAPI validates JSON schema
   - Pydantic models ensure type safety

2. **Error Handling**
   - Generic error messages to clients
   - Detailed logging for debugging

3. **Health Checks**
   - Monitor service availability
   - Automatic container restart on failure

### Best Practices

- Use specific IP addresses instead of 0.0.0.0/0 for SSH
- Store credentials in AWS Secrets Manager (not in code)
- Enable CloudTrail for audit logging
- Use VPC Flow Logs for network monitoring
- Enable VPC endpoint for AWS services access

---

## 📊 Terraform Configuration

### Key Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `aws_region` | us-east-1 | AWS region |
| `vpc_cidr` | 10.0.0.0/16 | VPC CIDR block |
| `public_subnet_cidr` | 10.0.1.0/24 | Public subnet |
| `private_subnet_cidr` | 10.0.2.0/24 | Private subnet |
| `instance_type` | t2.micro | EC2 instance type |
| `my_ip` | 0.0.0.0/0 | Your IP for SSH |
| `enable_nat_gateway` | true | NAT Gateway |

### Key Outputs

| Output | Description |
|--------|-------------|
| `api_server_public_ip` | Public IP of API server |
| `worker_server_private_ip` | Private IP of worker |
| `api_server_url` | Base URL for API calls |
| `api_server_ssh_command` | SSH command |

### Terraform Workflow

```bash
# Initialize Terraform
terraform init

# Plan infrastructure changes
terraform plan

# Apply changes
terraform apply

# Destroy infrastructure
terraform destroy
```

---

## 🔧 Troubleshooting

### API Server Not Responding

1. Check security group allows port 80:
```bash
aws ec2 describe-security-groups --group-ids sg-xxx
```

2. SSH into API server and check Docker:
```bash
docker ps
docker logs api-gateway
```

3. Check networking:
```bash
curl http://localhost:8000/health
```

### Workers Not Connected

1. Check worker server instance is running:
```bash
aws ec2 describe-instances --instance-ids i-xxx
```

2. SSH into worker and verify services:
```bash
docker-compose ps
docker-compose logs
```

3. Test internal connectivity:
```bash
curl http://localhost:8001/health
curl http://localhost:8002/health
curl http://localhost:8003/health
```

### Terraform Issues

1. Credentials not found:
```bash
aws configure
```

2. VPC already exists:
```bash
terraform state list
terraform state rm aws_vpc.main
```

3. Permission denied:
```bash
# Ensure IAM user has EC2, VPC permissions
aws iam get-user
```

---

## 🚀 Production Improvements

### 1. HTTPS/TLS
- Get SSL certificate from AWS Certificate Manager
- Configure HTTPS on ALB
- Use cert-manager in Kubernetes

### 2. Load Balancing
- Add Application Load Balancer (ALB)
- Distribute traffic across multiple API instances
- Enable auto-healing

### 3. Auto Scaling
- Create Auto Scaling Group for API servers
- Scale based on CPU/Memory metrics
- Configure CloudWatch alarms

### 4. Monitoring & Logging
- CloudWatch Logs for centralized logging
- Prometheus + Grafana for metrics
- Set up alerts for critical issues
- Use X-Ray for distributed tracing

### 5. Container Orchestration
- Migrate to Amazon EKS (Kubernetes)
- Use Helm for package management
- Implement rolling deployments
- Auto-scaling based on demand

### 6. Data Persistence
- RDS for relational data
- DynamoDB for NoSQL data
- ElastiCache for caching
- S3 for object storage

### 7. CI/CD Pipeline
- AWS CodePipeline for automation
- GitHub Actions for testing
- CodeBuild for building
- CodeDeploy for deployment

### 8. Secrets Management
- AWS Secrets Manager for credentials
- Parameter Store for configuration
- Automated secret rotation
- Never commit secrets to Git

### 9. Infrastructure Improvements
- Use Terraform modules for reusability
- Implement Terraform state locking
- Use remote state storage (S3)
- Enable version control for IaC

### 10. Cost Optimization
- Use Reserved Instances for production
- Implement spot instances for workers
- Set up billing alerts
- Regular cost analysis

---

## 📚 Technology Stack Details

### Infrastructure
- **AWS EC2:** Compute instances
- **AWS VPC:** Network isolation
- **AWS Security Groups:** Firewall rules
- **NAT Gateway:** Secure outbound access
- **Internet Gateway:** Public internet access

### Infrastructure as Code
- **Terraform:** Infrastructure automation
- **HCL:** Infrastructure configuration language

### Containerization
- **Docker:** Container runtime
- **Docker Compose:** Container orchestration
- **Python 3.11:** Base image for Python services
- **Node.js 20:** Base image for TypeScript services

### Application Framework
- **FastAPI:** Modern Python web framework
- **Pydantic:** Data validation
- **Express.js:** Node.js web framework
- **Uvicorn:** ASGI server

### Operating System
- **Ubuntu 22.04 LTS:** OS for EC2 instances
- **Bash:** Shell scripting

---

## 💾 Files and Directories

### Terraform Files
- `provider.tf` - AWS provider setup
- `variables.tf` - Input variables and defaults
- `vpc.tf` - VPC and Internet Gateway
- `subnet.tf` - Subnets and route tables
- `security.tf` - Security groups
- `ec2.tf` - EC2 instances
- `outputs.tf` - Output values
- `main.tf` - Documentation
- `terraform.tfvars` - Configuration values

### Docker Files
- `docker/api/Dockerfile` - API container image
- `docker/api/app.py` - FastAPI application
- `docker/api/requirements.txt` - Python dependencies
- `docker/workers/docker-compose.yml` - Worker orchestration
- `docker/workers/Dockerfile.*` - Worker container images
- `docker/workers/*_worker.*` - Worker applications

### Scripts
- `scripts/install_docker.sh` - Docker installation
- `scripts/deploy_api.sh` - API deployment
- `scripts/deploy_workers.sh` - Worker deployment
- `scripts/start-containers.sh` - Container restart

### Documentation
- `diagrams/architecture.txt` - Architecture diagram
- `curl-examples/infer.sh` - API usage examples
- `README.md` - This file

---

## 🎓 Learning Resources

### Terraform
- [Terraform AWS Provider Documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [Terraform Best Practices](https://www.terraform.io/language)

### AWS
- [AWS VPC Documentation](https://docs.aws.amazon.com/vpc/)
- [AWS EC2 Documentation](https://docs.aws.amazon.com/ec2/)
- [AWS Security Best Practices](https://aws.amazon.com/security/best-practices/)

### Docker
- [Docker Documentation](https://docs.docker.com/)
- [Docker Compose Documentation](https://docs.docker.com/compose/)

### FastAPI
- [FastAPI Documentation](https://fastapi.tiangolo.com/)
- [FastAPI Best Practices](https://fastapi.tiangolo.com/deployment/)

### DevOps
- [DevOps Best Practices](https://aws.amazon.com/devops/)
- [Infrastructure as Code](https://en.wikipedia.org/wiki/Infrastructure_as_code)

---

## 📄 License

This project is provided as-is for educational and learning purposes.

---

## 🤝 Contributing

This is a learning project. Feel free to:
- Modify for your needs
- Extend functionality
- Add new features
- Improve documentation

---

## 📞 Support

For issues or questions:

1. Check the Troubleshooting section
2. Review infrastructure logs
3. Check Docker container logs
4. Review AWS CloudWatch logs

---

## ✅ Verification Checklist

After deployment, verify:

- [ ] Terraform initialization successful (`terraform init`)
- [ ] Terraform plan shows expected resources (`terraform plan`)
- [ ] Infrastructure deployed successfully (`terraform apply`)
- [ ] Outputs displayed correctly (`terraform output`)
- [ ] API server is running and accessible
- [ ] Worker services are running
- [ ] Health checks pass
- [ ] API endpoint responds to requests
- [ ] Worker pipeline processes requests correctly

---

## 🎯 Project Goals Achieved

✅ Complete AWS VPC with public and private subnets
✅ Two EC2 instances (API and Workers)
✅ Internet Gateway and NAT Gateway
✅ Security groups with least privilege access
✅ Terraform infrastructure automation
✅ Docker containerization of services
✅ Docker Compose orchestration
✅ FastAPI REST API
✅ Multi-step worker pipeline
✅ Internal VPC communication
✅ Shell scripts for deployment
✅ Comprehensive documentation
✅ Production-ready code structure
✅ Security best practices

---

**Created with ❤️ for learning and DevOps mastery!**

Last Updated: May 2026
