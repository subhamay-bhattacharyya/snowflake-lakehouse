# AWS Terraform Configuration for Snowflake Lakehouse

This directory contains Terraform configuration for provisioning AWS infrastructure and Snowflake resources.

## Quick Start

### 1. Configure Codespaces Secrets

Go to: **Settings → Secrets and variables → Codespaces**

Add these 7 secrets (GitHub will convert names to UPPERCASE - this is normal):

| Secret Name | Description | Example |
|-------------|-------------|---------|
| `TF_VAR_snowflake_account` | Snowflake account identifier | `AGXUOKJ-JKC15404` |
| `TF_VAR_snowflake_user` | Snowflake username | `GH_ACTIONS_USER` |
| `TF_VAR_snowflake_private_key` | Private key (full PEM content) | `-----BEGIN PRIVATE KEY-----\n...` |
| `TF_VAR_snowflake_role` | Snowflake role | `SYSADMIN` |
| `AWS_ACCESS_KEY_ID` | AWS access key | `AKIAIOSFODNN7EXAMPLE` |
| `AWS_SECRET_ACCESS_KEY` | AWS secret key | `wJalrXUtnFEMI/...` |
| `AWS_DEFAULT_REGION` | AWS region | `us-east-1` |

**Note:** You can reuse values from your GitHub Actions secrets:
- `SNOWFLAKE_ACCOUNT` → `TF_VAR_snowflake_account`
- `SNOWFLAKE_USER` → `TF_VAR_snowflake_user`
- `SNOWFLAKE_PRIVATE_KEY` → `TF_VAR_snowflake_private_key`

### 2. Restart Codespace

Secrets are only loaded when a Codespace starts. After adding secrets:
1. Stop your Codespace
2. Start it again (or create a new one)

### 3. Verify Setup

```bash
cd infra/aws/tf

# Run verification script
./verify-setup.sh

# Should show all secrets loaded
```

### 4. Run Terraform

```bash
# Initialize Terraform
terraform init

# Preview changes
terraform plan

# Apply changes
terraform apply
```

## What Gets Created

### Snowflake Resources
- **4 Warehouses**: LOAD_WH, TRANSFORM_WH, STREAMLIT_WH, ADHOC_WH
  - Size: X-SMALL
  - Auto-suspend: 60 seconds
  - Auto-resume: Enabled

### AWS Resources
- **S3 Bucket**: For lakehouse data storage
- **IAM Role**: For Snowflake to access S3

## Configuration Files

### Input Files
- `input-jsons/warehouses.json` - Warehouse configurations
- `terraform.tfvars` - Variable values (optional, use secrets instead)

### Main Configuration
- `backend.tf` - Terraform backend and provider versions
- `providers.tf` - AWS and Snowflake provider configuration
- `variables.tf` - Variable declarations
- `main.tf` - Module calls
- `outputs.tf` - Output definitions
- `locals.tf` - Local values and JSON loading

### Modules
- `modules/s3/` - S3 bucket module
- `modules/iam/` - IAM role module
- `modules/snowflake/` - Snowflake resources
  - `modules/snowflake/modules/warehouse/` - Warehouse sub-module
  - Other sub-modules (database, storage_integration, stage, pipe) - commented out for now

## How Variables Work

Terraform automatically maps environment variables with the `TF_VAR_` prefix to input variables:

```
Codespaces Secret              Terraform Variable
─────────────────              ──────────────────
TF_VAR_SNOWFLAKE_ACCOUNT   →   var.snowflake_account
TF_VAR_SNOWFLAKE_USER      →   var.snowflake_user
TF_VAR_SNOWFLAKE_PRIVATE_KEY → var.snowflake_private_key
```

**No configuration needed** - this is a built-in Terraform feature!

## Troubleshooting

### Secrets Not Loading

**Symptom:** `Error: account is empty`

**Fix:**
1. Verify secrets are set in GitHub Codespaces settings
2. Restart your Codespace
3. Run `env | grep TF_VAR` to verify secrets are loaded

### Authentication Failed

**Symptom:** `Error: authentication failed`

**Fix:**
1. Verify private key format includes header/footer:
   ```
   -----BEGIN PRIVATE KEY-----
   ...
   -----END PRIVATE KEY-----
   ```
2. Check private key matches public key in Snowflake:
   ```sql
   DESC USER GH_ACTIONS_USER;
   ```
3. Verify user has correct role:
   ```sql
   SHOW GRANTS TO USER GH_ACTIONS_USER;
   ```

### Terraform Version Error

**Symptom:** `Unsupported Terraform Core version`

**Fix:** The configuration requires Terraform >= 1.0. Check your version:
```bash
terraform version
```

### Provider Not Found

**Symptom:** `Could not retrieve the list of available versions for provider`

**Fix:**
```bash
rm -rf .terraform .terraform.lock.hcl
terraform init
```

## Verification Commands

```bash
# Check secrets are loaded
env | grep TF_VAR

# Verify Terraform configuration
terraform validate

# Preview changes without applying
terraform plan

# Show current state
terraform show

# List all outputs
terraform output

# Show specific output
terraform output snowflake_warehouses
```

## Next Steps

After successfully creating warehouses:

1. **Test in Snowflake:**
   ```sql
   SHOW WAREHOUSES;
   USE WAREHOUSE LOAD_WH;
   SELECT CURRENT_WAREHOUSE();
   ```

2. **Enable other modules:**
   - Uncomment database module in `modules/snowflake/main.tf`
   - Create `input-jsons/databases.json`
   - Run `terraform plan` and `terraform apply`

3. **Add more resources:**
   - Storage integrations
   - External stages
   - Snowpipes

## File Structure

```
infra/aws/tf/
├── README.md                    # This file
├── backend.tf                   # Backend and provider versions
├── providers.tf                 # Provider configurations
├── variables.tf                 # Variable declarations
├── main.tf                      # Module calls
├── outputs.tf                   # Outputs
├── locals.tf                    # Local values
├── terraform.tfvars             # Variable values (optional)
├── verify-setup.sh              # Setup verification script
├── input-jsons/
│   └── warehouses.json          # Warehouse configurations
└── modules/
    ├── s3/                      # S3 bucket module
    ├── iam/                     # IAM role module
    └── snowflake/               # Snowflake module
        ├── main.tf              # Parent module
        ├── variables.tf
        ├── outputs.tf
        └── modules/             # Sub-modules
            ├── warehouse/
            ├── database/
            ├── storage_integration/
            ├── stage/
            └── pipe/
```

## Security Best Practices

✅ **Do:**
- Use Codespaces secrets for credentials
- Use key-pair authentication (more secure than passwords)
- Rotate keys every 90 days
- Use SYSADMIN role instead of ACCOUNTADMIN when possible
- Review `terraform plan` before applying

❌ **Don't:**
- Commit credentials to git
- Share private keys via chat/email
- Use production credentials in development
- Skip the verification script

## Resources

- [Terraform Snowflake Provider](https://registry.terraform.io/providers/Snowflake-Labs/snowflake/latest/docs)
- [GitHub Codespaces Secrets](https://docs.github.com/en/codespaces/managing-your-codespaces/managing-secrets-for-your-codespaces)
- [Snowflake Key-Pair Authentication](https://docs.snowflake.com/en/user-guide/key-pair-auth)
- [Main Project README](../../../README.md)
