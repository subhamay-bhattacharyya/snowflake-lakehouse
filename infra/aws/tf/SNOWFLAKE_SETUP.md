# Snowflake Warehouse Setup Guide

This guide explains how to use the Snowflake warehouse module with JSON input.

## Overview

The Snowflake module reads warehouse configurations from `input-jsons/warehouses.json` and creates all warehouses defined in that file.

## Current Configuration

The following warehouses are configured in `warehouses.json`:

1. **LOAD_WH** - For loading JSON files
2. **TRANSFORM_WH** - For transformation activities
3. **STREAMLIT_WH** - For Streamlit queries
4. **ADHOC_WH** - For adhoc purposes

All warehouses are configured with:
- Size: X-SMALL
- Auto-suspend: 60 seconds
- Auto-resume: Enabled
- Query acceleration: Disabled
- Cluster count: 1 (single cluster)
- Scaling policy: STANDARD
- Initially suspended: Yes

## Prerequisites

1. **Snowflake Account**: You need a Snowflake account with appropriate permissions
2. **Terraform User**: Create a Snowflake user for Terraform with ACCOUNTADMIN role (or appropriate grants)
3. **Credentials**: Set Snowflake credentials via environment variables or tfvars
4. **GitHub Codespaces**: (Optional) For running Terraform from Codespaces

## Setup Steps

### Option A: Running from GitHub Codespaces (Recommended)

#### 1. Configure Codespaces Secrets

Navigate to: **Repository Settings → Secrets and variables → Codespaces**

Add the following secrets:

| Secret Name | Description | Example Value |
|-------------|-------------|---------------|
| `TF_VAR_snowflake_account` | Snowflake account identifier | `AGXUOKJ-JKC15404` |
| `TF_VAR_snowflake_user` | Snowflake username | `TERRAFORM_USER` |
| `TF_VAR_snowflake_password` | Snowflake password | `your-secure-password` |
| `TF_VAR_snowflake_role` | Snowflake role | `SYSADMIN` |
| `AWS_ACCESS_KEY_ID` | AWS access key | `AKIAIOSFODNN7EXAMPLE` |
| `AWS_SECRET_ACCESS_KEY` | AWS secret key | `wJalrXUtnFEMI/...` |
| `AWS_DEFAULT_REGION` | AWS region | `us-east-1` |

#### 2. Open Codespace

Click **Code → Codespaces → Create codespace on main**

#### 3. Run Terraform

```bash
# Navigate to Terraform directory
cd infra/aws/tf

# Initialize Terraform
terraform init

# Review the plan
terraform plan

# Apply changes
terraform apply
```

Secrets are automatically injected as environment variables!

### Option B: Running Locally

#### 1. Configure Snowflake Credentials

Option A: Environment Variables (Recommended)
```bash
export TF_VAR_snowflake_account="your-account-identifier"
export TF_VAR_snowflake_user="terraform_user"
export TF_VAR_snowflake_password="your-password"
export TF_VAR_snowflake_role="ACCOUNTADMIN"
```

Option B: Create `terraform.tfvars.local` (gitignored)
```hcl
snowflake_account  = "your-account-identifier"
snowflake_user     = "terraform_user"
snowflake_password = "your-password"
snowflake_role     = "ACCOUNTADMIN"
```

#### 2. Initialize Terraform

```bash
cd infra/aws/tf
terraform init
```

#### 3. Review the Plan

```bash
terraform plan
```

#### 4. Apply the Configuration

```bash
terraform apply
```

Review the changes and type `yes` to create the warehouses.

## Modifying Warehouses

To modify warehouse configurations, edit `input-jsons/warehouses.json`:

### Example: Change Warehouse Size

```json
{
  "warehouses": {
    "transform_wh": {
      "name": "TRANSFORM_WH",
      "warehouse_size": "MEDIUM",  // Changed from X-SMALL
      ...
    }
  }
}
```

### Example: Add a New Warehouse

```json
{
  "warehouses": {
    "load_wh": { ... },
    "transform_wh": { ... },
    "streamlit_wh": { ... },
    "adhoc_wh": { ... },
    "new_warehouse": {
      "name": "NEW_WH",
      "comment": "New warehouse for specific purpose",
      "warehouse_size": "SMALL",
      "auto_suspend": 120,
      "auto_resume": true,
      "enable_query_acceleration": false,
      "warehouse_type": "STANDARD",
      "min_cluster_count": 1,
      "max_cluster_count": 1,
      "scaling_policy": "STANDARD",
      "initially_suspended": true
    }
  }
}
```

After editing, run:
```bash
terraform plan
terraform apply
```

## Outputs

After applying, you can view warehouse details:

```bash
terraform output snowflake_warehouses
```

This will show:
- Warehouse names
- Warehouse IDs

## File Structure

```
infra/aws/tf/
├── main.tf                              # Calls Snowflake module
├── locals.tf                            # Loads warehouses.json
├── providers.tf                         # Snowflake provider config
├── variables.tf                         # Snowflake variables
├── outputs.tf                           # Warehouse outputs
├── input-jsons/
│   └── warehouses.json                  # Warehouse configurations
└── modules/
    └── snowflake/
        ├── main.tf                      # Parent module
        ├── variables.tf
        ├── outputs.tf
        └── modules/
            └── warehouse/               # Warehouse sub-module
                ├── main.tf
                ├── variables.tf
                └── outputs.tf
```

## Troubleshooting

### Authentication Issues

If you get authentication errors:
1. Verify your Snowflake account identifier is correct
2. Check that the user has appropriate permissions
3. Ensure the role has warehouse creation privileges

### Provider Issues

If Terraform can't find the Snowflake provider:
```bash
terraform init -upgrade
```

### JSON Syntax Errors

If you get JSON parsing errors:
1. Validate your JSON syntax using a JSON validator
2. Ensure all quotes are properly closed
3. Check for trailing commas (not allowed in JSON)

## Next Steps

After warehouses are created, you can:
1. Add database module configuration
2. Add storage integration configuration
3. Add stage and pipe configurations

All following the same JSON-based pattern.
