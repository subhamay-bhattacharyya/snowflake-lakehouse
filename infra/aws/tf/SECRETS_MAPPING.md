# Secrets Mapping: GitHub Actions vs Codespaces

This document shows how to map your existing GitHub Actions credentials to Codespaces.

## Why Do I Need Both?

GitHub Actions and Codespaces use **separate secret stores**:

```
┌─────────────────────────────────────────────────────────────┐
│                    GitHub Repository                         │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  ┌──────────────────────┐      ┌──────────────────────┐    │
│  │  GitHub Actions      │      │  Codespaces          │    │
│  │  (CI/CD Workflows)   │      │  (Dev Environment)   │    │
│  ├──────────────────────┤      ├──────────────────────┤    │
│  │ Secrets & Variables  │      │ Secrets & Variables  │    │
│  │ (Separate Storage)   │      │ (Separate Storage)   │    │
│  └──────────────────────┘      └──────────────────────┘    │
│           ↓                              ↓                  │
│    Used by workflows              Used by terminal         │
│    (.github/workflows/)           (terraform commands)     │
└─────────────────────────────────────────────────────────────┘
```

## Credential Mapping

### Your Current GitHub Actions Setup

**Variables** (Settings → Secrets and variables → Actions → Variables):
- `SNOWFLAKE_ACCOUNT`
- `SNOWFLAKE_USER`

**Secrets** (Settings → Secrets and variables → Actions → Secrets):
- `SNOWFLAKE_PRIVATE_KEY`

### Required Codespaces Setup

**Secrets** (Settings → Secrets and variables → Codespaces → Secrets):

| Codespaces Secret | Maps To Actions | Same Value? | Notes |
|-------------------|-----------------|-------------|-------|
| `TF_VAR_snowflake_account` | `SNOWFLAKE_ACCOUNT` | ✅ Yes | Copy exact value |
| `TF_VAR_snowflake_user` | `SNOWFLAKE_USER` | ✅ Yes | Copy exact value |
| `TF_VAR_snowflake_private_key` | `SNOWFLAKE_PRIVATE_KEY` | ✅ Yes | Copy full PEM content |
| `TF_VAR_snowflake_role` | (none) | ➕ New | Set to `SYSADMIN` |
| `AWS_ACCESS_KEY_ID` | (none) | ➕ New | From AWS IAM |
| `AWS_SECRET_ACCESS_KEY` | (none) | ➕ New | From AWS IAM |
| `AWS_DEFAULT_REGION` | (none) | ➕ New | e.g., `us-east-1` |

## Step-by-Step Setup

### Step 1: View Your Actions Secrets

1. Go to: **Settings → Secrets and variables → Actions**
2. Note the values of:
   - Variable: `SNOWFLAKE_ACCOUNT`
   - Variable: `SNOWFLAKE_USER`
3. You'll need to copy `SNOWFLAKE_PRIVATE_KEY` (can't view, but can update)

### Step 2: Create Codespaces Secrets

1. Go to: **Settings → Secrets and variables → Codespaces**
2. Click: **New repository secret**
3. Add each secret from the table above

**Note:** GitHub will automatically convert your secret names to UPPERCASE. This is expected behavior and will work correctly.

### Step 3: Copy Values

For secrets you can't view (like `SNOWFLAKE_PRIVATE_KEY`):
- If you have the original file: Copy from `snowflake_key.p8`
- If you don't: You'll need to regenerate the key pair

## Authentication Flow

### GitHub Actions (Current)
```
Workflow runs
    ↓
Uses SNOWFLAKE_ACCOUNT, SNOWFLAKE_USER, SNOWFLAKE_PRIVATE_KEY
    ↓
Connects to Snowflake
    ↓
Runs DDL scripts
```

### Codespaces (New)
```
Open Codespace
    ↓
Secrets loaded as environment variables (TF_VAR_*)
    ↓
Run: terraform apply
    ↓
Terraform reads TF_VAR_* variables
    ↓
Connects to Snowflake
    ↓
Creates warehouses
```

## Key Differences

| Aspect | GitHub Actions | Codespaces |
|--------|----------------|------------|
| **Secret Prefix** | None | `TF_VAR_` |
| **Usage** | Workflow YAML | Terminal commands |
| **Tool** | Custom action | Terraform |
| **Purpose** | Deploy DDL scripts | Provision infrastructure |
| **Trigger** | Git push/PR | Manual commands |

## Private Key Format

Both Actions and Codespaces need the **same private key format**:

```
-----BEGIN PRIVATE KEY-----
MIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQC7Z8V9...
(multiple lines of base64 encoded key)
...
-----END PRIVATE KEY-----
```

**Important:**
- Include the header: `-----BEGIN PRIVATE KEY-----`
- Include the footer: `-----END PRIVATE KEY-----`
- Include all newlines (multi-line format)
- No extra spaces or characters

## Verification Commands

### Check Actions Secrets (in workflow)
```yaml
- name: Verify secrets
  run: |
    echo "Account: ${SNOWFLAKE_ACCOUNT:0:5}..."
    echo "User: $SNOWFLAKE_USER"
```

### Check Codespaces Secrets (in terminal)
```bash
echo "Account: ${TF_VAR_snowflake_account:0:5}..."
echo "User: ${TF_VAR_snowflake_user}"
echo "Role: ${TF_VAR_snowflake_role}"
```

## Troubleshooting

### "I can't see my SNOWFLAKE_PRIVATE_KEY value"

GitHub doesn't allow viewing secret values after creation. Options:
1. **If you have the original file**: Copy from `snowflake_key.p8`
2. **If you don't have it**: Generate a new key pair and update both Actions and Codespaces

### "My Codespace can't authenticate"

Check:
1. ✅ All 7 secrets are set in Codespaces (not just Actions)
2. ✅ Secret names have `TF_VAR_` prefix (case-sensitive)
3. ✅ Private key includes header and footer
4. ✅ Codespace was created/restarted after adding secrets

### "Do I need to update both when rotating keys?"

Yes! When rotating credentials:
1. Generate new key pair
2. Update Snowflake user with new public key
3. Update `SNOWFLAKE_PRIVATE_KEY` in Actions secrets
4. Update `TF_VAR_snowflake_private_key` in Codespaces secrets

## Security Best Practices

✅ **Do:**
- Use the same service account for both Actions and Codespaces
- Rotate keys every 90 days
- Use repository secrets (not user secrets) for team access
- Delete Codespaces when not in use

❌ **Don't:**
- Share private keys via chat or email
- Commit keys to the repository
- Use production credentials in development
- Leave secrets in terminal history

## Quick Reference

**To set up Codespaces from scratch:**
```bash
# 1. Set secrets in GitHub UI (Settings → Codespaces)
# 2. Open Codespace
# 3. Verify secrets
cd infra/aws/tf
env | grep TF_VAR

# 4. Run Terraform
terraform init
terraform plan
terraform apply
```

## Related Documentation

- [CODESPACES_QUICK_START.md](./CODESPACES_QUICK_START.md) - Quick setup guide
- [CODESPACES_SETUP.md](./CODESPACES_SETUP.md) - Detailed setup guide
- [SNOWFLAKE_SETUP.md](./SNOWFLAKE_SETUP.md) - Snowflake configuration
- [.codespaces-secrets-template.txt](./.codespaces-secrets-template.txt) - Copy-paste template
