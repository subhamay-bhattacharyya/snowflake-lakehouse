# Snowflake Lakehouse

![Built with Kiro](https://img.shields.io/badge/Built_with-Kiro-8845f4?logo=robot&logoColor=white)&nbsp;![Commit Activity](https://img.shields.io/github/commit-activity/t/subhamay-bhattacharyya/snowflake-lakehouse)&nbsp;![Last Commit](https://img.shields.io/github/last-commit/subhamay-bhattacharyya/snowflake-lakehouse)&nbsp;![Release Date](https://img.shields.io/github/release-date/subhamay-bhattacharyya/snowflake-lakehouse)&nbsp;![Repo Size](https://img.shields.io/github/repo-size/subhamay-bhattacharyya/snowflake-lakehouse)&nbsp;![File Count](https://img.shields.io/github/directory-file-count/subhamay-bhattacharyya/snowflake-lakehouse)&nbsp;![Issues](https://img.shields.io/github/issues/subhamay-bhattacharyya/snowflake-lakehouse)&nbsp;![Top Language](https://img.shields.io/github/languages/top/subhamay-bhattacharyya/snowflake-lakehouse)&nbsp;![Custom Endpoint](https://img.shields.io/endpoint?url=https://gist.githubusercontent.com/bsubhamay/8d142a9345ac5cff42474d131f6713de/raw/snowflake-lakehouse.json?)

A multi-cloud Snowflake Lakehouse implementation with Infrastructure as Code (Terraform) and automated DDL deployment using GitHub Actions.

## Overview

This repository provides a complete solution for deploying and managing a Snowflake Lakehouse across multiple cloud providers (AWS, Azure, GCP). It includes:

- **Infrastructure as Code**: Terraform configurations for cloud resources (S3, GCS, Azure Storage)
- **Snowflake DDL Scripts**: Organized SQL scripts for databases, schemas, tables, and other Snowflake objects
- **Automated Deployment**: GitHub Actions workflows for CI/CD
- **Multi-Cloud Support**: Ready for AWS, Azure, and GCP deployments

## Repository Structure

```
.
├── infra/                     # Infrastructure as Code
│   ├── snowflake/tf/          # Multi-cloud Snowflake Terraform (NEW)
│   ├── aws/tf/                # Legacy AWS-only Terraform
│   ├── azure/tf/              # Azure resources (Storage, Managed Identity)
│   └── gcp/tf/                # GCP resources (GCS, Service Accounts)
├── snowflake/                 # Snowflake DDL Scripts
│   ├── 00_account/            # Account-level objects
│   ├── 01_security/           # Roles, users, grants
│   ├── 02_warehouses/         # Virtual warehouses
│   ├── 03_databases/          # Database definitions
│   ├── 04_storage/            # Storage integrations & stages
│   ├── 05_schemas/            # Schema-level objects (tables, views)
│   ├── 06_pipes/              # Snowpipe definitions
│   ├── 07_tasks/              # Task definitions
│   ├── 08_functions/          # UDFs and UDTFs
│   ├── 09_procedures/         # Stored procedures
│   ├── environments/          # Environment configs (dev/staging/prod)
│   └── scripts/               # Utility scripts
└── .github/
    └── workflows/             # GitHub Actions workflows
```

## Architecture

This project uses a **3-phase multi-cloud architecture**:

### Phase 1 & 2: Snowflake Core + Cloud Storage (Parallel)
- **Snowflake Core** (cloud-agnostic): Warehouses, Databases, Schemas
- **Cloud Storage** (parallel): AWS S3, GCP GCS, Azure Blob

### Phase 3: Integrations (After Phase 1 & 2)
- Storage Integrations
- External Stages
- Snowpipes

**See detailed architecture:** [infra/snowflake/tf/ARCHITECTURE.md](infra/snowflake/tf/ARCHITECTURE.md)

## Getting Started

### Prerequisites

- **Terraform** >= 1.0
- **Snowflake Account** with appropriate permissions
- **Cloud Provider Account** (AWS, Azure, or GCP)
- **GitHub Repository** with Actions enabled

#### One-Time Snowflake Setup

Before using this action, run the following SQL script in Snowflake to create the utility infrastructure (only needs to be run once):

**Step 1: Create Utility Infrastructure**

```sql
-- =========================================================
-- Snowflake Utility Setup for DDL Migrations
-- =========================================================
-- This script creates:
--   1. A dedicated warehouse for CI/CD metadata operations
--   2. Utility database (UTIL_DB)
--   3. Utility schema (UTIL_SCHEMA)
--   4. DDL migration history table
--
-- Safe to re-run (idempotent)
-- =========================================================

-- -----------------------------------------------------------
-- 1. Create and use a dedicated warehouse
-- -----------------------------------------------------------
CREATE WAREHOUSE IF NOT EXISTS UTIL_WH
  WAREHOUSE_SIZE = 'XSMALL'
  WAREHOUSE_TYPE = 'STANDARD'
  AUTO_SUSPEND = 60
  AUTO_RESUME = TRUE
  INITIALLY_SUSPENDED = TRUE
  COMMENT = 'Warehouse for CI/CD utility operations and DDL migration tracking';

USE WAREHOUSE UTIL_WH;

-- -----------------------------------------------------------
-- 2. Create utility database and schema
-- -----------------------------------------------------------
CREATE DATABASE IF NOT EXISTS UTIL_DB
  COMMENT = 'Utility database for CI/CD metadata and migration tracking';

CREATE SCHEMA IF NOT EXISTS UTIL_DB.UTIL_SCHEMA
  COMMENT = 'Utility schema for migration and operational tables';

-- -----------------------------------------------------------
-- 3. Create DDL migration history table
-- -----------------------------------------------------------
CREATE TABLE IF NOT EXISTS UTIL_DB.UTIL_SCHEMA.DDL_MIGRATION_HISTORY (
  script_name    STRING        NOT NULL,
  script_path    STRING        NOT NULL,
  checksum       STRING        NOT NULL,
  applied_at     TIMESTAMP_LTZ NOT NULL DEFAULT CURRENT_TIMESTAMP(),
  status         STRING        NOT NULL,
  error_message  STRING,
  run_id         STRING,
  actor          STRING
) COMMENT = 'Tracks executed Snowflake DDL migration scripts for CI/CD pipelines';

-- -----------------------------------------------------------
-- 4. (Optional) Verify creation
-- -----------------------------------------------------------
SELECT
  'UTIL_DB.UTIL_SCHEMA.DDL_MIGRATION_HISTORY created successfully' AS status,
  CURRENT_TIMESTAMP() AS verified_at;
```

**Step 2: Grant MANAGE GRANTS Privilege to SYSADMIN**

SYSADMIN needs the MANAGE GRANTS privilege to grant permissions to other roles like PUBLIC. Run this as ACCOUNTADMIN:

```sql
USE ROLE ACCOUNTADMIN;

-- Grant MANAGE GRANTS privilege to SYSADMIN
-- This allows SYSADMIN to grant privileges on objects it owns
GRANT MANAGE GRANTS ON ACCOUNT TO ROLE SYSADMIN;

-- Verify the grant
SHOW GRANTS TO ROLE SYSADMIN;
```

**Note:** With this setup, SYSADMIN can both create objects and manage their permissions, simplifying the deployment process.

**Note:** If you want to use a different database/schema/table name, you can customize it using the `migrations_table` input parameter in the GitHub Actions workflow.

### 1. Create Dedicated Service Account

For security best practices, create a dedicated service account for GitHub Actions instead of using your personal account.

#### Step 1: Generate Key Pair

On your local machine, generate an RSA key pair:

```bash
# Generate private key with passphrase
# Generate unencrypted PKCS8 private key
openssl genrsa 2048 | openssl pkcs8 -topk8 -inform PEM -out snowflake_key.p8 -nocrypt

# Generate public key
openssl rsa -in snowflake_key.p8 -pubout -out snowflake_key.pub

# Extract public key value (remove header/footer and newlines)
grep -v "BEGIN PUBLIC" snowflake_key.pub | grep -v "END PUBLIC" | tr -d '\n'
```

**Save the output** - you'll need it for the next step.

#### Step 2: Create Service Account in Snowflake

Run this SQL in Snowflake (replace `YOUR_PUBLIC_KEY_HERE` with the output from Step 1):

```sql
-- =========================================================
-- Create Service Account for GitHub Actions
-- =========================================================

-- Create dedicated service account
CREATE USER IF NOT EXISTS GH_ACTIONS_USER
  RSA_PUBLIC_KEY = 'YOUR_PUBLIC_KEY_HERE'
  DEFAULT_ROLE = SYSADMIN
  DEFAULT_WAREHOUSE = COMPUTE_WH
  MUST_CHANGE_PASSWORD = FALSE
  COMMENT = 'Service account for GitHub Actions CI/CD deployments';

-- Grant SYSADMIN role (for DDL and grant operations)
GRANT ROLE SYSADMIN TO USER GH_ACTIONS_USER;

-- Grant usage on warehouses
GRANT USAGE ON WAREHOUSE UTIL_WH TO ROLE SYSADMIN;
GRANT USAGE ON WAREHOUSE COMPUTE_WH TO ROLE SYSADMIN;

-- Grant usage on the utility database
GRANT USAGE ON DATABASE UTIL_DB TO ROLE SYSADMIN;
GRANT USAGE ON SCHEMA UTIL_DB.UTIL_SCHEMA TO ROLE SYSADMIN;

-- Grant create privileges for the migration table
GRANT CREATE TABLE ON SCHEMA UTIL_DB.UTIL_SCHEMA TO ROLE SYSADMIN;

-- Grant all privileges on the migration table (if it already exists)
GRANT ALL PRIVILEGES ON TABLE UTIL_DB.UTIL_SCHEMA.DDL_MIGRATION_HISTORY TO ROLE SYSADMIN;

-- If the user needs to create the database/schema (first run)
GRANT CREATE DATABASE ON ACCOUNT TO ROLE SYSADMIN;

-- Verify the user's role
DESC USER GH_ACTIONS_USER;

-- See what roles the user has
SHOW GRANTS TO USER GH_ACTIONS_USER;

-- See what the SYSADMIN role can do
SHOW GRANTS TO ROLE SYSADMIN;

```

**Security Notes:**
- ✅ Use `SYSADMIN` role for all DDL and grant operations
- ✅ Grant `MANAGE GRANTS` privilege to SYSADMIN for permission management
- ✅ Key-pair authentication is more secure than passwords
- ✅ Service accounts provide better audit trails
- ✅ Never commit private keys to the repository

### 2. Configure GitHub Secrets and Variables

Set up GitHub Actions authentication. See [.github/SETUP.md](.github/SETUP.md) for detailed instructions.

#### Required Variables (Settings → Secrets and variables → Actions → Variables):

**Snowflake Configuration:**
- `SNOWFLAKE_ACCOUNT` - Your account identifier (e.g., `AGXUOKJ-JKC15404`)
- `SNOWFLAKE_USER` - Service account username (e.g., `GH_ACTIONS_USER`)
- `SNOWFLAKE_ROLE` - Snowflake role (e.g., `SYSADMIN`)

**Cloud Provider Enablement (Control which clouds to use):**
- `ENABLE_AWS` - Set to `true` to enable AWS S3 + IAM (default: `true`)
- `ENABLE_GCP` - Set to `true` to enable GCP GCS + Service Account (default: `false`)
- `ENABLE_AZURE` - Set to `true` to enable Azure Blob + Managed Identity (default: `false`)

**AWS Configuration (if ENABLE_AWS = true):**
- `AWS_REGION` - AWS region (e.g., `us-east-1`)
- `AWS_ROLE_ARN` - AWS IAM role ARN for S3 access (e.g., `arn:aws:iam::123456789012:role/snowflake-s3-role`)
- `S3_BUCKET_NAME` - S3 bucket name for lakehouse data (e.g., `my-lakehouse-bucket`)

**GCP Configuration (if ENABLE_GCP = true):**
- `GCP_PROJECT` - GCP project ID
- `GCP_REGION` - GCP region (e.g., `us-central1`)

**Azure Configuration (if ENABLE_AZURE = true):**
- `AZURE_SUBSCRIPTION_ID` - Azure subscription ID
- `AZURE_LOCATION` - Azure location (e.g., `eastus`)

#### Required Secrets (Settings → Secrets and variables → Actions → Secrets):

**Snowflake Authentication:**
- `SNOWFLAKE_PRIVATE_KEY` - Content of `snowflake_key.p8` file (including header/footer)
- `TF_TOKEN_APP_TERRAFORM_IO` - Terraform Cloud token

**AWS Authentication (if ENABLE_AWS = true):**
- `AWS_OIDC_ROLE_ARN` - AWS IAM role ARN for OIDC authentication

**GCP Authentication (if ENABLE_GCP = true):**
- `GCP_WIF_PROVIDER` - GCP Workload Identity Federation provider
- `GCP_SERVICE_ACCOUNT` - GCP service account email

**Azure Authentication (if ENABLE_AZURE = true):**
- `AZURE_CLIENT_ID` - Azure client ID
- `AZURE_TENANT_ID` - Azure tenant ID
- `AZURE_SUBSCRIPTION_ID` - Azure subscription ID

#### Multi-Cloud Configuration Examples

**Example 1: AWS Only (Most Common)**
```
ENABLE_AWS = true
ENABLE_GCP = false
ENABLE_AZURE = false
```
**Result:** Creates Snowflake + AWS S3 + Storage Integration

**Example 2: AWS + GCP**
```
ENABLE_AWS = true
ENABLE_GCP = true
ENABLE_AZURE = false
```
**Result:** Creates Snowflake + AWS + GCP + Integrations for both

**Example 3: All Three Clouds**
```
ENABLE_AWS = true
ENABLE_GCP = true
ENABLE_AZURE = true
```
**Result:** Creates Snowflake + AWS + GCP + Azure + Integrations for all

**Note:** The workflow automatically injects variables into Terraform and creates only the enabled cloud resources.

### 2a. Configure Codespaces Secrets (For Terraform Development)

If you're running Terraform from GitHub Codespaces, you need to configure Codespaces secrets for authentication.

**See detailed setup guide:** [infra/aws/tf/README.md](infra/aws/tf/README.md) or [infra/snowflake/tf/README.md](infra/snowflake/tf/README.md)

**Quick setup:**

Navigate to: **Settings → Secrets and variables → Codespaces**

Add these secrets (copy from your GitHub Actions):

**Snowflake Authentication:**
| Secret Name | Copy From Actions |
|-------------|-------------------|
| `TF_VAR_snowflake_account` | `SNOWFLAKE_ACCOUNT` variable |
| `TF_VAR_snowflake_user` | `SNOWFLAKE_USER` variable |
| `TF_VAR_snowflake_private_key` | `SNOWFLAKE_PRIVATE_KEY` secret |
| `TF_VAR_snowflake_role` | Set to `SYSADMIN` |

**Cloud Provider Enablement:**
| Secret Name | Value | Description |
|-------------|-------|-------------|
| `TF_VAR_enable_aws` | `true` or `false` | Enable AWS resources |
| `TF_VAR_enable_gcp` | `true` or `false` | Enable GCP resources |
| `TF_VAR_enable_azure` | `true` or `false` | Enable Azure resources |

**AWS Authentication (if enable_aws = true):**
| Secret Name | Description |
|-------------|-------------|
| `AWS_ACCESS_KEY_ID` | From AWS IAM |
| `AWS_SECRET_ACCESS_KEY` | From AWS IAM |
| `AWS_DEFAULT_REGION` | e.g., `us-east-1` |

**GCP Authentication (if enable_gcp = true):**
| Secret Name | Description |
|-------------|-------------|
| `TF_VAR_gcp_project` | GCP project ID |
| `GOOGLE_CREDENTIALS` | Service account JSON key |

**Azure Authentication (if enable_azure = true):**
| Secret Name | Description |
|-------------|-------------|
| `TF_VAR_azure_subscription_id` | Azure subscription ID |
| `ARM_CLIENT_ID` | Azure client ID |
| `ARM_CLIENT_SECRET` | Azure client secret |
| `ARM_TENANT_ID` | Azure tenant ID |

**Note:** GitHub Actions secrets and Codespaces secrets are stored separately. You need to configure both, but you can use the same values.

### 3. AWS OIDC Setup (Optional but Recommended)

For secure GitHub Actions authentication with AWS without long-lived credentials, set up OIDC (OpenID Connect). This eliminates the need to store AWS access keys in GitHub Secrets.

**See detailed setup instructions:** [infra/aws/README.md](infra/aws/README.md)

**Benefits:**
- ✅ No AWS access keys stored in GitHub Secrets
- ✅ Short-lived tokens that expire automatically
- ✅ Improved security posture
- ✅ Recommended by AWS and GitHub

## Snowflake Object Organization

Scripts are organized by execution order:

1. **00_account**: Resource monitors, network policies
2. **01_security**: Roles, users, grants
3. **02_warehouses**: Virtual warehouses
4. **03_databases**: Database creation
5. **04_storage**: Storage integrations and external stages
6. **05_schemas**: Tables, views, streams
7. **06_pipes**: Snowpipe for automated ingestion
8. **07_tasks**: Scheduled tasks
9. **08_functions**: User-defined functions
10. **09_procedures**: Stored procedures

## Sample Implementation

The repository includes sample implementations:

- **Warehouse**: `COMPUTE_WH` (small, auto-suspend)
- **Database**: `RAW_DB` with sales, marketing, finance schemas
- **Tables**: 
  - `customer_orders` - Order transactions
  - `customer_master` - Customer data
  - `product_catalog` - Product information

## Multi-Cloud Support

### Current Status

- ✅ **AWS**: Fully implemented (S3, IAM, storage integrations)
- 🚧 **GCP**: Infrastructure ready, enable with `ENABLE_GCP=true`
- 🚧 **Azure**: Infrastructure ready, enable with `ENABLE_AZURE=true`

### Enabling Cloud Providers

#### For GitHub Actions (CI/CD)

Set these variables in **Settings → Secrets and variables → Actions → Variables**:

```
ENABLE_AWS = true    # Enable AWS S3 + IAM
ENABLE_GCP = false   # Enable GCP GCS + Service Account
ENABLE_AZURE = false # Enable Azure Blob + Managed Identity
```

#### For Terraform (Local/Codespaces)

Edit `infra/snowflake/tf/terraform.tfvars`:

```hcl
# Enable/disable cloud providers
enable_aws   = true   # AWS S3
enable_gcp   = false  # GCP GCS
enable_azure = false  # Azure Blob
```

Or set environment variables:

```bash
export TF_VAR_enable_aws=true
export TF_VAR_enable_gcp=false
export TF_VAR_enable_azure=false
```

### What Gets Created Per Cloud

#### AWS (when ENABLE_AWS = true)
- ✅ S3 Bucket for data storage
- ✅ IAM Role for Snowflake access
- ✅ Bucket policy and encryption
- ✅ Snowflake storage integration
- ✅ External stage

#### GCP (when ENABLE_GCP = true)
- ✅ GCS Bucket for data storage
- ✅ Service Account for Snowflake access
- ✅ IAM bindings
- ✅ Snowflake storage integration
- ✅ External stage

#### Azure (when ENABLE_AZURE = true)
- ✅ Blob Storage for data storage
- ✅ Managed Identity for Snowflake access
- ✅ Storage account and container
- ✅ Snowflake storage integration
- ✅ External stage

### Adding New Cloud Providers

1. Set `ENABLE_<CLOUD>=true` in GitHub variables
2. Add cloud-specific secrets (credentials)
3. Configure JSON input files in `infra/snowflake/tf/input-jsons/`
4. Run workflow or `terraform apply`

**See detailed guide:** [infra/snowflake/tf/README.md](infra/snowflake/tf/README.md)

## GitHub Actions Workflow

The deployment workflow (`snowflake-deploy.yaml`) automatically:

- Discovers all SQL files in the repository
- Deploys them in dependency order
- Runs files in parallel within each stage
- Uses the reusable action: `subhamay-bhattacharyya-gha/snowflake-run-ddl-action`

**Triggers**:
- Push to `main` or `develop` branches (when `snowflake/**` files change)
- Pull requests to `main` or `develop`
- Manual workflow dispatch

## Best Practices

### Migration Tracking

By default, the action tracks which scripts have been applied using a migrations table. This enables:

- **Idempotent execution**: Scripts are only run once (based on path + checksum)
- **Change detection**: If a script's content changes, it will be re-run
- **Audit trail**: Complete history of what was applied, when, and by whom

#### Migration Table Schema

The default table `UTIL_DB.UTIL_SCHEMA.DDL_MIGRATION_HISTORY` contains:

- `script_name` - Filename of the script
- `script_path` - Full path to the script
- `checksum` - SHA-256 hash of the script content
- `applied_at` - Timestamp when applied
- `status` - SUCCESS or FAILED
- `error_message` - Error details if failed
- `run_id` - GitHub Actions run ID
- `actor` - GitHub user who triggered the run

#### Baseline Mode

Use baseline mode to mark existing scripts as applied without executing them. This is useful when:

- Adopting this action in an existing environment
- Scripts have already been manually applied
- You want to start tracking from a known state

To enable baseline mode in the workflow:

```yaml
- name: Deploy with baseline
  uses: subhamay-bhattacharyya-gha/snowflake-run-ddl-action@v1
  with:
    baseline: true
    # ... other parameters
```

#### Disabling Migration Tracking

To run scripts without tracking (not recommended for production):

```yaml
- name: Deploy without tracking
  uses: subhamay-bhattacharyya-gha/snowflake-run-ddl-action@v1
  with:
    track_migrations: false
    # ... other parameters
```

### SQL Scripts
- Use `CREATE OR REPLACE` or `CREATE IF NOT EXISTS` for idempotency
- Add meaningful comments to all objects
- Number files for execution order (01_, 02_, etc.)
- Test in dev before promoting to staging/prod

### Security
- Never commit credentials or private keys
- Use service accounts for automation
- Implement least privilege access
- Rotate keys regularly

### Infrastructure
- Use remote state storage for Terraform
- Enable state locking
- Tag all resources consistently
- Use separate environments (dev/staging/prod)

## Documentation

- [Infrastructure Setup](infra/README.md)
- [Snowflake DDL Scripts](snowflake/README.md)
- [GitHub Actions Setup](.github/SETUP.md)
- [Deployment Scripts](snowflake/scripts/README.md)

## Contributing

1. Create a feature branch from `main`
2. Make your changes
3. Test in dev environment
4. Create a pull request with description
5. Wait for approval and automated deployment

See [CONTRIBUTING.md](CONTRIBUTING.md) for detailed guidelines.

## License

MIT License - See [LICENSE](LICENSE) for details.

## Support

For issues and questions:
- Open an issue in this repository
- Check existing documentation in the `docs/` folder
- Review [Snowflake documentation](https://docs.snowflake.com/)

## Roadmap

- [ ] Complete Azure implementation
- [ ] Complete GCP implementation
- [ ] Add data quality checks
- [ ] Implement dbt integration
- [ ] Add monitoring and alerting
- [ ] Create CI/CD for data pipelines