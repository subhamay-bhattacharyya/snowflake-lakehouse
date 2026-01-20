# How Codespaces Secrets Map to Terraform Variables

This document explains the automatic mapping between Codespaces secrets and Terraform variables.

## The Magic: TF_VAR_ Prefix

Terraform has a built-in convention: **Any environment variable starting with `TF_VAR_` is automatically mapped to a Terraform variable.**

## Complete Flow

```
┌─────────────────────────────────────────────────────────────────────────┐
│ Step 1: You Set Codespaces Secret                                       │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                          │
│  GitHub Codespaces Secret:                                              │
│  Name:  TF_VAR_SNOWFLAKE_ACCOUNT                                        │
│  Value: AGXUOKJ-JKC15404                                                │
│                                                                          │
└─────────────────────────────────────────────────────────────────────────┘
                                    ↓
                    (Loaded as environment variable)
                                    ↓
┌─────────────────────────────────────────────────────────────────────────┐
│ Step 2: Codespace Environment                                           │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                          │
│  $ env | grep TF_VAR                                                    │
│  TF_VAR_SNOWFLAKE_ACCOUNT=AGXUOKJ-JKC15404                              │
│  TF_VAR_SNOWFLAKE_USER=GH_ACTIONS_USER                                  │
│  TF_VAR_SNOWFLAKE_PRIVATE_KEY=-----BEGIN PRIVATE KEY-----...            │
│  TF_VAR_SNOWFLAKE_ROLE=SYSADMIN                                         │
│                                                                          │
└─────────────────────────────────────────────────────────────────────────┘
                                    ↓
                    (Terraform reads environment variables)
                                    ↓
┌─────────────────────────────────────────────────────────────────────────┐
│ Step 3: Terraform Variable Declaration (variables.tf)                   │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                          │
│  variable "snowflake_account" {                                         │
│    description = "Snowflake account identifier"                         │
│    type        = string                                                 │
│    default     = ""                                                     │
│  }                                                                       │
│                                                                          │
│  Terraform automatically maps:                                          │
│  TF_VAR_SNOWFLAKE_ACCOUNT → var.snowflake_account                       │
│                                                                          │
└─────────────────────────────────────────────────────────────────────────┘
                                    ↓
                    (Variable is now available as var.snowflake_account)
                                    ↓
┌─────────────────────────────────────────────────────────────────────────┐
│ Step 4: Provider Configuration (providers.tf)                           │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                          │
│  provider "snowflake" {                                                 │
│    account     = var.snowflake_account  ← Uses the variable            │
│    user        = var.snowflake_user                                     │
│    private_key = var.snowflake_private_key                              │
│    role        = var.snowflake_role                                     │
│  }                                                                       │
│                                                                          │
└─────────────────────────────────────────────────────────────────────────┘
                                    ↓
                    (Provider connects to Snowflake)
                                    ↓
┌─────────────────────────────────────────────────────────────────────────┐
│ Step 5: Terraform Connects to Snowflake                                 │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                          │
│  Snowflake Provider uses:                                               │
│  - Account: AGXUOKJ-JKC15404                                            │
│  - User: GH_ACTIONS_USER                                                │
│  - Private Key: (from TF_VAR_SNOWFLAKE_PRIVATE_KEY)                     │
│  - Role: SYSADMIN                                                       │
│                                                                          │
│  ✓ Authentication successful                                            │
│  ✓ Ready to create resources                                            │
│                                                                          │
└─────────────────────────────────────────────────────────────────────────┘
```

## The Files Involved

### 1. variables.tf (Line 58-62)
```hcl
variable "snowflake_account" {
  description = "Snowflake account identifier"
  type        = string
  default     = ""
}
```
**Purpose:** Declares that this variable exists and can be used in Terraform.

**Note:** There's NO explicit mapping here. The mapping happens automatically through Terraform's `TF_VAR_` convention.

### 2. providers.tf (Line 27-32)
```hcl
provider "snowflake" {
  account     = var.snowflake_account
  user        = var.snowflake_user
  password    = var.snowflake_password != "" ? var.snowflake_password : null
  private_key = var.snowflake_private_key != "" ? var.snowflake_private_key : null
  role        = var.snowflake_role
}
```
**Purpose:** Uses the variable to configure the Snowflake provider.

## The Automatic Mapping Rules

Terraform automatically maps environment variables to input variables using this pattern:

| Environment Variable | Terraform Variable | Rule |
|---------------------|-------------------|------|
| `TF_VAR_SNOWFLAKE_ACCOUNT` | `var.snowflake_account` | Remove `TF_VAR_` prefix, convert to lowercase |
| `TF_VAR_SNOWFLAKE_USER` | `var.snowflake_user` | Remove `TF_VAR_` prefix, convert to lowercase |
| `TF_VAR_snowflake_account` | `var.snowflake_account` | Remove `TF_VAR_` prefix (already lowercase) |
| `TF_VAR_Snowflake_Account` | `var.snowflake_account` | Remove `TF_VAR_` prefix, convert to lowercase |

