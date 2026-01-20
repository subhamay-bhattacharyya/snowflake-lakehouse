# Codespaces Secrets - Frequently Asked Questions

## Secret Names

### Q: Why are my secret names all UPPERCASE?

**A:** This is normal! GitHub automatically converts Codespaces secret names to UPPERCASE.

When you type:
```
TF_VAR_snowflake_account
```

GitHub saves it as:
```
TF_VAR_SNOWFLAKE_ACCOUNT
```

**This is expected behavior and will work correctly.** Terraform is case-insensitive for environment variable names, so both formats work identically.

### Q: Should I type the secret name in lowercase or uppercase?

**A:** Either works! Type it however you prefer:
- `TF_VAR_snowflake_account` (lowercase - easier to read)
- `TF_VAR_SNOWFLAKE_ACCOUNT` (uppercase - matches what GitHub shows)

Both will be saved as `TF_VAR_SNOWFLAKE_ACCOUNT` and both will work with Terraform.

### Q: Do I need to match the case exactly?

**A:** No. Terraform environment variables are case-insensitive. All of these work:
- `TF_VAR_snowflake_account`
- `TF_VAR_SNOWFLAKE_ACCOUNT`
- `TF_VAR_Snowflake_Account`

They all map to `var.snowflake_account` in Terraform.

## Secrets vs Variables

### Q: What's the difference between GitHub Actions secrets and Codespaces secrets?

**A:** They're stored in different places:

| Feature | GitHub Actions | Codespaces |
|---------|----------------|------------|
| **Location** | Settings → Secrets → Actions | Settings → Secrets → Codespaces |
| **Used by** | Workflow files (.github/workflows/) | Terminal in Codespace |
| **Purpose** | CI/CD automation | Development environment |
| **Shared?** | No - separate storage | No - separate storage |

You need to configure both separately, but you can use the same values.

### Q: Can I use GitHub Actions secrets in Codespaces?

**A:** No. They're stored separately and don't share values. You must configure Codespaces secrets separately.

### Q: Why do Codespaces secrets need the TF_VAR_ prefix?

**A:** The `TF_VAR_` prefix tells Terraform to automatically use these environment variables as input variables. Without it, Terraform won't recognize them.

## Authentication

### Q: Can I use the same private key for both Actions and Codespaces?

**A:** Yes! Use the exact same private key value in both:
- Actions secret: `SNOWFLAKE_PRIVATE_KEY`
- Codespaces secret: `TF_VAR_snowflake_private_key`

### Q: What format should the private key be in?

**A:** PEM format with header, footer, and newlines:

```
-----BEGIN PRIVATE KEY-----
MIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQC...
(multiple lines)
...
-----END PRIVATE KEY-----
```

Include everything from `-----BEGIN` to `-----END`.

### Q: Can I use password authentication instead of key-pair?

**A:** Yes, but key-pair is more secure. For password auth, use:
- `TF_VAR_snowflake_password` instead of `TF_VAR_snowflake_private_key`

The Terraform provider supports both methods.

## Setup and Configuration

### Q: Do I need to restart my Codespace after adding secrets?

**A:** Yes! Secrets are only loaded when a Codespace is created. To load new secrets:
1. Stop your Codespace
2. Delete the Codespace (optional but recommended)
3. Create a new Codespace

Or simply restart the Codespace from the GitHub UI.

### Q: How do I verify my secrets are loaded?

**A:** In your Codespace terminal, run:

```bash
# Check if variables are set (shows only first few characters)
echo "Account: ${TF_VAR_SNOWFLAKE_ACCOUNT:0:5}..."
echo "User: ${TF_VAR_SNOWFLAKE_USER}"
echo "Role: ${TF_VAR_SNOWFLAKE_ROLE}"

# Or list all TF_VAR variables (values hidden)
env | grep TF_VAR
```

### Q: Can I see the secret values in my Codespace?

**A:** Yes, in the terminal. But be careful not to expose them:

```bash
# DON'T do this in shared screens or recordings:
echo $TF_VAR_SNOWFLAKE_PRIVATE_KEY

# DO use partial display:
echo "${TF_VAR_SNOWFLAKE_PRIVATE_KEY:0:20}..."
```

## Terraform Usage

### Q: How does Terraform know to use these secrets?

**A:** Terraform automatically reads environment variables that start with `TF_VAR_` and maps them to input variables:

