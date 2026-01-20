# Codespaces Quick Start - Using Existing GitHub Actions Credentials

Since you already have GitHub Actions configured with key-pair authentication, you can reuse the same credentials for Codespaces.

## Why Separate Secrets?

GitHub Actions secrets and Codespaces secrets are stored in **different locations**:
- **Actions secrets**: Used by GitHub Actions workflows (CI/CD)
- **Codespaces secrets**: Used by development environments (your Codespace terminal)

They don't share secrets, so you need to configure both separately, but you can use the **same values**.

## Quick Setup (3 Steps)

### Step 1: Copy Your Existing Values

You already have these in GitHub Actions:
- Variable: `SNOWFLAKE_ACCOUNT`
- Variable: `SNOWFLAKE_USER`
- Secret: `SNOWFLAKE_PRIVATE_KEY`

### Step 2: Create Codespaces Secrets

Go to: **Settings → Secrets and variables → Codespaces → New repository secret**

Add these 4 secrets (copy values from your Actions secrets/variables):

| Codespaces Secret Name | Copy From Actions | Description |
|------------------------|-------------------|-------------|
| `TF_VAR_snowflake_account` | `SNOWFLAKE_ACCOUNT` variable | Your account identifier |
| `TF_VAR_snowflake_user` | `SNOWFLAKE_USER` variable | Your service account username |
| `TF_VAR_snowflake_private_key` | `SNOWFLAKE_PRIVATE_KEY` secret | Your private key (full PEM content) |
| `TF_VAR_snowflake_role` | (new) | Set to `SYSADMIN` |

**Plus AWS secrets** (if not already set):

| Codespaces Secret Name | Description |
|------------------------|-------------|
| `AWS_ACCESS_KEY_ID` | Your AWS access key |
| `AWS_SECRET_ACCESS_KEY` | Your AWS secret key |
| `AWS_DEFAULT_REGION` | Your AWS region (e.g., `us-east-1`) |

### Step 3: Use in Codespace

Once configured, open your Codespace and run:

```bash
cd infra/aws/tf
terraform init
terraform plan
terraform apply
```

That's it! The secrets are automatically available as environment variables.

## How It Works

The `TF_VAR_` prefix tells Terraform to use these environment variables as input variables.

**GitHub converts secret names to UPPERCASE automatically:**

```
You type:                    GitHub saves as:              Terraform reads as:
TF_VAR_snowflake_account  →  TF_VAR_SNOWFLAKE_ACCOUNT  →  var.snowflake_account
TF_VAR_snowflake_user     →  TF_VAR_SNOWFLAKE_USER     →  var.snowflake_user
TF_VAR_snowflake_role     →  TF_VAR_SNOWFLAKE_ROLE     →  var.snowflake_role
```

**This is normal and expected!** Terraform is case-insensitive for environment variable names.

## Verification

To verify secrets are loaded (without exposing values):

```bash
# Check if variables are set (shows only first few characters)
echo "Account: ${TF_VAR_snowflake_account:0:5}..."
echo "User: ${TF_VAR_snowflake_user}"
echo "Private Key: ${TF_VAR_snowflake_private_key:0:20}..."
echo "Role: ${TF_VAR_snowflake_role}"
```

## Private Key Format

Your `SNOWFLAKE_PRIVATE_KEY` should be in PEM format with newlines:

```
-----BEGIN PRIVATE KEY-----
MIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQC...
(multiple lines)
...
-----END PRIVATE KEY-----
```

**Important:** Include the full content with header, footer, and all newlines.

## Troubleshooting

### "My secret names are UPPERCASE - is this a problem?"

**No!** GitHub automatically converts Codespaces secret names to UPPERCASE. This is normal and expected.

Example:
- You type: `TF_VAR_snowflake_account`
- GitHub saves: `TF_VAR_SNOWFLAKE_ACCOUNT`
- Terraform reads: `var.snowflake_account` ✓

Both work identically because Terraform is case-insensitive for environment variable names.

### Issue: "Authentication failed"

**Check:**
1. Private key format is correct (includes `-----BEGIN PRIVATE KEY-----` and `-----END PRIVATE KEY-----`)
2. Private key matches the public key registered in Snowflake
3. User has the correct role grants

**Verify in Snowflake:**
```sql
DESC USER GH_ACTIONS_USER;
SHOW GRANTS TO USER GH_ACTIONS_USER;
```

### Issue: Secrets not loading

**Solution:**
1. Stop your Codespace
2. Delete the Codespace
3. Create a new Codespace (secrets will be loaded on creation)

### Issue: "Error: Invalid provider configuration"

**Check:**
1. All required secrets are set in Codespaces (not just Actions)
2. Secret names have the `TF_VAR_` prefix
3. Secret names are exactly as shown (case-sensitive)

## Comparison: Actions vs Codespaces

| Aspect | GitHub Actions | Codespaces |
|--------|----------------|------------|
| **Purpose** | CI/CD automation | Development environment |
| **Secrets Location** | Settings → Secrets → Actions | Settings → Secrets → Codespaces |
| **Variable Prefix** | None (used directly in workflow) | `TF_VAR_` (for Terraform) |
| **When Used** | Workflow runs | Terminal commands |
| **Sharing** | No (separate storage) | No (separate storage) |

## Security Notes

✅ **Best Practices:**
- Use the same service account for both Actions and Codespaces
- Use key-pair authentication (more secure than passwords)
- Rotate keys every 90 days
- Use SYSADMIN role instead of ACCOUNTADMIN when possible
- Never commit private keys to the repository

❌ **Don't:**
- Share private keys via chat or email
- Use production credentials in development
- Store keys in code or configuration files
- Grant more permissions than needed

## Next Steps

After setting up Codespaces secrets:

1. ✅ Open a Codespace
2. ✅ Run `cd infra/aws/tf`
3. ✅ Run `terraform init`
4. ✅ Run `terraform plan` to preview changes
5. ✅ Run `terraform apply` to create warehouses
6. ✅ Verify in Snowflake Web UI

## Additional Resources

- [Main Codespaces Setup Guide](./CODESPACES_SETUP.md)
- [Snowflake Setup Guide](./SNOWFLAKE_SETUP.md)
- [Terraform Snowflake Provider - Key Pair Auth](https://registry.terraform.io/providers/Snowflake-Labs/snowflake/latest/docs#key-pair-authentication)
