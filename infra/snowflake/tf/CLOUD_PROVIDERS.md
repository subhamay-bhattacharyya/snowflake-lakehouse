# Cloud Provider Configuration Guide

## Overview

This Terraform configuration supports **selective multi-cloud deployment**. You can enable or disable cloud providers using simple boolean flags.

## Quick Reference

| Variable | GitHub Actions | Terraform/Codespaces | Default |
|----------|----------------|----------------------|---------|
| AWS | `ENABLE_AWS` | `enable_aws` or `TF_VAR_enable_aws` | `true` |
| GCP | `ENABLE_GCP` | `enable_gcp` or `TF_VAR_enable_gcp` | `false` |
| Azure | `ENABLE_AZURE` | `enable_azure` or `TF_VAR_enable_azure` | `false` |

## Configuration Methods

### Method 1: GitHub Actions (CI/CD)

**Location:** Settings → Secrets and variables → Actions → Variables

Add these variables:
```
ENABLE_AWS = true
ENABLE_GCP = false
ENABLE_AZURE = false
```

**How it works:**
- Workflow reads these variables
- Conditionally runs cloud-specific jobs
- Only enabled clouds are provisioned

### Method 2: Terraform Variables File

**File:** `infra/snowflake/tf/terraform.tfvars`

```hcl
# Enable/disable cloud providers
enable_aws   = true
enable_gcp   = false
enable_azure = false
```

**How it works:**
- Terraform reads from tfvars file
- Uses `count` to conditionally create resources
- Only enabled clouds are provisioned

### Method 3: Environment Variables (Codespaces)

**Codespaces Secrets:**
```
TF_VAR_enable_aws = true
TF_VAR_enable_gcp = false
TF_VAR_enable_azure = false
```

**Or in terminal:**
```bash
export TF_VAR_enable_aws=true
export TF_VAR_enable_gcp=false
export TF_VAR_enable_azure=false
```

**How it works:**
- Terraform automatically reads `TF_VAR_*` environment variables
- Maps to `var.enable_aws`, `var.enable_gcp`, `var.enable_azure`
- Only enabled clouds are provisioned

## What Gets Created

### When enable_aws = true

**AWS Resources:**
- S3 Bucket (`<project>-<name>-<env>-<region>`)
- IAM Role for Snowflake
- Bucket Policy
- KMS Key (optional)

**Snowflake Resources:**
- Storage Integration (`AWS_INTEGRATION`)
- External Stage (`AWS_RAW_STAGE`, etc.)

**Estimated Cost:** ~$0.023/GB/month

### When enable_gcp = true

**GCP Resources:**
- GCS Bucket
- Service Account
- IAM Bindings

**Snowflake Resources:**
- Storage Integration (`GCP_INTEGRATION`)
- External Stage (`GCP_RAW_STAGE`, etc.)

**Estimated Cost:** ~$0.020/GB/month

### When enable_azure = true

**Azure Resources:**
- Storage Account
- Blob Container
- Managed Identity

**Snowflake Resources:**
- Storage Integration (`AZURE_INTEGRATION`)
- External Stage (`AZURE_RAW_STAGE`, etc.)

**Estimated Cost:** ~$0.018/GB/month

## Common Scenarios

### Scenario 1: AWS Only (Default)

**Configuration:**
```hcl
enable_aws   = true
enable_gcp   = false
enable_azure = false
```

**Use Case:**
- Starting with AWS
- Single cloud deployment
- Cost optimization

**Resources Created:**
- Snowflake Core (warehouses, databases)
- AWS S3 + IAM
- AWS storage integration

### Scenario 2: AWS + GCP (Multi-Cloud)

**Configuration:**
```hcl
enable_aws   = true
enable_gcp   = true
enable_azure = false
```

**Use Case:**
- Multi-cloud data sources
- Geographic distribution
- Vendor diversification

**Resources Created:**
- Snowflake Core
- AWS S3 + IAM
- GCP GCS + Service Account
- Storage integrations for both

### Scenario 3: All Three Clouds

**Configuration:**
```hcl
enable_aws   = true
enable_gcp   = true
enable_azure = true
```

**Use Case:**
- Enterprise multi-cloud strategy
- Maximum flexibility
- Data from all three clouds

**Resources Created:**
- Snowflake Core
- AWS S3 + IAM
- GCP GCS + Service Account
- Azure Blob + Managed Identity
- Storage integrations for all three

### Scenario 4: Snowflake Only (No Cloud Storage)

**Configuration:**
```hcl
enable_aws   = false
enable_gcp   = false
enable_azure = false
```

**Use Case:**
- Testing Snowflake configuration
- Using existing cloud resources
- Manual storage setup

**Resources Created:**
- Snowflake Core only (warehouses, databases, schemas)

## Enabling a New Cloud Provider

### Step 1: Set the Enable Flag

**GitHub Actions:**
```
ENABLE_GCP = true
```

