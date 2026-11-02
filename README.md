# Automated DevOps Deployment Pipeline on AWS

An end-to-end DevOps project that automates application building, testing, containerization, infrastructure provisioning, and deployment using Docker, GitHub Actions, Terraform, and AWS.

## Project Overview

This project demonstrates how to build an automated CI/CD pipeline that deploys a containerized web application to an AWS EC2 instance.

Whenever code is pushed to the GitHub repository, GitHub Actions automatically builds and tests the application, publishes the Docker image to Docker Hub, and deploys the latest version to EC2.

The deployment process also includes application health checks and automatic rollback to the previous working version if a deployment fails.

## Architecture

```text
              Developer
                  |
                  v
             GitHub Repo
                  |
                  v
          GitHub Actions (CI)
                  |
          Build & Test Docker
                  |
                  v
              Docker Hub
                  |
           Publish Image
                  |
                  v
         GitHub Actions (CD)
                  |
             SSH Connection
                  |
                  v
             AWS EC2
                  |
            Docker Engine
                  |
                  v
          Application Container
                  |
                  v
             Web Browser
```

### Infrastructure Architecture

AWS infrastructure is provisioned using Terraform.

```text
                  AWS Cloud
                      |
                     VPC
                 10.0.0.0/16
                      |
                Public Subnet
                 10.0.1.0/24
                      |
             Internet Gateway
                      |
               Route Table
                      |
                Security Group
                      |
                 EC2 Instance
                  (Ubuntu)
                      |
                 Docker Engine
                      |
              Application Container
```

## Technologies Used

| Technology | Purpose |
|---|---|
| Linux | Server administration and environment management |
| Bash | Deployment automation and health-check scripts |
| Git | Version control |
| GitHub | Source code management |
| Docker | Application containerization |
| Docker Hub | Docker image registry |
| GitHub Actions | CI/CD automation |
| Terraform | Infrastructure as Code |
| AWS EC2 | Application hosting |
| AWS VPC | Network isolation |
| SSH | Secure remote deployment |

## Key Features

- **Automated CI/CD:** GitHub Actions automatically builds, tests, and deploys the application.
- **Docker Containerization:** Packages the application and its runtime environment into a Docker image.
- **Docker Hub Integration:** Publishes Docker images with version tags.
- **Infrastructure as Code:** Creates AWS networking and compute resources using Terraform.
- **Automated Deployment:** Deploys the application to EC2 through SSH.
- **Health Checks:** Verifies application availability after deployment.
- **Automatic Rollback:** Restores the previous working Docker image if the new deployment fails.
- **Self-hosted Runner:** Executes the deployment workflow using a self-hosted GitHub Actions runner.

## CI/CD Pipeline

The GitHub Actions workflow consists of three main stages.

### 1. Build and Test

- Checks out the source code.
- Builds the Docker image.
- Runs the application container.
- Executes the health-check script.
- Removes the test container after validation.

### 2. Publish Docker Image

- Authenticates with Docker Hub using GitHub repository secrets.
- Builds and publishes the Docker image.
- Tags the image with `latest` and the Git commit SHA.
- Publishes images when changes are pushed to the `main` branch.

### 3. Deploy to AWS EC2

- Runs on a self-hosted GitHub Actions runner.
- Establishes an SSH connection to the EC2 instance.
- Executes the deployment script on the server.
- Pulls the required Docker image.
- Starts the application container.
- Verifies application health.
- Performs automatic rollback if deployment fails.

## Terraform Infrastructure

Terraform provisions the following AWS resources:

- VPC
- Public Subnet
- Internet Gateway
- Public Route Table
- Route Table Association
- Security Group
- AWS Key Pair
- EC2 Instance

**AWS Region:** `ap-south-1` (Mumbai)

**EC2 Instance Type:** `t3.micro`

**Operating System:** Ubuntu 24.04 LTS

## Automatic Rollback Mechanism

The deployment script implements a basic rollback strategy.

