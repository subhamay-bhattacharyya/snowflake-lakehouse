# GitHub Actions Setup for Snowflake Deployment

This guide explains how to configure GitHub Secrets and Variables for the Snowflake deployment workflow.

## Security Best Practices

We use **Variables** for non-sensitive configuration and **Secrets** for credentials:

| Item | Type | Visibility | Security Level |
|------|------|------------|----------------|
| Account, User, Role, Warehouse, Database | **Variables** | Visible in logs | Low risk |
| Private Key, Passphrase | **Secrets** | Masked in logs | High risk |

## Setup Instructions

### 1. Create GitHub Variables

Go to: **Settings → Secrets and variables → Actions → Variables tab**

Click **New repository variable** and add:

```
Name: SNOWFLAKE_ACCOUNT
Value: your-account-name (e.g., xy12345.us-east-1)

Name: SNOWFLAKE_USER
Value: your-service-account-user (e.g., GH_ACTIONS_USER)

Name: SNOWFLAKE_ROLE
Value: SYSADMIN (or your deployment role)

Name: SNOWFLAKE_WAREHOUSE
Value: COMPUTE_WH

Name: SNOWFLAKE_DATABASE
Value: RAW_DB
```

### 2. Create GitHub Secrets

Go to: **Settings → Secrets and variables → Actions → Secrets tab**

Click **New repository secret** and add:

```
Name: SNOWFLAKE_PRIVATE_KEY
Value: -----BEGIN ENCRYPTED PRIVATE KEY-----
       [Your private key content here]
       -----END ENCRYPTED PRIVATE KEY-----

Name: SNOWFLAKE_PASSPHRASE
Value: your-private-key-passphrase
```

## Generating Snowflake Key Pair

If you don't have a key pair yet:

```bash
# Generate private key
openssl genrsa 2048 | openssl pkcs8 -topk8 -inform PEM -out snowflake_key.p8 -v2 aes256

# Generate public key
openssl rsa -in snowflake_key.p8 -pubout -out snowflake_key.pub

# Copy private key content (paste this into GitHub Secret)
cat snowflake_key.p8

# Copy public key for Snowflake (remove header/footer and newlines)
grep -v "BEGIN PUBLIC" snowflake_key.pub | grep -v "END PUBLIC" | tr -d '\n'
```

## Configure Snowflake User

In Snowflake, run:

```sql
-- Create user with public key authentication
CREATE USER IF NOT EXISTS GH_ACTIONS_USER
  RSA_PUBLIC_KEY = 'MIIBIjANBgkqhki...' -- Your public key here (no header/footer)
  DEFAULT_ROLE = SYSADMIN
  DEFAULT_WAREHOUSE = COMPUTE_WH;

-- Grant necessary privileges
GRANT ROLE SYSADMIN TO USER GH_ACTIONS_USER;

-- Verify
DESC USER GH_ACTIONS_USER;
```

## Environment-Specific Configuration

For multiple environments (dev/staging/prod), use **GitHub Environments**:

1. Go to **Settings → Environments**
2. Create environments: `dev`, `staging`, `prod`
3. Add environment-specific variables/secrets to each

Then update the workflow to use environments:

```yaml
jobs:
  deploy:
    environment: production  # or dev, staging
    runs-on: ubuntu-latest
```

## Testing the Setup

1. Push a change to a SQL file in `snowflake/` directory
2. Go to **Actions** tab
3. Watch the workflow run
4. Check logs for any authentication issues

## Troubleshooting

**Issue**: Authentication failed
- Verify the public key is correctly set in Snowflake user
- Ensure private key format is correct (PKCS#8)
- Check passphrase is correct

**Issue**: Variables not found
- Ensure you created them in the **Variables** tab, not Secrets
- Variable names are case-sensitive

**Issue**: Permission denied
- Verify the Snowflake user has necessary grants
- Check the role has access to warehouses and databases

## Security Notes

✅ **DO:**
- Rotate keys regularly
- Use service accounts (not personal accounts)
- Limit role permissions to minimum required
- Use environment protection rules for production

❌ **DON'T:**
- Commit private keys to the repository
- Share passphrases in plain text
- Use admin accounts for automation
- Log sensitive information
