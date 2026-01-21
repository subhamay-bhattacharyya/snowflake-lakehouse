# Multi-Cloud Snowflake Lakehouse - Terraform Configuration

This is the **unified Terraform configuration** that orchestrates Snowflake and multi-cloud resources in the correct dependency order.

## Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│ Phase 1 & 2: Snowflake Core + Cloud Storage (Parallel)          │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  Snowflake Core (Cloud-Agnostic)    Cloud Storage (Parallel)   │
│  ┌────────────────────────┐         ┌────────────────────────┐ │
│  │ ✓ Warehouses           │         │ AWS: S3 + IAM          │ │
│  │ ✓ Databases            │         │ GCP: GCS + SA          │ │
│  │ ✓ Schemas              │         │ Azure: Blob + MI       │ │
│  └────────────────────────┘         └────────────────────────┘ │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────────┐
│ Phase 3: Snowflake Integrations (Depends on Phase 1 & 2)        │
├─────────────────────────────────────────────────────────────────┤
│ ✓ Storage Integrations (AWS, GCP, Azure)                       │
│ ✓ External Stages (using storage integrations)                 │
│ ✓ Snowpipes (using external stages)                            │
└─────────────────────────────────────────────────────────────────┘
```

## Key Benefits

✅ **Cloud-Agnostic Snowflake Core**: Warehouses and databases are independent of cloud providers
✅ **Parallel Cloud Provisioning**: AWS, GCP, and Azure resources created simultaneously
✅ **Proper Dependencies**: Integrations wait for both Snowflake and cloud resources
✅ **Selective Enablement**: Enable only the cloud providers you need
✅ **Clean Separation**: Each phase has its own module

## Directory Structure

```
infra/snowflake/tf/
├── main.tf                          # Root orchestration
├── variables.tf                     # Global variables
├── locals.tf                        # Local values and JSON loading
├── providers.tf                     # Provider configurations
├── backend.tf                       # Backend configuration
├── outputs.tf                       # Root outputs
├── terraform.tfvars                 # Variable values
├── README.md                        # This file
├── ARCHITECTURE.md                  # Detailed architecture
│
├── input-jsons/                     # Configuration files
│   ├── warehouses.json              # Warehouse definitions
│   ├── databases.json               # Database and schema definitions
│   ├── aws-s3.json                  # AWS S3 configuration
│   ├── gcp-gcs.json                 # GCP GCS configuration
│   ├── azure-blob.json              # Azure Blob configuration
│   └── stages.json                  # External stage definitions
│
└── modules/
    ├── snowflake-core/              # Phase 1: Core Snowflake resources
    │   ├── main.tf
    │   ├── variables.tf
    │   ├── outputs.tf
    │   └── modules/
    │       ├── warehouse/           # Warehouse sub-module
    │       └── database/            # Database sub-module
    │
    ├── cloud-storage/               # Phase 2: Cloud storage
    │   ├── aws/                     # AWS S3 + IAM
    │   ├── gcp/                     # GCP GCS + Service Account
    │   └── azure/                   # Azure Blob + Managed Identity
    │
    └── snowflake-integrations/      # Phase 3: Integrations
        ├── main.tf
        ├── variables.tf
        ├── outputs.tf
        └── modules/
            ├── storage-integration/ # Storage integration sub-module
            ├── stage/               # External stage sub-module
            └── pipe/                # Snowpipe sub-module
```

## Quick Start

### 1. Grant Required Permissions

Before running Terraform, ensure the Snowflake user has the necessary privileges:

```sql
-- Switch to ACCOUNTADMIN role (you must already have this role)
USE ROLE ACCOUNTADMIN;

-- Grant ACCOUNTADMIN role to the user
GRANT ROLE ACCOUNTADMIN TO USER GH_ACTIONS_USER;

