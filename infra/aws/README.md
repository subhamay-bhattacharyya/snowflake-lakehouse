# AWS Infrastructure Setup

This directory contains AWS infrastructure configurations for the Snowflake Lakehouse project.

## Overview

The AWS infrastructure includes:
- **S3 Buckets**: Storage for lakehouse data (Bronze, Silver, Gold layers)
- **IAM Roles**: Roles for Snowflake storage integration
- **OIDC Provider**: Secure GitHub Actions authentication
- **CloudFormation Templates**: Infrastructure as Code for OIDC setup

## Directory Structure

```
infra/aws/
├── cfn/                    # CloudFormation templates
│   └── github-oidc-setup.yaml
├── tf/                     # Terraform configurations
│   ├── modules/
│   │   ├── iam/           # IAM roles and policies module
│   │   └── s3/            # S3 bucket module
│   ├── main.tf
│   ├── variables.tf
│   └── outputs.tf
└── README.md              # This file
```

## OIDC Setup: GitHub → AWS

### Prerequisites

Before setting up OIDC, ensure you have:
- AWS account with administrative access
- AWS CLI configured with an IAM user that has `AdministratorAccess` (only needed for initial OIDC setup)
- GitHub repository with Actions enabled

### Design Overview

**Why OIDC (no long-lived access keys):**

OpenID Connect (OIDC) provides a secure, modern, and automated way for GitHub Actions to access cloud resources without storing or rotating long-lived credentials. Instead of embedding permanent AWS/GCP/Azure access keys in GitHub Secrets, workloads exchange short-lived tokens that are issued only when needed and expire automatically. This dramatically reduces the risk of credential leakage, simplifies secret management, and aligns with cloud-provider security best practices.

**With OIDC:**
- ✅ **No hard-coded credentials** — nothing stored in GitHub Secrets, nothing to rotate manually
- ✅ **Short-lived tokens** — automatically expire and minimize blast radius even if exposed
- ✅ **Granular permissions** — cloud roles (IAM/GCP SA/Azure Entra Apps) can restrict access tightly
- ✅ **Automatic identity verification** — cloud providers validate that the request is coming from your GitHub workflow
- ✅ **Improved security posture** — eliminates a major attack surface associated with leaked access keys
- ✅ **Best practice for CI/CD** — recommended by AWS, GCP, Azure, and GitHub for secure pipelines

### Create IAM OIDC Identity Provider

The CloudFormation template creates:
- An OIDC Identity Provider for GitHub
- An IAM role that GitHub Actions can assume
- Proper trust policies with conditions for your repository

Execute the following CloudFormation template from the directory `infra/aws/cfn`:

```bash
cd infra/aws/cfn

aws cloudformation deploy \
  --template-file github-oidc-setup.yaml \
  --stack-name github-oidc-setup-snowflake-lakehouse \
  --capabilities CAPABILITY_NAMED_IAM \
  --parameter-overrides \
    GitHubOrg=subhamay-bhattacharyya \
    GitHubRepo=snowflake-lakehouse
```

**Note:** Replace `subhamay-bhattacharyya` with your GitHub organization/username and `snowflake-lakehouse` with your repository name.

### Verify OIDC Setup

After deploying the CloudFormation stack, verify the setup:

```bash
# Get the IAM role ARN
aws cloudformation describe-stacks \
  --stack-name github-oidc-setup \
  --query 'Stacks[0].Outputs[?OutputKey==`GitHubActionsRoleArn`].OutputValue' \
  --output text

# Verify OIDC provider exists
aws iam list-open-id-connect-providers

# Check the OIDC provider details
aws iam get-open-id-connect-provider \
  --open-id-connect-provider-arn arn:aws:iam::YOUR_ACCOUNT_ID:oidc-provider/token.actions.githubusercontent.com
```

### Update GitHub Actions Workflow

Once OIDC is set up, update your GitHub Actions workflow to use the IAM role instead of access keys.

