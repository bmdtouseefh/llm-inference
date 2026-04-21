# Terraform for vLLM and Ollama

This directory contains Terraform configurations for deploying GPU servers on AWS with either vLLM or Ollama for running LLM inference.

## Branches

- **`main` branch**: Deploys a server with vLLM
- **`ollama` branch**: Deploys a server with Ollama

## Prerequisites

- AWS CLI configured with credentials
- SSH key pair (`ollama_aws` and `ollama_aws.pub` in `~/.ssh/`)
- Terraform installed

## Usage

### vLLM (main branch)

```bash
git checkout main
terraform init
terraform apply
```

This deploys a GPU spot instance running vLLM with Qwen/Qwen3.5-9B model.

### Ollama (ollama branch)

```bash
git checkout ollama
terraform init
terraform apply
```

This deploys a GPU spot instance running Ollama Docker container with qwen3.5:27b-q4_K_M model.

## Connect after deployment

```bash
# For vLLM (port 8000)
ssh -i ~/.ssh/ollama_aws -N -L 8000:localhost:8000 ubuntu@<public_ip>

# For Ollama (port 11434)
ssh -i ~/.ssh/ollama_aws -N -L 11434:localhost:11434 ubuntu@<public_ip>
```

## Infrastructure

Both branches use the same infrastructure:
- Region: us-east-2
- Instance: g6.xlarge (GPU)
- AMI: ami-0c6b386534e3e1534
- Storage: 100GB gp3
- Pricing: Spot (one-time)