1. Identifies the currently deployed Docker image.
2. Pulls the new image if it is not already available locally.
3. Stops and removes the existing application container.
4. Starts the new container.
5. Checks application health.
6. If the health check fails, removes the failed container.
7. Restarts the previous working image.
8. Verifies that the previous application is healthy.

This helps recover from failed deployments without manually restoring the previous application version.

## Project Structure

```text
devops-deployment-project/
│
├── app/
│   └── index.html
│
├── scripts/
│   ├── deploy.sh
│   ├── deploy-ec2.sh
│   └── health-check.sh
│
├── terraform/
│   ├── ec2.tf
│   ├── internet-gateway.tf
│   ├── key-pair.tf
│   ├── main.tf
│   ├── output.tf
│   ├── provider.tf
│   ├── route-assocation.tf
│   ├── route-table.tf
│   ├── security-group.tf
│   ├── subnet.tf
│   └── .terraform.lock.hcl
│
├── .github/
│   └── workflows/
│       └── deploy.yml
│
├── Dockerfile
├── .gitignore
└── README.md
```

## Prerequisites

Install the following tools before running the project:

- Git
- Docker
- Terraform
- AWS CLI
- An AWS account
- A GitHub account
- A Docker Hub account
- An SSH key pair

## Running the Project Locally

### 1. Clone the repository

```bash
git clone https://github.com/aryavsingh633/devops-deployment-project.git

cd devops-deployment-project
```

### 2. Build the Docker image

```bash
docker build -t devops-deployment-project .
```

### 3. Run the container

```bash
docker run -d \
  --name devops-app \
  -p 8080:80 \
  devops-deployment-project
```

### 4. Access the application

Open:

```text
http://localhost:8080
```

### 5. Check application health

```bash
bash scripts/health-check.sh http://localhost:8080
```

## Provisioning AWS Infrastructure with Terraform

Navigate to the Terraform directory:

```bash
cd terraform
```

Initialize Terraform:

```bash
terraform init
```

Validate the configuration:

```bash
terraform validate
```

Review the infrastructure plan:

```bash
terraform plan
```

Create the AWS infrastructure:

```bash
terraform apply
```

Confirm the changes when prompted.

To inspect the infrastructure:

```bash
terraform show
```

**Important:** Keep the Terraform state file secure. It may contain sensitive infrastructure information. Do not commit Terraform state files or AWS credentials to GitHub.

## GitHub Actions Configuration

Configure the following repository secrets under:

**GitHub Repository → Settings → Secrets and variables → Actions**

| Secret | Description |
|---|---|
| `DOCKERHUB_USERNAME` | Docker Hub username |
| `DOCKERHUB_TOKEN` | Docker Hub access token |
| `EC2_SSH_KEY` | EC2 SSH private key |
| `EC2_USER` | EC2 login username |
| `EC2_HOST` | EC2 public IP address or DNS |

Never hardcode credentials or private keys in workflow files.

## Deployment Workflow

Once the infrastructure and GitHub Actions runner are configured:

1. Push changes to the `main` branch.
2. GitHub Actions starts the workflow.
3. The application is built and tested.
4. The Docker image is pushed to Docker Hub.
5. The deployment job connects to EC2 through SSH.
6. The deployment script updates the running application.
7. Health checks verify the deployment.

## Important Notes

- Terraform manages the AWS infrastructure.
- GitHub Actions manages the automated CI/CD workflow.
- Docker packages and runs the application.
- Docker Hub stores published container images.
- The self-hosted runner must be online for jobs assigned to it.
- The EC2 deployment script is maintained separately from the local deployment script.
- If the EC2 public IP changes, update the `EC2_HOST` GitHub secret.
- AWS resources may incur charges. Stop or destroy resources when they are no longer needed.
- Preserve Terraform state securely if you intend to manage the existing infrastructure again.

## Future Improvements

Possible extensions for this project include:

- Blue-green deployment using a reverse proxy.
- Centralized logging and monitoring.
- Prometheus and Grafana integration.
- Kubernetes orchestration.
- Helm-based deployments.
- Automated infrastructure testing.


⭐ If you find this project useful, feel free to explore the repository and its implementation.