**Add the role ARN to GitHub Variables:**

1. Go to your repository → Settings → Secrets and variables → Actions → Variables
2. Add a new variable:
   - Name: `AWS_ROLE_ARN`
   - Value: The role ARN from CloudFormation output (e.g., `arn:aws:iam::123456789012:role/GitHubActionsRole`)

**Example workflow step:**

```yaml
- name: Configure AWS Credentials
  uses: aws-actions/configure-aws-credentials@v4
  with:
    role-to-assume: ${{ vars.AWS_ROLE_ARN }}
    aws-region: us-east-1
```

### Configure GitHub Repository Secrets

For the Terraform deployment workflow to work, you need to configure the following secrets and variables in your GitHub repository.

#### Required Secrets

Go to: **Repository → Settings → Secrets and variables → Actions → Secrets**

1. **`TF_TOKEN_APP_TERRAFORM_IO`**
   - **Description**: Terraform Cloud API token for authentication
   - **How to get it**:
     ```bash
     # Login to Terraform Cloud
     terraform login
     
     # The token is stored in ~/.terraform.d/credentials.tfrc.json
     # Or create a new token at: https://app.terraform.io/app/settings/tokens
     ```
   - **Value format**: `your-terraform-cloud-token`
   - **Example**: `AbCdEfGhIjKlMnOpQrStUvWxYz1234567890`

2. **`AWS_OIDC_ROLE_ARN`**
   - **Description**: AWS IAM role ARN for OIDC authentication
   - **How to get it**:
     ```bash
     # Get from CloudFormation output
     aws cloudformation describe-stacks \
       --stack-name github-oidc-setup \
       --query 'Stacks[0].Outputs[?OutputKey==`GitHubActionsRoleArn`].OutputValue' \
       --output text
     ```
   - **Value format**: `arn:aws:iam::ACCOUNT_ID:role/ROLE_NAME`
   - **Example**: `arn:aws:iam::123456789012:role/GitHubActionsRole`

#### Required Variables

Go to: **Repository → Settings → Secrets and variables → Actions → Variables**

