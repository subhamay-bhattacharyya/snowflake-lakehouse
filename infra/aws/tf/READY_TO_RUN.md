# Ready to Run? Quick Start Guide

## Before You Start

### 1. Verify Codespaces Secrets Are Set

Go to: **Settings → Secrets and variables → Codespaces**

You should have these 7 secrets:
- `TF_VAR_SNOWFLAKE_ACCOUNT` (will show as `TF_VAR_SNOWFLAKE_ACCOUNT` - uppercase is fine)
- `TF_VAR_SNOWFLAKE_USER`
- `TF_VAR_SNOWFLAKE_PRIVATE_KEY`
- `TF_VAR_SNOWFLAKE_ROLE`
- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`
- `AWS_DEFAULT_REGION`

### 2. Run the Verification Script

In your Codespace terminal:

```bash
cd infra/aws/tf
./verify-setup.sh
```

This will check:
- ✓ All secrets are loaded
- ✓ Configuration files exist
- ✓ Terraform is installed
- ✓ JSON syntax is valid

**If all checks pass**, you're ready to run Terraform!

**If checks fail**, see [PRE_FLIGHT_CHECKLIST.md](./PRE_FLIGHT_CHECKLIST.md) for troubleshooting.

## Running Terraform

### Step 1: Initialize

```bash
terraform init
```

Expected: Downloads Snowflake and AWS providers

### Step 2: Validate

```bash
terraform validate
```

Expected: "Success! The configuration is valid."

### Step 3: Plan

```bash
terraform plan
```

Expected: Shows 4 warehouses + S3 bucket + IAM role to be created

### Step 4: Apply

```bash
terraform apply
```

Type `yes` when prompted.

Expected: Creates all resources successfully

### Step 5: Verify

```bash
terraform output snowflake_warehouses
```

Or log into Snowflake and run:
```sql
SHOW WAREHOUSES;
```

## What Gets Created

### Snowflake Resources (4 warehouses)
1. **LOAD_WH** - For loading JSON files
2. **TRANSFORM_WH** - For transformation activities
3. **STREAMLIT_WH** - For Streamlit queries
4. **ADHOC_WH** - For adhoc purposes

All configured as:
- Size: X-SMALL
- Auto-suspend: 60 seconds
- Auto-resume: Enabled
- Initially suspended: Yes

### AWS Resources
1. **S3 Bucket** - For lakehouse data storage
2. **IAM Role** - For Snowflake to access S3

## Estimated Time

- First run: ~5-10 minutes (includes provider downloads)
- Subsequent runs: ~2-3 minutes

## Estimated Cost

- **Snowflake**: Minimal (warehouses are suspended, only charged when running queries)
- **AWS**: ~$0.023/GB/month for S3 storage (minimal for empty bucket)

## If Something Goes Wrong

1. Read the error message carefully
2. Check [PRE_FLIGHT_CHECKLIST.md](./PRE_FLIGHT_CHECKLIST.md) troubleshooting section
3. Run `./verify-setup.sh` again
4. Check [CODESPACES_FAQ.md](./CODESPACES_FAQ.md)

## After Success

Once warehouses are created:

1. ✅ Test in Snowflake:
```sql
USE WAREHOUSE LOAD_WH;
SELECT CURRENT_WAREHOUSE();
```

2. ✅ Uncomment other modules in `modules/snowflake/main.tf`:
   - Database module
   - Storage integration module
   - Stage module
   - Pipe module

3. ✅ Create JSON input files for other resources

4. ✅ Run `terraform plan` and `terraform apply` again

## Quick Reference

```bash
# Verify setup
./verify-setup.sh

# Initialize
terraform init

# Preview changes
terraform plan

# Apply changes
terraform apply

# View outputs
terraform output

# Destroy everything (careful!)
terraform destroy
```

## Documentation Index

- **[PRE_FLIGHT_CHECKLIST.md](./PRE_FLIGHT_CHECKLIST.md)** - Complete checklist before running
- **[CODESPACES_QUICK_START.md](./CODESPACES_QUICK_START.md)** - Quick setup guide
- **[VARIABLE_MAPPING_EXPLAINED.md](./VARIABLE_MAPPING_EXPLAINED.md)** - How variables work
- **[CODESPACES_FAQ.md](./CODESPACES_FAQ.md)** - Common questions
- **[SNOWFLAKE_SETUP.md](./SNOWFLAKE_SETUP.md)** - Detailed Snowflake setup

## You're Ready! 🚀

If `./verify-setup.sh` passes all checks, you can confidently run:

```bash
terraform init
terraform plan
terraform apply
```

Good luck! 🎉
