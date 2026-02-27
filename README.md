# Self-Healing Web Application

A production-style DevOps project that provisions, deploys, and monitors a containerized web application on AWS with automated CI/CD and self-healing capabilities.

---

## Architecture

```
                        ┌─────────────────────────────────────────┐
                        │                  AWS VPC                │
                        │          CIDR: 10.0.0.0/16              │
                        │                                         │
  Internet              │  Public Subnets      Private Subnets    │
     │                  │  10.0.1.0/24         10.0.101.0/24      │
     │                  │  10.0.2.0/24         10.0.102.0/24      │
     ▼                  │                                         │
 ┌───────┐              │  ┌──────────┐    ┌──────────────────┐   │
 │  ALB  │──────────────┼─▶│ Jenkins  │    │   App Server 1   │   │
 │ :80   │              │  │(Public)  │───▶│  (Private) :80   │   │
 └───────┘              │  └──────────┘    └──────────────────┘   │
     │                  │                                         │
     │                  │       NAT Gateway                       │
     │                  │  ┌──────────┐    ┌──────────────────┐   │
     └──────────────────┼─▶│          │    │   App Server 2   │   │
                        │  └──────────┘    │  (Private) :80   │   │
                        │                  └──────────────────┘   │
                        │                                         │
                        │  CloudWatch Alarms → SNS → Email        │
                        └─────────────────────────────────────────┘
```

---

## Tech Stack

| Layer | Tool |
|---|---|
| Infrastructure | Terraform |
| Configuration Management | Ansible |
| CI/CD | Jenkins |
| Containerization | Docker |
| Container Registry | Docker Hub |
| Cloud Provider | AWS (EC2, ALB, VPC, CloudWatch, SNS) |
| Web Server | Nginx (Alpine) |

---

## How Self-Healing Works

1. **CloudWatch** monitors CPU utilization on app servers (threshold: 80%)
2. **CloudWatch** monitors ALB unhealthy host count (threshold: > 0)
3. When an alarm triggers → **SNS** sends an email alert
4. Docker containers run with `restart_policy: always` — if a container crashes it automatically restarts
5. Jenkins pipeline can be re-triggered to redeploy a fresh container to any failed server

---

## Prerequisites

- AWS account with programmatic access (Access Key + Secret Key)
- Terraform installed (`>= 1.0`)
- Ansible installed (`>= 2.9`)
- Docker installed locally
- Docker Hub account
- Jenkins server (provisioned via this project)
- AWS Key Pair (`yourKey`) created in `eu-central-1`

---

## Project Structure

```
Self_Healing_WebApp/
├── ansible/
│   ├── inventory.json          # App server IPs
│   ├── ansible.cfg             # Ansible configuration
│   ├── playbooks/
│   │   ├── application.yml     # Deploy app to servers
│   │   └── jenkins_setup.yml   # Setup Jenkins server
│   └── roles/
│       ├── app/                # Docker + app deployment role
│       └── jenkins/            # Jenkins + Docker + Ansible role
├── docker/
│   └── app/
│       ├── Dockerfile          # Nginx Alpine image
│       └── index.html          # Web application
├── terraform/
│   ├── environments/
│   │   └── dev/
│   │       ├── main.tf         # Root module
│   │       ├── variables.tf    # Variable declarations
│   │       └── terraform.tfvars# Variable values
│   └── modules/
│       ├── vpc/                # VPC, subnets, IGW, NAT
│       ├── ec2/                # Jenkins + App instances
│       ├── alb/                # Load balancer + target group
│       ├── security-group/     # ALB, App, Jenkins SGs
│       └── monitoring/         # CloudWatch + SNS alerts
├── scripts/                    # Helper scripts
├── alert/                      # Alert configurations
├── Jenkinsfile                 # CI/CD pipeline
└── README.md
```

---

## Deployment Guide

### Step 1 — Configure Variables

Copy the example env file and fill in your values:
```bash
cp terraform/environments/dev/terraform.tfvars.example terraform/environments/dev/terraform.tfvars
```

Edit `terraform.tfvars` with your values (see `.env` section below).

### Step 2 — Provision Infrastructure with Terraform

```bash
cd terraform/environments/dev

terraform init
terraform plan
terraform apply
```