1. **`TF_LINT_VER`**
   - **Description**: TFLint version to use for Terraform linting
   - **Value**: `v0.50.3` (or latest version from [TFLint releases](https://github.com/terraform-linters/tflint/releases))

2. **`AWS_REGION`**
   - **Description**: AWS region for resource deployment
   - **Value**: `us-east-1` (or your preferred region)

#### Step-by-Step Setup

**1. Create Terraform Cloud Token:**

```bash
# Login to Terraform Cloud (opens browser)
terraform login

# Or create token manually:
# 1. Go to https://app.terraform.io/app/settings/tokens
# 2. Click "Create an API token"
# 3. Name: "GitHub Actions"
# 4. Copy the token
```

**2. Get AWS OIDC Role ARN:**

```bash
# After deploying the CloudFormation stack
aws cloudformation describe-stacks \
  --stack-name github-oidc-setup \
  --query 'Stacks[0].Outputs[?OutputKey==`GitHubActionsRoleArn`].OutputValue' \
  --output text
```

**3. Add Secrets to GitHub:**

```bash
# Using GitHub CLI (gh)
gh secret set TF_TOKEN_APP_TERRAFORM_IO --body "your-terraform-cloud-token"
gh secret set AWS_OIDC_ROLE_ARN --body "arn:aws:iam::123456789012:role/GitHubActionsRole"

# Or manually via GitHub UI:
# Repository → Settings → Secrets and variables → Actions → New repository secret
```

**4. Add Variables to GitHub:**

```bash
# Using GitHub CLI (gh)
gh variable set TF_LINT_VER --body "v0.50.3"
gh variable set AWS_REGION --body "us-east-1"

# Or manually via GitHub UI:
# Repository → Settings → Secrets and variables → Actions → Variables → New repository variable
```

#### Verification

After setting up secrets and variables, verify they're configured correctly:

```bash
# List all secrets (values are hidden)
gh secret list

# List all variables
gh variable list
```

**Expected output:**
```
Secrets:
TF_TOKEN_APP_TERRAFORM_IO    Updated YYYY-MM-DD
AWS_OIDC_ROLE_ARN           Updated YYYY-MM-DD

Variables:
TF_LINT_VER    v0.50.3
AWS_REGION     us-east-1
```

#### Security Best Practices

- ✅ **Never commit secrets** to the repository
- ✅ **Use secrets for sensitive data** (tokens, credentials, ARNs)
- ✅ **Use variables for non-sensitive config** (versions, regions)
- ✅ **Rotate tokens regularly** (every 90 days recommended)
- ✅ **Use least privilege** for IAM roles
- ✅ **Enable branch protection** to prevent unauthorized deployments
- ✅ **Audit secret access** regularly in GitHub settings

### Benefits of OIDC Setup

- ✅ **No AWS access keys** stored in GitHub Secrets
- ✅ **Automatic credential rotation** - tokens expire automatically
- ✅ **Fine-grained access control** via IAM policies
- ✅ **Audit trail** through CloudTrail
- ✅ **Reduced security risk** - no long-lived credentials to leak
- ✅ **Compliance-friendly** - meets security best practices

## Terraform Configuration

### Terraform Cloud Setup (Recommended)

If you're using Terraform Cloud (HashiCorp Cloud Platform) for remote state management, follow these steps:

#### 1. Create Terraform Cloud Account

1. Sign up at [https://app.terraform.io/signup](https://app.terraform.io/signup)
2. Create an organization (e.g., `my-org`)

#### 2. Create Workspace

```bash
# Login to Terraform Cloud
terraform login

# Create a new workspace
# Option 1: Via Terraform Cloud UI
# - Go to your organization
# - Click "New Workspace"
# - Choose "CLI-driven workflow"
# - Name: snowflake-lakehouse-aws-dev

# Option 2: Via CLI (after configuring backend)
cd infra/aws/tf
terraform init
```

#### 3. Configure Backend

Create or update `backend.tf` in `infra/aws/tf/`:

```hcl
terraform {
  cloud {
    organization = "subhamay-bhattacharyya-projects"
    
    workspaces {
      name = "snowflake-lakehouse-aws"
    }
  }
}
```

#### 4. Set Workspace Variables

In Terraform Cloud workspace settings, add these variables:

**Environment Variables:**
- `AWS_ACCESS_KEY_ID` - AWS access key (if not using OIDC)
- `AWS_SECRET_ACCESS_KEY` - AWS secret key (if not using OIDC)
- `AWS_REGION` - AWS region (e.g., `us-east-1`)

**Terraform Variables:**
- `project_name` - Project name (e.g., `snowflake-lakehouse`)
- `environment` - Environment name (e.g., `dev`, `prod`)

**Note:** If using OIDC with Terraform Cloud, configure dynamic provider credentials instead of static AWS keys.

#### 5. Initialize and Apply

```bash
cd infra/aws/tf

# Initialize with Terraform Cloud backend
terraform init

# Plan the deployment
terraform plan

# Apply the configuration
terraform apply
```

### S3 Bucket Setup (Alternative Backend)

**Note:** S3 bucket creation is only required if you're using S3 as the Terraform backend for state storage. If you're using Terraform Cloud or another backend, you can skip this step.

The Terraform configuration creates S3 buckets for:
- **Terraform state storage** (optional - only if using S3 backend)
- **Lakehouse data layers** (Bronze, Silver, Gold)

#### Using S3 Backend

If you prefer S3 backend over Terraform Cloud, configure `backend.tf`:

```hcl
terraform {
  backend "s3" {
    bucket         = "my-terraform-state-bucket"
    key            = "snowflake-lakehouse/aws/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-state-lock"
  }
}
```

```bash
cd infra/aws/tf

# Initialize Terraform
terraform init

# Plan the deployment
terraform plan

# Apply the configuration
terraform apply
```

### Terraform Outputs

After applying, Terraform will output:
- S3 bucket names
- S3 bucket ARNs
- IAM role ARN for Snowflake

### Variables

Key variables to configure in `terraform.tfvars`:

```hcl
project_name = "snowflake-lakehouse"
environment  = "dev"
aws_region   = "us-east-1"
```

## Snowflake Authentication Setup

### Generate Unencrypted Private Key for Terraform

For Terraform to authenticate with Snowflake, you need to set up key-pair authentication. Follow these steps to generate and configure an unencrypted private key.

#### Step 1: Generate New Key Pair

```bash
# Create a directory for the keys
mkdir -p ~/snowflake-keys && cd ~/snowflake-keys

# Update .gitignore to prevent committing keys to GitHub
echo "snowflake-keys/" >> ~/.gitignore
echo "*.p8" >> ~/.gitignore
echo "snowflake_key.*" >> ~/.gitignore

# Generate unencrypted private key (2048-bit RSA)
openssl genrsa 2048 | openssl pkcs8 -topk8 -inform PEM -out snowflake_key.p8 -nocrypt

# Generate public key from private key
openssl rsa -in snowflake_key.p8 -pubout -out snowflake_key.pub

echo "✅ Keys generated successfully!"
```

#### Step 2: Extract Public Key for Snowflake

```bash
# Extract public key content without BEGIN/END headers
grep -v "BEGIN PUBLIC KEY" snowflake_key.pub | grep -v "END PUBLIC KEY" | tr -d '\n'

# This will output something like:
# MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA...
```

**Copy this output** - you'll need it for Step 3.

#### Step 3: Update Snowflake User with New Public Key

Connect to Snowflake and run:

```sql
-- Switch to account admin role
USE ROLE ACCOUNTADMIN;

-- Update the user with new public key (paste the key from Step 2)
ALTER USER GH_ACTIONS_USER SET RSA_PUBLIC_KEY='MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA...';

-- Verify the key was set
DESC USER GH_ACTIONS_USER;
```

#### Step 4: Get Private Key Content for GitHub Secret

```bash
# Display the full private key (including headers)
cat snowflake_key.p8
```

**Copy the entire output** including:
- `-----BEGIN PRIVATE KEY-----`
- All the content
- `-----END PRIVATE KEY-----`

#### Step 5: Update GitHub Codespaces Secrets

1. Go to: **GitHub → Repository Settings → Secrets and variables → Codespaces**
2. Add/Update these secrets:
   - **Name:** `TF_VAR_SNOWFLAKE_ACCOUNT`  
     **Value:** Your account identifier (format: `ORGNAME-ACCOUNTNAME`, e.g., `AGXUOKJ-JKC15404`)
   
   - **Name:** `TF_VAR_SNOWFLAKE_USER`  
     **Value:** Your Snowflake username (e.g., `GH_ACTIONS_USER`)
   
   - **Name:** `TF_VAR_SNOWFLAKE_PRIVATE_KEY`  
     **Value:** Paste the entire private key from Step 4 (with headers)
   
   - **Name:** `TF_VAR_SNOWFLAKE_ROLE`  
     **Value:** `SYSADMIN` (or your preferred role)

3. **Important:** If you previously had `TF_VAR_SNOWFLAKE_PRIVATE_KEY_PASSPHRASE`, delete it (unencrypted keys don't need passphrases)

#### Step 6: Clean Up Local Keys

**Security:** Delete the local key files after updating GitHub:

```bash
rm -rf ~/snowflake-keys
```

The keys should only exist in:
- ✅ Snowflake (public key)
- ✅ GitHub Secrets (private key)
- ❌ NOT in your local filesystem or repository

#### Step 7: Restart Codespace and Test

```bash
# Restart the codespace from GitHub UI or close/reopen

# After restart, verify the new key is loaded:
echo "$TF_VAR_SNOWFLAKE_PRIVATE_KEY" | head -1
# Should output: -----BEGIN PRIVATE KEY----- (not ENCRYPTED)

# Test Terraform
cd /workspaces/snowflake-lakehouse/infra/aws/tf
terraform plan
```

### Environment Variables Mapping

Your GitHub Codespaces secrets automatically map to Terraform variables:

| GitHub Secret | Terraform Variable | Description |
|--------------|-------------------|-------------|
| `TF_VAR_SNOWFLAKE_ACCOUNT` | Split into `organization_name` + `account_name` | Account identifier (ORGNAME-ACCOUNTNAME) |
| `TF_VAR_SNOWFLAKE_USER` | `snowflake_user` | Snowflake username |
| `TF_VAR_SNOWFLAKE_PRIVATE_KEY` | `snowflake_private_key` | Private key for authentication |
| `TF_VAR_SNOWFLAKE_ROLE` | `snowflake_role` | Snowflake role (e.g., SYSADMIN) |

The Terraform configuration automatically:
1. Reads uppercase environment variables (`TF_VAR_SNOWFLAKE_*`)
2. Splits the account identifier into organization and account name
3. Maps to the Snowflake provider's required parameters

## IAM Role for Snowflake

The IAM role created for Snowflake storage integration should have:

**Trust Policy:**
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::SNOWFLAKE_ACCOUNT:user/SNOWFLAKE_USER"
      },
      "Action": "sts:AssumeRole",
      "Condition": {
        "StringEquals": {
          "sts:ExternalId": "SNOWFLAKE_EXTERNAL_ID"
        }
      }
    }
  ]
}
```

**Permissions Policy:**
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:GetObject",
        "s3:GetObjectVersion",
        "s3:ListBucket",
        "s3:GetBucketLocation"
      ],
      "Resource": [
        "arn:aws:s3:::your-bucket-name/*",
        "arn:aws:s3:::your-bucket-name"
      ]
    }
  ]
}
```