**Key Point:** The case of the environment variable doesn't matter. Terraform normalizes it to lowercase after removing the `TF_VAR_` prefix.

## Where Is The Mapping Code?

**There is no explicit mapping code!** This is a built-in Terraform feature.

From Terraform's documentation:
> "Terraform searches the environment of its own process for environment variables named TF_VAR_ followed by the name of a declared variable."

The mapping happens inside Terraform's core engine, not in your configuration files.

## How to Verify the Mapping

### In Your Codespace Terminal:

```bash
# 1. Check environment variables are set
env | grep TF_VAR

# Output:
# TF_VAR_SNOWFLAKE_ACCOUNT=AGXUOKJ-JKC15404
# TF_VAR_SNOWFLAKE_USER=GH_ACTIONS_USER
# TF_VAR_SNOWFLAKE_PRIVATE_KEY=-----BEGIN PRIVATE KEY-----...
# TF_VAR_SNOWFLAKE_ROLE=SYSADMIN

# 2. Check Terraform can see the variables
cd infra/aws/tf
terraform console

# In the Terraform console, type:
> var.snowflake_account
"AGXUOKJ-JKC15404"

> var.snowflake_user
"GH_ACTIONS_USER"

> var.snowflake_role
"SYSADMIN"

# Press Ctrl+D to exit
```

## Alternative Ways to Set Variables

Terraform supports multiple ways to set variables (in order of precedence):

### 1. Environment Variables (What You're Using)
```bash
export TF_VAR_SNOWFLAKE_ACCOUNT="AGXUOKJ-JKC15404"
terraform apply
```
✅ **Best for Codespaces** - Secrets are automatically loaded

### 2. Command Line Flags
```bash
terraform apply -var="snowflake_account=AGXUOKJ-JKC15404"
```
❌ Not recommended - Exposes secrets in command history

### 3. terraform.tfvars File
```hcl
# terraform.tfvars
snowflake_account = "AGXUOKJ-JKC15404"
```
❌ Not recommended - Would commit secrets to git

### 4. terraform.tfvars.json File
```json
{
  "snowflake_account": "AGXUOKJ-JKC15404"
}
```
❌ Not recommended - Would commit secrets to git

### 5. Variable Defaults (in variables.tf)
```hcl
variable "snowflake_account" {
  default = "AGXUOKJ-JKC15404"
}
```
❌ Not recommended - Would commit secrets to git

## Why TF_VAR_ Is Perfect for Codespaces

✅ **Secure:** Secrets stored in GitHub, not in code
✅ **Automatic:** No manual configuration needed
✅ **Clean:** No files to gitignore
✅ **Team-friendly:** Each developer can have their own secrets
✅ **Consistent:** Same pattern for all variables

## Common Misconceptions

### ❌ "I need to add mapping code somewhere"
**No!** The mapping is automatic. Just declare the variable in `variables.tf` and use it.

### ❌ "The variable names must match exactly"
**No!** Terraform is case-insensitive. `TF_VAR_SNOWFLAKE_ACCOUNT` and `TF_VAR_snowflake_account` both map to `var.snowflake_account`.

### ❌ "I need to configure the TF_VAR_ prefix somewhere"
**No!** This is a built-in Terraform convention. It works out of the box.

### ❌ "Codespaces secrets and environment variables are different"
**No!** Codespaces secrets ARE environment variables. They're automatically loaded into your terminal environment.

## Debugging Tips

### Problem: Variable is empty or not set

```bash
# Check if environment variable exists
echo $TF_VAR_SNOWFLAKE_ACCOUNT

# If empty, check all TF_VAR variables
env | grep TF_VAR

# If none appear, restart your Codespace
```

### Problem: Terraform says variable is not declared

```bash
# Check variables.tf has the declaration
grep "variable \"snowflake_account\"" infra/aws/tf/variables.tf

# Should output:
# variable "snowflake_account" {
```

### Problem: Authentication fails

```bash
# Verify the value is correct
terraform console
> var.snowflake_account
> var.snowflake_user
> var.snowflake_role

# Check if private key is set (don't print the full value!)
> length(var.snowflake_private_key) > 0
true
```

## Summary

**Where is the mapping?**
- It's **built into Terraform** - no configuration needed!

**What files are involved?**
1. **variables.tf** - Declares the variable exists
2. **providers.tf** - Uses the variable
3. **Codespaces secrets** - Provides the value via `TF_VAR_*` environment variables

**The magic:**
```
TF_VAR_SNOWFLAKE_ACCOUNT (env var) → var.snowflake_account (Terraform)
```

This happens automatically when you run `terraform plan` or `terraform apply`!

## References

- [Terraform Environment Variables Documentation](https://developer.hashicorp.com/terraform/cli/config/environment-variables#tf_var_name)
- [Terraform Input Variables](https://developer.hashicorp.com/terraform/language/values/variables)
- [GitHub Codespaces Secrets](https://docs.github.com/en/codespaces/managing-your-codespaces/managing-secrets-for-your-codespaces)
