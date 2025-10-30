# Highly Available E‑Commerce Platform (AWS + Terraform + Jenkins + Docker)

Production-style blueprint for a 3‑tier, multi‑AZ e‑commerce backend:
- VPC (public/private), NAT, ALB, two Target Groups (blue/green)
- Two ASGs (blue/green) via Launch Templates; zero-downtime with listener switch
- ECR for container images
- RDS MySQL (multi-AZ)
- S3 bucket for assets
- IAM roles for EC2 -> ECR/S3
- Jenkins pipeline with blue/green deployment & health gating

## Quick start
1) Create an S3 bucket for Terraform state and set its name in `infra/envs/dev/backend.tf`.
2) `cd infra/envs/dev && terraform init && terraform apply -auto-approve`
3) Capture `ecr_repo_url` output, build & push:
   ```bash
   ECR_REPO_URL=$(terraform output -raw ecr_repo_url)
   aws ecr get-login-password --region ap-south-1 | docker login --username AWS --password-stdin ${ECR_REPO_URL%%/*}
   docker build -t ${ECR_REPO_URL}:latest app/product-api
   docker push ${ECR_REPO_URL}:latest
   ```
4) Configure Jenkins with AWS creds id `aws-creds`. Use `ci/jenkins/Jenkinsfile`.
5) Run pipeline with `DEPLOY_COLOR=green` first. After health passes, pipeline swaps ALB to green.

**Default region in examples:** `ap-south-1` (Mumbai). Change as needed.