## Security Best Practices

1. **Use OIDC** instead of long-lived access keys
2. **Least privilege** - Grant only necessary permissions
3. **Enable S3 encryption** - Use SSE-S3 or SSE-KMS
4. **Enable S3 versioning** - Protect against accidental deletion
5. **Enable CloudTrail** - Audit all API calls
6. **Use S3 bucket policies** - Restrict access to specific principals
7. **Enable MFA delete** - Protect against accidental deletion
8. **Regular access reviews** - Audit IAM roles and policies

## Troubleshooting

### OIDC Authentication Fails

**Error:** "Not authorized to perform sts:AssumeRoleWithWebIdentity"

**Solution:**
- Verify the GitHub repository name matches the trust policy
- Check that the OIDC provider thumbprint is correct
- Ensure the IAM role trust policy includes the correct conditions

### S3 Access Denied

**Error:** "Access Denied" when Snowflake tries to access S3

**Solution:**
- Verify the IAM role ARN in Snowflake storage integration
- Check the IAM role permissions policy
- Ensure the S3 bucket policy allows access from the IAM role
- Verify the external ID matches between Snowflake and IAM trust policy

### CloudFormation Stack Fails

**Error:** Stack creation fails with "Resource already exists"

**Solution:**
- Delete the existing OIDC provider manually
- Or update the stack instead of creating a new one

## Additional Resources

- [AWS OIDC Documentation](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_providers_create_oidc.html)
- [GitHub Actions OIDC](https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/configuring-openid-connect-in-amazon-web-services)
- [Snowflake Storage Integration](https://docs.snowflake.com/en/user-guide/data-load-s3-config-storage-integration)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)

## Support

For issues or questions:
- Check the main repository README
- Review Snowflake and AWS documentation
- Open an issue in the GitHub repository
