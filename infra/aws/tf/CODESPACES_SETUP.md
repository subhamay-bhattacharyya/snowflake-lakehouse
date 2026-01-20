# GitHub Codespaces Setup for Terraform

This guide explains how to configure GitHub Codespaces to run Terraform for Snowflake warehouse provisioning.

> **💡 Already have GitHub Actions configured?** See [CODESPACES_QUICK_START.md](./CODESPACES_QUICK_START.md) to reuse your existing credentials!

## Quick Setup

### Step 1: Configure Codespaces Secrets

1. Go to your GitHub repository
2. Navigate to: **Settings → Secrets and variables → Codespaces**
3. Click **New repository secret**
4. Add each secret from the table below

**Important Notes:**
- GitHub automatically converts secret names to UPPERCASE (this is normal and expected)
- Type: `TF_VAR_snowflake_account` → GitHub saves as: `TF_VAR_SNOWFLAKE_ACCOUNT`
- Terraform is case-insensitive for `TF_VAR_*` variables, so both work identically

### Step 2: Required Secrets

#### For Key-Pair Authentication (Recommended - More Secure)

If you're using the same key-pair authentication as GitHub Actions:

| Secret Name | Description | Where to Find | Example |
|-------------|-------------|---------------|---------|
| `TF_VAR_snowflake_account` | Snowflake account identifier | Snowflake UI → Account menu | `AGXUOKJ-JKC15404` |
| `TF_VAR_snowflake_user` | Snowflake username for Terraform | Same as GitHub Actions variable | `GH_ACTIONS_USER` |
| `TF_VAR_snowflake_private_key` | Private key content (PEM format) | Same content as `SNOWFLAKE_PRIVATE_KEY` in Actions | `-----BEGIN PRIVATE KEY-----\nMIIE...` |
| `TF_VAR_snowflake_role` | Snowflake role to use | Usually SYSADMIN or ACCOUNTADMIN | `SYSADMIN` |
| `AWS_ACCESS_KEY_ID` | AWS access key | AWS IAM Console | `AKIAIOSFODNN7EXAMPLE` |
| `AWS_SECRET_ACCESS_KEY` | AWS secret access key | AWS IAM Console | `wJalrXUtnFEMI/K7MDENG/...` |
| `AWS_DEFAULT_REGION` | AWS region | Your preferred region | `us-east-1` |

**Note:** You can copy the exact same values from your GitHub Actions secrets/variables:
- `SNOWFLAKE_ACCOUNT` (Actions variable) → `TF_VAR_snowflake_account` (Codespaces secret)
- `SNOWFLAKE_USER` (Actions variable) → `TF_VAR_snowflake_user` (Codespaces secret)
- `SNOWFLAKE_PRIVATE_KEY` (Actions secret) → `TF_VAR_snowflake_private_key` (Codespaces secret)

#### For Password Authentication (Alternative)

If you prefer password authentication instead:

| Secret Name | Description | Where to Find | Example |
|-------------|-------------|---------------|---------|
| `TF_VAR_snowflake_account` | Snowflake account identifier | Snowflake UI → Account menu | `AGXUOKJ-JKC15404` |
| `TF_VAR_snowflake_user` | Snowflake username for Terraform | Created in Snowflake | `TERRAFORM_USER` |
| `TF_VAR_snowflake_password` | Snowflake user password | Set when creating user | `SecureP@ssw0rd!` |
| `TF_VAR_snowflake_role` | Snowflake role to use | Usually SYSADMIN or ACCOUNTADMIN | `SYSADMIN` |
| `AWS_ACCESS_KEY_ID` | AWS access key | AWS IAM Console | `AKIAIOSFODNN7EXAMPLE` |
| `AWS_SECRET_ACCESS_KEY` | AWS secret access key | AWS IAM Console | `wJalrXUtnFEMI/K7MDENG/...` |
| `AWS_DEFAULT_REGION` | AWS region | Your preferred region | `us-east-1` |

### Step 3: Optional Variables

These can be set as Codespaces variables (not secrets) if you want to customize them:

| Variable Name | Description | Default Value |
|---------------|-------------|---------------|
| `TF_VAR_environment` | Environment name | `devl` |
| `TF_VAR_project_name` | Project name prefix | `snw-lkh` |
| `TF_VAR_aws_region` | AWS region | `us-east-1` |

## How to Get Snowflake Account Identifier

1. Log into Snowflake Web UI
2. Click on your account name in the bottom left
3. Hover over your account name
4. Copy the account identifier (format: `ORGNAME-ACCOUNTNAME` or `ACCOUNT_LOCATOR`)

Example formats:
- Modern: `AGXUOKJ-JKC15404`
- Legacy: `xy12345.us-east-1`

## How to Create AWS Access Keys