-- Verify the grant
SHOW GRANTS TO USER GH_ACTIONS_USER;
```

**Note:** Storage integrations require ACCOUNTADMIN privileges. For production, consider creating a custom role with specific privileges instead of granting full ACCOUNTADMIN access.

### 2. Configure Codespaces Secrets

Same as before - see [../aws/tf/README.md](../aws/tf/README.md) for details.

### 3. Choose Cloud Providers

Edit `terraform.tfvars`:

```hcl
# Enable/disable cloud providers
enable_aws   = true   # AWS S3
enable_gcp   = false  # GCP GCS
enable_azure = false  # Azure Blob
```

**See detailed guide:** [CLOUD_PROVIDERS.md](./CLOUD_PROVIDERS.md)

### 4. Configure Resources

Edit JSON files in `input-jsons/`:

- `warehouses.json` - Define warehouses
- `databases.json` - Define databases and schemas
- `aws-s3.json` - AWS S3 configuration (if enable_aws = true)
- `gcp-gcs.json` - GCP GCS configuration (if enable_gcp = true)
- `azure-blob.json` - Azure Blob configuration (if enable_azure = true)
- `stages.json` - External stages

### 5. Run Terraform

```bash
cd infra/snowflake/tf

# Initialize
terraform init

# Plan (preview changes)
terraform plan

# Apply (create resources)
terraform apply
```

## Execution Order

Terraform automatically handles dependencies:

1. **First**: Creates warehouses and databases (snowflake-core module)
2. **Then**: Creates cloud storage in parallel (aws_storage, gcp_storage, azure_storage)
3. **Finally**: Creates storage integrations and stages (snowflake-integrations module)

## Example Configuration

### warehouses.json
```json
{
  "warehouses": {
    "load_wh": {
      "name": "LOAD_WH",
      "warehouse_size": "X-SMALL",
      "comment": "Warehouse for data loading"
    }
  }
}
```

### databases.json
```json
{
  "databases": {
    "lakehouse": {
      "name": "LAKEHOUSE",
      "comment": "Main lakehouse database",
      "schemas": [
        { "name": "RAW", "comment": "Raw data layer" },
        { "name": "STAGING", "comment": "Staging layer" },
        { "name": "ANALYTICS", "comment": "Analytics layer" }
      ]
    }
  }
}
```

### aws-s3.json
```json
{
  "bucket_name": "lakehouse-data",
  "versioning": true,
  "kms_key_alias": "alias/snowflake-key"
}
```

### stages.json
```json
{
  "stages": {
    "aws_raw_stage": {
      "name": "AWS_RAW_STAGE",
      "database": "LAKEHOUSE",
      "schema": "RAW",
      "cloud_provider": "aws",
      "storage_integration": "AWS_INTEGRATION",
      "url": "s3://lakehouse-data/raw/"
    }
  }
}
```

## Migration from Old Structure

If you're migrating from `infra/aws/tf/`:

1. **Copy your JSON files**:
   ```bash
   cp infra/aws/tf/input-jsons/warehouses.json infra/terraform/input-jsons/
   ```

2. **Create databases.json** (new file needed)

3. **Update your workflow** to use `infra/terraform/` instead of `infra/aws/tf/`

4. **Run terraform init** in the new directory

## Multi-Cloud Setup

### AWS Only (Current)
```hcl
enable_aws   = true
enable_gcp   = false
enable_azure = false
```

### AWS + GCP
```hcl
enable_aws   = true
enable_gcp   = true
enable_azure = false
```

### All Three Clouds
```hcl
enable_aws   = true
enable_gcp   = true
enable_azure = true
```

## Outputs

```bash
# View all warehouses
terraform output snowflake_warehouses

# View all databases
terraform output snowflake_databases

# View AWS resources
terraform output aws_s3_bucket
terraform output aws_iam_role

# View storage integrations
terraform output storage_integrations
```

## Benefits of This Structure

1. **Snowflake First**: Core Snowflake resources created before cloud dependencies
2. **Cloud Agnostic**: Snowflake core module doesn't know about AWS/GCP/Azure
3. **Parallel Execution**: Cloud resources created simultaneously
4. **Proper Dependencies**: Integrations wait for everything to be ready
5. **Selective Deployment**: Enable only what you need
6. **Clean Modules**: Each module has a single responsibility
7. **Easy Testing**: Test each phase independently

## Troubleshooting

Same as before - see [../aws/tf/README.md](../aws/tf/README.md#troubleshooting)

## Next Steps

1. ✅ Create `input-jsons/databases.json`
2. ✅ Copy warehouse configuration
3. ✅ Run `terraform init`
4. ✅ Run `terraform plan`
5. ✅ Run `terraform apply`
6. ✅ Enable GCP/Azure when needed
