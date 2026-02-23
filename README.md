# DefensePoint Cloud Security Engineer - Technical Assessment

## Overview
This repository contains the infrastructure as code (Terraform) and configuration scripts to deploy a basic security monitoring infrastructure in AWS, running Wazuh via Docker Compose.

## 1. Setup Instructions
To provision the infrastructure:

1. Ensure you have the AWS CLI configured and Terraform installed.
2. Navigate to the Terraform directory:
   ```bash
   cd terraform
   terraform init
   terraform apply -auto-approve