```
Environment Variable          →  Terraform Variable
TF_VAR_SNOWFLAKE_ACCOUNT     →  var.snowflake_account
TF_VAR_SNOWFLAKE_USER        →  var.snowflake_user
TF_VAR_SNOWFLAKE_PRIVATE_KEY →  var.snowflake_private_key
```

### Q: Do I need to create a terraform.tfvars file?

**A:** No! When using Codespaces secrets with the `TF_VAR_` prefix, Terraform automatically uses them. You don't need a `.tfvars` file.

However, you can still use `.tfvars` files if you want to override specific values.

### Q: What if I have both environment variables and tfvars?

**A:** Terraform precedence (highest to lowest):
1. Command-line flags (`-var`)
2. Environment variables (`TF_VAR_*`)
3. `terraform.tfvars` file
4. Variable defaults in `variables.tf`

Environment variables (Codespaces secrets) will override `.tfvars` files.

## Troubleshooting

### Q: I get "Error: Invalid provider configuration"

**Check:**
1. All required secrets are set in Codespaces (not just Actions)
2. Secret names have the `TF_VAR_` prefix
3. Codespace was restarted after adding secrets
4. Run `env | grep TF_VAR` to verify secrets are loaded

### Q: I get "Error: authentication failed"

**Check:**
1. Private key format is correct (includes header/footer)
2. Private key matches the public key in Snowflake
3. User exists and has correct role grants
4. Account identifier is correct

Verify in Snowflake:
```sql
DESC USER GH_ACTIONS_USER;
SHOW GRANTS TO USER GH_ACTIONS_USER;
```

### Q: My secrets aren't loading in the Codespace

**Solution:**
1. Verify secrets are set in **Codespaces** (not Actions)
2. Stop and delete your Codespace
3. Create a new Codespace
4. Secrets will be loaded on creation

### Q: Can I use repository secrets or user secrets?

**A:** Use **repository secrets** for team collaboration. User secrets are only available to you and won't work for other team members.

## Security

### Q: Are Codespaces secrets secure?

**A:** Yes! They're encrypted at rest and only exposed in your Codespace environment. However:
- ✅ Don't echo secrets in logs or terminal output
- ✅ Don't commit secrets to the repository
- ✅ Don't share Codespaces with untrusted users
- ✅ Delete Codespaces when not in use

### Q: Should I use the same credentials for dev and prod?

**A:** No! Use separate credentials:
- **Dev/Test**: Use dev Snowflake account credentials
- **Production**: Use prod credentials (only in Actions, not Codespaces)

### Q: How often should I rotate keys?

**A:** Best practice: Every 90 days. When rotating:
1. Generate new key pair
2. Update Snowflake user with new public key
3. Update both Actions and Codespaces secrets
4. Delete old key

## AWS Credentials

### Q: Why do I need AWS credentials for Snowflake?

**A:** The Terraform configuration creates AWS resources (S3 buckets, IAM roles) that Snowflake uses for storage integration.

### Q: Can I skip AWS credentials if I only want Snowflake warehouses?

**A:** Yes! If you only want to create warehouses, you can skip AWS credentials. However, the full lakehouse setup requires AWS resources.

### Q: Should I use AWS access keys or OIDC?

**A:** 
- **Codespaces**: Use access keys (OIDC not supported in Codespaces)
- **GitHub Actions**: Use OIDC (more secure, no long-lived credentials)

## Getting Help

### Q: Where can I find more documentation?

**A:**
- [CODESPACES_QUICK_START.md](./CODESPACES_QUICK_START.md) - Quick setup guide
- [CODESPACES_SETUP.md](./CODESPACES_SETUP.md) - Detailed setup
- [SECRETS_MAPPING.md](./SECRETS_MAPPING.md) - Actions vs Codespaces mapping
- [SNOWFLAKE_SETUP.md](./SNOWFLAKE_SETUP.md) - Snowflake configuration

### Q: Something's not working. What should I check?

**Checklist:**
1. ✅ All 7 secrets are set in Codespaces
2. ✅ Secret names have `TF_VAR_` prefix (case doesn't matter)
3. ✅ Private key includes header and footer
4. ✅ Codespace was restarted after adding secrets
5. ✅ Run `env | grep TF_VAR` to verify secrets are loaded
6. ✅ Run `terraform init` before `terraform plan`
7. ✅ Check Snowflake user has correct permissions

Still stuck? Check the Troubleshooting sections in the other documentation files.