This creates:
- VPC with public/private subnets across 2 AZs
- Internet Gateway + NAT Gateway
- Jenkins EC2 instance (public subnet)
- 2x App EC2 instances (private subnets)
- Application Load Balancer
- Security Groups
- CloudWatch Alarms + SNS Topic

Note the outputs — you'll need the Jenkins public IP and app server private IPs.

### Step 3 — Configure Ansible Inventory

Update `ansible/inventory.json` with the IPs from Terraform output:

```json
{
  "all": {
    "hosts": {
      "jenkins": {
        "ansible_host": "<JENKINS_PUBLIC_IP>",
        "ansible_user": "ubuntu"
      },
      "app1": {
        "ansible_host": "<APP1_PRIVATE_IP>",
        "ansible_user": "ubuntu",
        "ansible_ssh_common_args": "-o StrictHostKeyChecking=no"
      },
      "app2": {
        "ansible_host": "<APP2_PRIVATE_IP>",
        "ansible_user": "ubuntu",
        "ansible_ssh_common_args": "-o StrictHostKeyChecking=no"
      }
    },
    "children": {
      "app": {
        "hosts": { "app1": {}, "app2": {} }
      }
    }
  }
}
```

### Step 4 — Setup Jenkins Server with Ansible

```bash
ansible-playbook -i ansible/inventory.json \
  ansible/playbooks/jenkins_setup.yml \
  --private-key=~/Downloads/yourKey.pem \
  -u ubuntu
```

This installs Jenkins, Docker, and Ansible on the Jenkins server automatically.

### Step 5 — Configure Jenkins

1. Access Jenkins at `http://<JENKINS_PUBLIC_IP>:8080`
2. Get initial admin password:
```bash
ssh -i ~/Downloads/myDevKey.pem ubuntu@<JENKINS_PUBLIC_IP>
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
```
3. Install suggested plugins + **SSH Agent** plugin
4. Add credentials:
   - **Docker Hub** → `Manage Jenkins → Credentials → Add`
     - Kind: `Username with password`
     - ID: `Dockerhub`
   - **SSH Key** → `Manage Jenkins → Credentials → Add`
     - Kind: `SSH Username with private key`
     - ID: `my-ssh-key`
     - Username: `ubuntu`
     - Private Key: paste contents of `yourKey.pem`
5. Create a Pipeline job pointing to this repository

### Step 6 — Run the Pipeline

Trigger the Jenkins pipeline. It will:
1. Checkout code from GitHub
2. Build Docker image
3. Push to Docker Hub
4. Deploy to both app servers via Ansible

### Step 7 — Verify Deployment

```bash
# Check ALB DNS from AWS Console
curl http://<ALB_DNS_NAME>

# Or check directly on app servers (from Jenkins)
ssh -i myDevKey.pem ubuntu@<APP_PRIVATE_IP>
sudo docker ps
sudo docker logs nexusapp
```

---

## CI/CD Pipeline

```
GitHub Push
    │
    ▼
┌─────────────┐
│  Checkout   │  Clone repo from GitHub
└──────┬──────┘
       │
       ▼
┌─────────────┐
│    Build    │  docker build nginx:alpine image
└──────┬──────┘
       │
       ▼
┌─────────────┐
│    Push     │  Push to Docker Hub
└──────┬──────┘
       │
       ▼
┌─────────────┐
│   Deploy    │  Ansible pulls image + runs container
│  (app1+2)   │  on both app servers via sshagent
└─────────────┘
```

---

## Monitoring & Alerts

CloudWatch alarms are configured for:

| Alarm | Metric | Threshold |
|---|---|---|
| CPU High | EC2 CPUUtilization | > 80% for 2 minutes |
| Unhealthy Hosts | ALB UnHealthyHostCount | > 0 for 1 minute |

Alerts are sent via SNS to the configured `alert_email`.

---

## Security Notes

- App servers have **no public IP** — only accessible via Jenkins (SSH) and ALB (HTTP)
- Jenkins is in a public subnet but SSH/UI access should be restricted to your IP in production
- Never commit `terraform.tfvars`, `.pem` key files, or `.env` to Git
- Rotate AWS credentials and SSH keys regularly

---

## Cleanup

To destroy all AWS resources:
```bash
cd terraform/environments/dev
terraform destroy
```