**Terraform:**
```hcl
enable_gcp = true
```

### Step 2: Add Cloud-Specific Configuration

Create/update the JSON configuration file:

**For GCP:** `input-jsons/gcp-gcs.json`
```json
{
  "bucket_name": "lakehouse-data",
  "location": "us-central1",
  "storage_class": "STANDARD"
}
```

### Step 3: Add Cloud-Specific Secrets

**GitHub Actions:**
- `GCP_WIF_PROVIDER`
- `GCP_SERVICE_ACCOUNT`

**Codespaces:**
- `TF_VAR_gcp_project`
- `GOOGLE_CREDENTIALS`

### Step 4: Run Terraform

```bash
terraform plan
terraform apply
```

Or push to GitHub to trigger the workflow.

## Disabling a Cloud Provider

### Step 1: Set the Enable Flag to False

**GitHub Actions:**
```
ENABLE_GCP = false
```

**Terraform:**
```hcl
enable_gcp = false
```

### Step 2: Run Terraform

```bash
terraform plan
# Review the plan - should show resources to be destroyed
terraform apply
```

**Warning:** This will destroy the cloud resources! Make sure data is backed up.

## Terraform Implementation

### How It Works

The enable flags use Terraform's `count` meta-argument:

```hcl
module "aws_storage" {
  source = "./modules/cloud-storage/aws"
  count  = var.enable_aws ? 1 : 0  # Creates 1 instance if true, 0 if false
  
  # ... configuration
}
```

**Result:**
- `count = 1`: Module is created
- `count = 0`: Module is skipped (not created)

### Accessing Conditional Outputs

When a module is conditional, access outputs with index:

```hcl
# Correct (with count)
storage_aws_role_arn = module.aws_storage[0].iam_role_arn

# Incorrect (without count)
storage_aws_role_arn = module.aws_storage.iam_role_arn  # Error!
```

## GitHub Actions Workflow

### Conditional Job Execution

```yaml
terraform-aws-storage:
  name: Phase 2 - AWS Storage
  needs: start-job
  if: vars.ENABLE_AWS == 'true'  # Only runs if enabled
  # ... job configuration
```

**Result:**
- Job runs if `ENABLE_AWS = true`
- Job is skipped if `ENABLE_AWS = false`

### Parallel Execution

All enabled cloud providers run in parallel:

```
Start
  ↓
Parallel:
  ├─ Snowflake Core (always)
  ├─ AWS Storage (if ENABLE_AWS = true)
  ├─ GCP Storage (if ENABLE_GCP = true)
  └─ Azure Storage (if ENABLE_AZURE = true)
  ↓
Integrations (after all complete)
```

## Best Practices

### 1. Start with One Cloud
Begin with AWS only, then add others as needed:
```hcl
enable_aws   = true
enable_gcp   = false
enable_azure = false
```

### 2. Test in Dev First
Always test cloud provider changes in dev environment before production.

### 3. Monitor Costs
Each enabled cloud provider adds cost. Monitor usage:
- AWS CloudWatch
- GCP Cloud Monitoring
- Azure Cost Management

### 4. Use Consistent Naming
Keep bucket/container names consistent across clouds:
```
AWS:   my-lakehouse-data-aws
GCP:   my-lakehouse-data-gcp
Azure: my-lakehouse-data-azure
```

### 5. Document Your Choice
Document why you enabled specific clouds in your `terraform.tfvars`:
```hcl
# Enable AWS for primary data storage
enable_aws = true

# Enable GCP for BigQuery integration
enable_gcp = true

# Disable Azure (not needed yet)
enable_azure = false
```

## Troubleshooting

### Issue: Cloud resources not created

**Cause:** Enable flag is false

**Fix:**
```hcl
enable_aws = true  # Change from false to true
```

### Issue: Workflow job skipped

**Cause:** GitHub variable not set or set to false

**Fix:**
Set `ENABLE_AWS = true` in GitHub Actions variables

### Issue: "Error: Invalid count argument"

**Cause:** Enable variable not defined

**Fix:**
Add to `terraform.tfvars`:
```hcl
enable_aws = true
```

### Issue: Resources created when they shouldn't be

**Cause:** Enable flag is true when it should be false

**Fix:**
```hcl
enable_gcp = false  # Change from true to false
terraform apply     # Will destroy GCP resources
```

## Summary

| Aspect | Configuration |
|--------|---------------|
| **Enable AWS** | `ENABLE_AWS=true` or `enable_aws=true` |
| **Enable GCP** | `ENABLE_GCP=true` or `enable_gcp=true` |
| **Enable Azure** | `ENABLE_AZURE=true` or `enable_azure=true` |
| **Default** | AWS only |
| **Location** | GitHub Variables or terraform.tfvars |
| **Effect** | Conditionally creates cloud resources |

**Key Point:** Only enabled clouds are provisioned and billed! 💰
