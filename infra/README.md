# Infrastructure as Code

This directory contains Terraform configurations for cloud infrastructure supporting the Snowflake Lakehouse.

## Directory Structure

```
infra/
├── aws/
│   └── tf/          # AWS infrastructure (S3, IAM, etc.)
├── azure/
│   └── tf/          # Azure infrastructure (Storage, Managed Identity, etc.)
└── gcp/
    └── tf/          # GCP infrastructure (GCS, Service Accounts, etc.)
```

## Cloud Provider Resources

### AWS (`infra/aws/tf/`)
- S3 buckets for raw and processed data
- IAM roles and policies for Snowflake access
- S3 event notifications for Snowpipe (optional)

### GCP (`infra/gcp/tf/`)
- GCS buckets for raw and processed data
- Service accounts for Snowflake access
- IAM bindings for bucket access

### Azure (`infra/azure/tf/`)
- Azure Storage accounts with Data Lake Gen2
- Storage containers for raw and processed data
- Managed identities for Snowflake access

## Prerequisites

### AWS
- AWS CLI configured
- Terraform >= 1.0
- S3 bucket for Terraform state (recommended)

### GCP
- gcloud CLI configured
- Terraform >= 1.0
- GCS bucket for Terraform state (recommended)

### Azure
- Azure CLI configured
- Terraform >= 1.0
- Azure Storage for Terraform state (recommended)

## Usage

### Initialize Terraform

```bash
# AWS
cd infra/aws/tf
terraform init

# GCP
cd infra/gcp/tf
terraform init

# Azure
cd infra/azure/tf
terraform init
```

### Plan Changes

```bash
terraform plan -var-file="terraform.tfvars"
```

### Apply Changes

```bash
terraform apply -var-file="terraform.tfvars"
```

### Destroy Resources

```bash
terraform destroy -var-file="terraform.tfvars"
```

## Configuration

1. Copy the example tfvars file:
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   ```

2. Update `terraform.tfvars` with your values

3. Configure backend in `backends.tf` for remote state storage

## Environment Management

Each cloud provider supports multiple environments (dev, staging, prod):

- Use separate tfvars files: `dev.tfvars`, `staging.tfvars`, `prod.tfvars`
- Or use Terraform workspaces
- Or use separate state files with different backend keys

## Integration with Snowflake

After deploying infrastructure:

1. Note the output values (bucket names, IAM roles, etc.)
2. Use these values in Snowflake DDL scripts (in `snowflake/` directory)
3. Create storage integrations in Snowflake referencing these resources

## Best Practices

1. **State Management**: Use remote state storage (S3, GCS, Azure Storage)
2. **State Locking**: Enable state locking (DynamoDB for AWS)
3. **Secrets**: Never commit sensitive values; use environment variables or secret managers
4. **Modules**: Consider creating reusable modules for common patterns
5. **Tagging**: Apply consistent tags/labels for cost tracking and organization
