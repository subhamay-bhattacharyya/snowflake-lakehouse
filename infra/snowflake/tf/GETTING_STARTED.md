# Getting Started with Multi-Cloud Snowflake Terraform

## Quick Overview

This directory (`infra/snowflake/tf/`) contains the unified Terraform configuration for managing Snowflake resources across multiple cloud providers.

## Directory Structure

```
infra/snowflake/tf/          ← You are here
├── README.md                ← Full documentation
├── ARCHITECTURE.md          ← Architecture details
├── GETTING_STARTED.md       ← This file
├── main.tf                  ← Root configuration
├── variables.tf
├── locals.tf
├── providers.tf
├── backend.tf
├── outputs.tf
├── terraform.tfvars
│
├── input-jsons/             ← Configuration files
│   ├── warehouses.json
│   ├── databases.json
│   ├── aws-s3.json
│   ├── gcp-gcs.json
│   ├── azure-blob.json
│   └── stages.json
│
└── modules/                 ← Terraform modules
    ├── snowflake-core/
    ├── cloud-storage/
    └── snowflake-integrations/
```

## What Gets Created

### Phase 1: Snowflake Core (Always)
- ✅ Warehouses (LOAD_WH, TRANSFORM_WH, STREAMLIT_WH, ADHOC_WH)
- ✅ Databases (LAKEHOUSE)
- ✅ Schemas (RAW, STAGING, ANALYTICS)

### Phase 2: Cloud Storage (Optional)
- ☁️ AWS: S3 Bucket + IAM Role (if `enable_aws = true`)
- ☁️ GCP: GCS Bucket + Service Account (if `enable_gcp = true`)
- ☁️ Azure: Blob Storage + Managed Identity (if `enable_azure = true`)

### Phase 3: Integrations (After Phase 1 & 2)
- 🔗 Storage Integrations (connects Snowflake to cloud storage)
- 📦 External Stages (data loading endpoints)
- 🚰 Snowpipes (automated data ingestion)

## Prerequisites

1. **Codespaces Secrets Configured**
   - See [../aws/tf/README.md](../../aws/tf/README.md) for setup

2. **JSON Configuration Files**
   - `warehouses.json` - Required
   - `databases.json` - Required
   - Cloud-specific JSON files - Optional (based on enabled clouds)

## Quick Start (5 Minutes)

### 1. Copy Warehouse Configuration

```bash
# If migrating from old structure
cp ../../aws/tf/input-jsons/warehouses.json input-jsons/
```

### 2. Review Database Configuration

```bash
# Check the example databases.json
cat input-jsons/databases.json
```

### 3. Choose Cloud Providers

Edit `terraform.tfvars`:

```hcl
# Enable only what you need
enable_aws   = true   # AWS S3
enable_gcp   = false  # GCP GCS (not yet)
enable_azure = false  # Azure Blob (not yet)
```

### 4. Initialize and Apply

```bash
# Initialize Terraform
terraform init

# Preview changes
terraform plan

# Create resources
terraform apply
```

## Common Scenarios

### Scenario 1: Snowflake Only (No Cloud Storage)

```hcl
# terraform.tfvars
enable_aws   = false
enable_gcp   = false
enable_azure = false
```

**Result**: Creates only warehouses and databases

### Scenario 2: Snowflake + AWS (Most Common)

```hcl
# terraform.tfvars
enable_aws   = true
enable_gcp   = false
enable_azure = false
```

**Result**: Creates Snowflake + AWS S3 + Storage Integration

### Scenario 3: Multi-Cloud

```hcl
# terraform.tfvars
enable_aws   = true
enable_gcp   = true
enable_azure = true
```

**Result**: Creates Snowflake + all cloud providers + integrations

## Configuration Files Explained

### warehouses.json
Defines Snowflake compute warehouses:
```json
{
  "warehouses": {
    "load_wh": {
      "name": "LOAD_WH",
      "warehouse_size": "X-SMALL",
      "comment": "For data loading"
    }
  }
}
```

### databases.json
Defines databases and their schemas:
```json
{
  "databases": {
    "lakehouse": {
      "name": "LAKEHOUSE",
      "schemas": [
        { "name": "RAW" },
        { "name": "STAGING" }
      ]
    }
  }
}
```

### aws-s3.json (if enable_aws = true)
Defines AWS S3 bucket configuration:
```json
{
  "bucket_name": "lakehouse-data",
  "versioning": true,
  "kms_key_alias": "alias/snowflake-key"
}
```

## Verification

### Check Snowflake Resources

```sql
-- In Snowflake
SHOW WAREHOUSES;
SHOW DATABASES;
SHOW SCHEMAS IN DATABASE LAKEHOUSE;
```

### Check Terraform Outputs

```bash
# View all outputs
terraform output

# View specific output
terraform output snowflake_warehouses
terraform output snowflake_databases
```

### Check Cloud Resources

```bash
# AWS
aws s3 ls | grep lakehouse
aws iam list-roles | grep snowflake

# GCP
gcloud storage buckets list | grep lakehouse

# Azure
az storage account list | grep lakehouse
```

## Next Steps

1. ✅ **Test warehouses** - Run queries in Snowflake
2. ✅ **Add more clouds** - Enable GCP or Azure
3. ✅ **Create stages** - Configure external stages
4. ✅ **Set up pipes** - Enable automated data ingestion
5. ✅ **Add monitoring** - Set up alerts and dashboards

## Troubleshooting

### "Module not found"
```bash
terraform init
```

### "Secrets not loaded"
1. Check Codespaces secrets are set
2. Restart Codespace
3. Run `env | grep TF_VAR`

### "databases.json not found"
```bash
# Create the file
cat > input-jsons/databases.json << 'EOF'
{
  "databases": {
    "lakehouse": {
      "name": "LAKEHOUSE",
      "schemas": [
        { "name": "RAW" }
      ]
    }
  }
}
EOF
```

## Documentation

- **README.md** - Complete documentation
- **ARCHITECTURE.md** - Detailed architecture explanation
- **GETTING_STARTED.md** - This file
- **../../MIGRATION_GUIDE.md** - Migration from old structure

## Support

For issues:
1. Check README.md troubleshooting section
2. Review ARCHITECTURE.md for design details
3. Check Terraform error messages
4. Verify JSON syntax

## Estimated Time

- **First run**: 5-10 minutes
- **Subsequent runs**: 2-3 minutes
- **Multi-cloud setup**: 10-15 minutes

## Estimated Cost

- **Snowflake**: Minimal (warehouses suspended when not in use)
- **AWS S3**: ~$0.023/GB/month
- **GCP GCS**: ~$0.020/GB/month
- **Azure Blob**: ~$0.018/GB/month

Start small, scale as needed! 🚀
