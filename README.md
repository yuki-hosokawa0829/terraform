# Terraform Azure Deployment

This repository contains Terraform projects for deploying resources on Microsoft Azure cloud platform. Each directory represents a certain project.

The infrastructure is defined as code using HashiCorp's Terraform, allowing for version control, automation, and repeatability in deploying and managing Azure resources.

## Prerequisites

Before you begin, ensure you have the following installed:

- [Terraform](https://www.terraform.io/downloads.html)
- [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)

You'll also need an Azure subscription and service principal to create resources.
For instructions on setting up your Terraform environment, refer to [the official documentation](https://learn.microsoft.com/en-us/azure/developer/terraform/get-started-windows-powershell?tabs=bash#1-configure-your-environment).

## Terraform Variables

You should create a `.tfvars` file (e.g., `terraform.tfvars`) in the root directory of each project to specify the following variables:

```hcl
subscription_id = "your_subscription_id"
client_id       = "your_client_id"
client_secret   = "your_client_secret"
tenant_id       = "your_tenant_id"
```

Replace "your_subscription_id", "your_client_id", "your_client_secret", and "your_tenant_id" with your Azure subscription ID, Service Principal ID, Service Principal Secret, and Tenant ID, respectively.

## Getting Started

1. Clone this repository:

   ```bash
   git clone https://github.com/your-username/terraform-azure-deployment.git
   ```

2. Navigate to the cloned repository:

   ```bash
   cd terraform-azure-deployment
   ```

3. Initialize Terraform:

   ```bash
   terraform init
   ```

4. Execute plan and preview the changes

   ```bash
   terraform plan -var-file=terraform.tfvars -out=main.tfplan
   ```

5. Deploy the resources:

   ```bash
   terraform apply main.tfplan
   ```

6. Confirm the deployment by typing `yes` when prompted.