1. Log into AWS Console
2. Go to **IAM → Users → Your User**
3. Click **Security credentials** tab
4. Click **Create access key**
5. Choose **Command Line Interface (CLI)**
6. Copy both the Access Key ID and Secret Access Key

**Important:** Save the secret access key immediately - you won't be able to see it again!

## Using Terraform in Codespaces

Once secrets are configured:

### 1. Open Codespace

```bash
# From GitHub UI: Code → Codespaces → Create codespace on main
# Or use GitHub CLI:
gh codespace create
```

### 2. Navigate to Terraform Directory

```bash
cd infra/aws/tf
```

### 3. Verify Secrets are Available

```bash
# Check if Snowflake secrets are set (values will be hidden)
echo "Snowflake Account: ${TF_VAR_snowflake_account:0:5}..."
echo "Snowflake User: ${TF_VAR_snowflake_user}"
echo "AWS Region: ${AWS_DEFAULT_REGION}"
```

### 4. Initialize Terraform

```bash
terraform init
```

Expected output:
```
Initializing modules...
Initializing the backend...
Initializing provider plugins...
- Finding snowflake-labs/snowflake versions matching "~> 0.94"...
- Finding hashicorp/aws versions matching ">= 1.12.0"...
```

### 5. Validate Configuration

```bash
terraform validate
```

### 6. Plan Changes

```bash
terraform plan
```

This will show you:
- 4 Snowflake warehouses to be created
- S3 bucket (if not already created)
- IAM role (if not already created)

### 7. Apply Changes

```bash
terraform apply
```

Type `yes` when prompted to create the resources.

### 8. View Outputs

```bash
terraform output
```

Or for specific output:
```bash
terraform output snowflake_warehouses
```

## Troubleshooting

### "My secret names are all UPPERCASE - is this wrong?"

**No, this is correct!** GitHub automatically converts Codespaces secret names to UPPERCASE. This is expected behavior.

```
✓ Correct: TF_VAR_SNOWFLAKE_ACCOUNT (what GitHub shows)
✓ Correct: TF_VAR_snowflake_account (what you typed)
✓ Both work identically with Terraform
```

Terraform is case-insensitive for `TF_VAR_*` environment variables, so it will correctly map:
- `TF_VAR_SNOWFLAKE_ACCOUNT` → `var.snowflake_account`
- `TF_VAR_SNOWFLAKE_USER` → `var.snowflake_user`

### Issue: "Error: Invalid provider configuration"

**Cause:** Snowflake credentials not set or incorrect

**Solution:**
1. Verify secrets are set in Codespaces settings
2. Restart your Codespace to reload secrets
3. Check secret names match exactly (case-sensitive)

### Issue: "Error: authentication failed"

**Cause:** Incorrect Snowflake credentials

**Solution:**
1. Verify account identifier format
2. Test credentials in Snowflake Web UI
3. Ensure user has appropriate role grants

### Issue: "Error: AWS credentials not found"

**Cause:** AWS secrets not configured

**Solution:**
1. Add `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` to Codespaces secrets
2. Verify IAM user has necessary permissions
3. Check access key is active in AWS Console

### Issue: Secrets not loading in Codespace

**Cause:** Codespace created before secrets were added

**Solution:**
1. Stop the Codespace
2. Delete the Codespace
3. Create a new Codespace (secrets will be loaded)

### Issue: "Error: Provider produced inconsistent result"

**Cause:** Terraform state out of sync

**Solution:**
```bash
terraform refresh
terraform plan
```

## Security Best Practices

✅ **DO:**
- Use repository secrets (not user secrets) for team collaboration
- Rotate credentials every 90 days
- Use least privilege IAM policies
- Use SYSADMIN role instead of ACCOUNTADMIN when possible
- Enable MFA on AWS and Snowflake accounts

❌ **DON'T:**
- Commit credentials to the repository
- Share secrets via chat or email
- Use production credentials in development
- Grant more permissions than needed
- Leave unused access keys active

## Next Steps

After successfully creating warehouses:

1. ✅ Verify warehouses in Snowflake Web UI
2. ✅ Test warehouse functionality
3. ✅ Uncomment database module in `modules/snowflake/main.tf`
4. ✅ Create database JSON input file
5. ✅ Run `terraform plan` and `terraform apply` again

## Additional Resources

- [Terraform Snowflake Provider Docs](https://registry.terraform.io/providers/Snowflake-Labs/snowflake/latest/docs)
- [GitHub Codespaces Docs](https://docs.github.com/en/codespaces)
- [Snowflake Account Identifiers](https://docs.snowflake.com/en/user-guide/admin-account-identifier)
- [AWS IAM Best Practices](https://docs.aws.amazon.com/IAM/latest/UserGuide/best-practices.html)
