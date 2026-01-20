# Pre-Flight Checklist - Before Running Terraform in Codespaces

Use this checklist to ensure everything is configured before running `terraform apply`.

## ✅ Checklist

### 1. Codespaces Secrets Configuration

Go to: **Settings → Secrets and variables → Codespaces**

Verify these 7 secrets are set:

- [ ] `TF_VAR_SNOWFLAKE_ACCOUNT` (or `TF_VAR_SNOWFLAKE_ACCOUNT` - uppercase is fine)
- [ ] `TF_VAR_SNOWFLAKE_USER` (or `TF_VAR_SNOWFLAKE_USER`)
- [ ] `TF_VAR_SNOWFLAKE_PRIVATE_KEY` (or `TF_VAR_SNOWFLAKE_PRIVATE_KEY`)
- [ ] `TF_VAR_SNOWFLAKE_ROLE` (or `TF_VAR_SNOWFLAKE_ROLE`)
- [ ] `AWS_ACCESS_KEY_ID`
- [ ] `AWS_SECRET_ACCESS_KEY`
- [ ] `AWS_DEFAULT_REGION`

**Note:** GitHub converts names to uppercase automatically - this is expected!

### 2. Snowflake User Setup

Verify in Snowflake that your service account exists and has the correct permissions:

```sql
-- Check user exists and has public key configured
DESC USER GH_ACTIONS_USER;

-- Check user has SYSADMIN role
SHOW GRANTS TO USER GH_ACTIONS_USER;

-- Verify SYSADMIN has necessary privileges
SHOW GRANTS TO ROLE SYSADMIN;
```

Expected grants for SYSADMIN:
- CREATE WAREHOUSE
- USAGE on WAREHOUSE (if using existing warehouse)
- CREATE DATABASE (if creating databases later)

### 3. AWS IAM User Setup

Verify your AWS IAM user has necessary permissions:

- [ ] S3 bucket creation/management
- [ ] IAM role creation/management
- [ ] KMS key access (if using encryption)

Minimum required AWS permissions:
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:CreateBucket",
        "s3:PutBucketPolicy",
        "s3:PutBucketVersioning",
        "iam:CreateRole",
        "iam:PutRolePolicy",
        "iam:GetRole",
        "kms:DescribeKey"
      ],
      "Resource": "*"
    }
  ]
}
```

### 4. Codespace Environment

- [ ] Codespace is created (or restarted after adding secrets)
- [ ] You're in the correct directory: `infra/aws/tf`

### 5. Verify Secrets Are Loaded

Run these commands in your Codespace terminal:

```bash
# Navigate to Terraform directory
cd infra/aws/tf

# Check Snowflake secrets (partial display for security)
echo "Snowflake Account: ${TF_VAR_SNOWFLAKE_ACCOUNT:0:5}..."
echo "Snowflake User: ${TF_VAR_SNOWFLAKE_USER}"
echo "Snowflake Role: ${TF_VAR_SNOWFLAKE_ROLE}"
echo "Private Key Length: ${#TF_VAR_SNOWFLAKE_PRIVATE_KEY} characters"

# Check AWS secrets
echo "AWS Region: ${AWS_DEFAULT_REGION}"
echo "AWS Access Key: ${AWS_ACCESS_KEY_ID:0:10}..."

# List all TF_VAR variables (values hidden)
env | grep TF_VAR | cut -d'=' -f1
```

Expected output:
```
Snowflake Account: AGXUO...
Snowflake User: GH_ACTIONS_USER
Snowflake Role: SYSADMIN
Private Key Length: 1700 characters
AWS Region: us-east-1
AWS Access Key: AKIAIOSFO...
TF_VAR_SNOWFLAKE_ACCOUNT
TF_VAR_SNOWFLAKE_USER
TF_VAR_SNOWFLAKE_PRIVATE_KEY
TF_VAR_SNOWFLAKE_ROLE
```

### 6. Review Configuration Files

- [ ] Check `input-jsons/warehouses.json` has correct warehouse definitions
- [ ] Review `variables.tf` - all Snowflake variables are declared
- [ ] Review `providers.tf` - Snowflake provider is configured
- [ ] Review `main.tf` - Snowflake module is called with warehouses

### 7. Backend Configuration (Optional)

If using remote state, verify `backend.tf` is configured. Otherwise, state will be stored locally.

- [ ] Backend configured (or accepting local state)

## 🚀 Ready to Run

If all checks pass, you're ready to run Terraform!

### Step 1: Initialize Terraform

```bash
cd infra/aws/tf
terraform init
```

Expected output:
```
Initializing modules...
Initializing the backend...
Initializing provider plugins...
- Finding snowflake-labs/snowflake versions matching "~> 0.94"...
- Finding hashicorp/aws versions matching ">= 1.12.0"...
- Installing snowflake-labs/snowflake v0.94.x...
- Installing hashicorp/aws v5.x.x...

