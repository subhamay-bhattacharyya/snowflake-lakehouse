# Snowflake Nested Module Structure

This module provides a comprehensive, nested structure for managing Snowflake resources using Terraform.

## Architecture

The module is organized into sub-modules for each Snowflake resource type:

```
snowflake/
├── main.tf                          # Parent module orchestration
├── variables.tf                     # Parent module inputs
├── outputs.tf                       # Parent module outputs
├── example.tfvars                   # Example usage
└── modules/                         # Sub-modules
    ├── warehouse/                   # Warehouse management
    ├── database/                    # Database & schema management
    ├── storage_integration/         # Storage integration (S3/Azure/GCP)
    ├── stage/                       # External stages
    └── pipe/                        # Snowpipe for auto-ingestion
```

## Sub-Modules

### 1. Warehouse Module
Creates and manages Snowflake warehouses with configurable size, auto-suspend, and auto-resume settings.

### 2. Database Module
Creates databases and their associated schemas in a single module for better organization.

### 3. Storage Integration Module
Manages external storage integrations (S3, Azure, GCP) for accessing data in cloud storage.

### 4. Stage Module
Creates external stages that reference storage integrations for data loading.

### 5. Pipe Module
Creates Snowpipes for continuous, automated data ingestion from stages.

## Usage

### Basic Example

```hcl
module "snowflake" {
  source = "./modules/snowflake"

  warehouses = {
    load_wh = {
      name = "LOAD_WH"
      size = "Small"
    }
  }

  databases = {
    lakehouse = {
      name = "LAKEHOUSE"
      schemas = [
        { name = "RAW" },
        { name = "STAGING" }
      ]
    }
  }

  storage_integrations = {
    s3_int = {
      name                      = "S3_INTEGRATION"
      storage_allowed_locations = ["s3://my-bucket/data/"]
      storage_aws_role_arn      = "arn:aws:iam::123456789012:role/snowflake-role"
    }
  }

  stages = {
    raw_stage = {
      name                     = "RAW_STAGE"
      database                 = "LAKEHOUSE"
      schema                   = "RAW"
      url                      = "s3://my-bucket/data/"
      storage_integration_name = "S3_INTEGRATION"
    }
  }

  pipes = {
    auto_pipe = {
      name           = "AUTO_PIPE"
      database       = "LAKEHOUSE"
      schema         = "RAW"
      copy_statement = "COPY INTO TABLE FROM @STAGE"
      auto_ingest    = true
    }
  }
}
```

## Outputs

The module outputs details for all created resources:

- `warehouses` - Map of warehouse details
- `databases` - Map of database and schema details
- `storage_integrations` - Map of storage integration details (includes IAM user ARN and external ID)
- `stages` - Map of stage details
- `pipes` - Map of pipe details (includes notification channel for SQS setup)

## Dependencies

The module handles dependencies automatically:
- Stages depend on storage integrations and databases
- Pipes depend on stages and databases

## Requirements

- Terraform >= 1.0
- Snowflake provider configured with appropriate credentials
- For S3 integration: AWS IAM role with trust relationship to Snowflake

## Notes

- Use the `storage_aws_iam_user_arn` and `storage_aws_external_id` outputs to configure your AWS IAM role trust policy
- Use the `notification_channel` output from pipes to configure S3 event notifications for auto-ingest