Terraform has been successfully initialized!
```

### Step 2: Validate Configuration

```bash
terraform validate
```

Expected output:
```
Success! The configuration is valid.
```

### Step 3: Plan Changes

```bash
terraform plan
```

Review the output. You should see:
- **4 warehouses** to be created (LOAD_WH, TRANSFORM_WH, STREAMLIT_WH, ADHOC_WH)
- **1 S3 bucket** to be created (if not exists)
- **1 IAM role** to be created (if not exists)

Example output:
```
Terraform will perform the following actions:

  # module.snowflake.module.warehouse["adhoc_wh"].snowflake_warehouse.this will be created
  + resource "snowflake_warehouse" "this" {
      + name           = "ADHOC_WH"
      + warehouse_size = "X-SMALL"
      ...
    }

  # module.snowflake.module.warehouse["load_wh"].snowflake_warehouse.this will be created
  ...

Plan: 6 to add, 0 to change, 0 to destroy.
```

### Step 4: Apply Changes

```bash
terraform apply
```

Type `yes` when prompted.

Expected output:
```
module.snowflake.module.warehouse["load_wh"].snowflake_warehouse.this: Creating...
module.snowflake.module.warehouse["transform_wh"].snowflake_warehouse.this: Creating...
module.snowflake.module.warehouse["streamlit_wh"].snowflake_warehouse.this: Creating...
module.snowflake.module.warehouse["adhoc_wh"].snowflake_warehouse.this: Creating...

...

Apply complete! Resources: 6 added, 0 changed, 0 destroyed.

Outputs:

snowflake_warehouses = {
  "adhoc_wh" = {
    "id" = "ADHOC_WH"
    "name" = "ADHOC_WH"
  }
  ...
}
```

### Step 5: Verify in Snowflake

Log into Snowflake Web UI and verify:

```sql
-- List all warehouses
SHOW WAREHOUSES;

-- Check specific warehouse details
DESC WAREHOUSE LOAD_WH;
DESC WAREHOUSE TRANSFORM_WH;
DESC WAREHOUSE STREAMLIT_WH;
DESC WAREHOUSE ADHOC_WH;
```

## 🔧 Troubleshooting

### Issue: "Error: Invalid provider configuration"

**Cause:** Secrets not loaded or incorrect

**Fix:**
1. Verify all 7 secrets are set in Codespaces
2. Restart your Codespace
3. Run `env | grep TF_VAR` to verify secrets are loaded

### Issue: "Error: authentication failed"

**Cause:** Snowflake credentials incorrect

**Fix:**
1. Verify private key format (includes header/footer)
2. Check private key matches public key in Snowflake
3. Verify user exists: `DESC USER GH_ACTIONS_USER;`
4. Check account identifier is correct

### Issue: "Error: Insufficient privileges"

**Cause:** Snowflake user lacks permissions

**Fix:**
```sql
-- Grant necessary privileges
USE ROLE ACCOUNTADMIN;
GRANT CREATE WAREHOUSE ON ACCOUNT TO ROLE SYSADMIN;
GRANT ROLE SYSADMIN TO USER GH_ACTIONS_USER;
```

### Issue: "Error: AWS credentials not found"

**Cause:** AWS secrets not set

**Fix:**
1. Add `AWS_ACCESS_KEY_ID` to Codespaces secrets
2. Add `AWS_SECRET_ACCESS_KEY` to Codespaces secrets
3. Add `AWS_DEFAULT_REGION` to Codespaces secrets
4. Restart Codespace

### Issue: Secrets not loading after adding them

**Cause:** Codespace needs restart

**Fix:**
1. Stop your Codespace
2. Delete the Codespace (optional but recommended)
3. Create a new Codespace
4. Secrets will be loaded on creation

## 📋 Quick Command Reference

```bash
# Navigate to Terraform directory
cd infra/aws/tf

# Verify secrets
env | grep TF_VAR

# Initialize
terraform init

# Validate
terraform validate

# Plan (preview changes)
terraform plan

# Apply (create resources)
terraform apply

# Show outputs
terraform output

# Show specific output
terraform output snowflake_warehouses

# Destroy (cleanup - use with caution!)
terraform destroy
```

## 🎯 Success Criteria

You'll know everything worked when:

✅ `terraform apply` completes without errors
✅ Output shows 4 warehouses created
✅ You can see warehouses in Snowflake Web UI
✅ You can run queries using the warehouses:
```sql
USE WAREHOUSE LOAD_WH;
SELECT CURRENT_WAREHOUSE();
```

## 📚 Related Documentation

- [CODESPACES_QUICK_START.md](./CODESPACES_QUICK_START.md) - Quick setup guide
- [VARIABLE_MAPPING_EXPLAINED.md](./VARIABLE_MAPPING_EXPLAINED.md) - How variables work
- [CODESPACES_FAQ.md](./CODESPACES_FAQ.md) - Common questions
- [SNOWFLAKE_SETUP.md](./SNOWFLAKE_SETUP.md) - Detailed Snowflake setup

## 🆘 Need Help?

If you're stuck:
1. Check the troubleshooting section above
2. Review the FAQ: [CODESPACES_FAQ.md](./CODESPACES_FAQ.md)
3. Verify each checklist item again
4. Check Terraform error messages carefully - they usually indicate what's wrong
