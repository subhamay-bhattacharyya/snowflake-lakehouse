# GitHub Actions Workflow Guide

## Overview

The CI workflow (`ci.yaml`) implements a **3-phase deployment strategy** that matches the Terraform architecture:

```
Phase 1: Snowflake Core → Phase 2: Cloud Storage → Phase 3: Integrations
```

## Workflow Phases

### Phase 1 & 2: Snowflake Core + Cloud Storage (Parallel)

**Jobs (run in parallel):**
- `snowflake-core` - Creates Snowflake warehouses, databases, schemas
- `aws-storage` - Creates AWS S3 + IAM (if enabled)
- `gcp-storage` - Creates GCP GCS + Service Account (if enabled)
- `azure-storage` - Creates Azure Blob + Managed Identity (if enabled)

**Why parallel?** Snowflake core and cloud storage are independent - they don't depend on each other.

**Runs:** All jobs start simultaneously after `start-job`

### Phase 3: Snowflake Integrations (After Phase 1 & 2)
**Job:** `snowflake-integrations`

Creates integrations between Snowflake and cloud storage:
- 🔗 Storage Integrations
- 📦 External Stages
- 🚰 Snowpipes

**Runs:** After ALL Phase 1 & 2 jobs complete successfully

## Required GitHub Variables

### Snowflake Variables
| Variable | Description | Example |
|----------|-------------|---------|
| `SNOWFLAKE_ACCOUNT` | Snowflake account identifier | `AGXUOKJ-JKC15404` |
| `SNOWFLAKE_USER` | Snowflake service account | `GH_ACTIONS_USER` |
| `SNOWFLAKE_ROLE` | Snowflake role | `SYSADMIN` |

### Cloud Provider Enablement
| Variable | Description | Values |
|----------|-------------|--------|
| `ENABLE_AWS` | Enable AWS resources | `true` or `false` |
| `ENABLE_GCP` | Enable GCP resources | `true` or `false` |
| `ENABLE_AZURE` | Enable Azure resources | `true` or `false` |

### AWS Variables (if ENABLE_AWS = true)
| Variable | Description |
|----------|-------------|
| `AWS_REGION` | AWS region |

### Terraform Variables
| Variable | Description | Default |
|----------|-------------|---------|
| `TERRAFORM_VERSION` | Terraform version | `1.9.6` |
| `TF_LINT_VER` | TFLint version | Latest |

## Required GitHub Secrets

### Snowflake Secrets
| Secret | Description |
|--------|-------------|
| `SNOWFLAKE_PRIVATE_KEY` | Private key for key-pair auth |
| `TF_TOKEN_APP_TERRAFORM_IO` | Terraform Cloud token |

### AWS Secrets (if ENABLE_AWS = true)
| Secret | Description |
|--------|-------------|
| `AWS_OIDC_ROLE_ARN` | AWS IAM role ARN for OIDC |

### GCP Secrets (if ENABLE_GCP = true)
| Secret | Description |
|--------|-------------|
| `GCP_WIF_PROVIDER` | GCP Workload Identity Federation provider |
| `GCP_SERVICE_ACCOUNT` | GCP service account email |

### Azure Secrets (if ENABLE_AZURE = true)
| Secret | Description |
|--------|-------------|
| `AZURE_CLIENT_ID` | Azure client ID |
| `AZURE_TENANT_ID` | Azure tenant ID |
| `AZURE_SUBSCRIPTION_ID` | Azure subscription ID |

## Workflow Execution Examples

### Example 1: Snowflake + AWS Only

**Variables:**
```
ENABLE_AWS = true
ENABLE_GCP = false
ENABLE_AZURE = false
```

**Execution:**
```
1. Parallel:
   - snowflake-core ✓
   - aws-storage ✓
2. snowflake-integrations ✓
```

### Example 2: Snowflake + AWS + GCP

**Variables:**
```
ENABLE_AWS = true
ENABLE_GCP = true
ENABLE_AZURE = false
```

**Execution:**
```
1. Parallel:
   - snowflake-core ✓
   - aws-storage ✓
   - gcp-storage ✓
2. snowflake-integrations ✓
```

### Example 3: All Clouds

**Variables:**
```
ENABLE_AWS = true
ENABLE_GCP = true
ENABLE_AZURE = true
```

**Execution:**
```
1. Parallel:
   - snowflake-core ✓
   - aws-storage ✓
   - gcp-storage ✓
   - azure-storage ✓
2. snowflake-integrations ✓
```

## Workflow Triggers

### Push to Main/Feature Branches
```yaml
on:
  push:
    branches:
      - 'main'
      - 'feature/**'
      - 'bug/**'
    paths:
      - infra/snowflake/tf/**
```

**Behavior:**
- Runs all phases
- Applies changes on `main` branch
- Only plans on feature branches

### Pull Requests
```yaml
on:
  pull_request:
    branches: [ main ]
    paths:
      - infra/snowflake/tf/**
```

**Behavior:**
- Runs all phases
- Only plans (no apply)
- Shows plan in PR comments

## Conditional Execution

### Phase 2 Jobs (Cloud Storage)
```yaml
if: vars.ENABLE_AWS == 'true'
```

Only runs if the cloud provider is enabled.

### Phase 3 Job (Integrations)
```yaml
if: |
  always() && 
  needs.snowflake-core.result == 'success' &&
  (needs.aws-storage.result == 'success' || needs.aws-storage.result == 'skipped')
```

Runs if:
- Phase 1 succeeded
- All enabled Phase 2 jobs succeeded or were skipped

## Terraform Targeting

### Phase 1: Snowflake Core
```bash
terraform plan -target=module.snowflake_core
```

Only plans/applies Snowflake core resources.

### Phase 2: Cloud Storage
```bash
terraform plan -target=module.aws_storage
```

Only plans/applies specific cloud provider resources.

### Phase 3: Integrations
```bash
terraform plan -target=module.snowflake_integrations
```

Only plans/applies integration resources.

## Setup Instructions

### 1. Configure GitHub Variables

Go to: **Settings → Secrets and variables → Actions → Variables**

Add:
- `SNOWFLAKE_ACCOUNT`
- `SNOWFLAKE_USER`
- `SNOWFLAKE_ROLE`
- `ENABLE_AWS` (set to `true`)
- `ENABLE_GCP` (set to `false`)
- `ENABLE_AZURE` (set to `false`)
- `AWS_REGION`

### 2. Configure GitHub Secrets

Go to: **Settings → Secrets and variables → Actions → Secrets**

Add:
- `SNOWFLAKE_PRIVATE_KEY`
- `TF_TOKEN_APP_TERRAFORM_IO`
- `AWS_OIDC_ROLE_ARN` (if using AWS)

### 3. Test the Workflow

Create a feature branch and push:
```bash
git checkout -b feature/test-workflow
git push origin feature/test-workflow
```

Check the Actions tab to see the workflow run.

## Monitoring

### View Workflow Runs
1. Go to **Actions** tab
2. Click on the workflow run
3. View each phase's logs

### Phase Status
- ✅ Green checkmark = Success
- ❌ Red X = Failed
- ⏭️ Gray dash = Skipped
- 🔵 Blue circle = Running

## Troubleshooting

### Phase 1 Fails
**Issue:** Snowflake authentication or permission error

**Fix:**
1. Verify `SNOWFLAKE_ACCOUNT`, `SNOWFLAKE_USER` variables
2. Check `SNOWFLAKE_PRIVATE_KEY` secret
3. Verify user has SYSADMIN role

### Phase 2 Skipped
**Issue:** Cloud provider not enabled

**Fix:**
Set `ENABLE_AWS`, `ENABLE_GCP`, or `ENABLE_AZURE` to `true`

### Phase 3 Fails
**Issue:** Missing cloud resources or integration error

**Fix:**
1. Verify Phase 2 completed successfully
2. Check cloud provider credentials
3. Verify storage integration configuration

### Workflow Doesn't Trigger
**Issue:** Changes not in watched paths

**Fix:**
Ensure changes are in `infra/snowflake/tf/**`

## Best Practices

### 1. Test in Feature Branches
Always test changes in feature branches before merging to main.

### 2. Review Plans
Review Terraform plans in PR comments before merging.

### 3. Enable Clouds Gradually
Start with AWS only, then add GCP/Azure when needed.

### 4. Monitor Costs
Check cloud provider costs after enabling new providers.

### 5. Use Terraform Cloud
Store state remotely for team collaboration.

## Workflow Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                    GitHub Push/PR                            │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│                    start-job                                 │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│         Phase 1 & 2: Parallel Execution                      │
│                                                              │
│  ┌──────────────────────────────────────────────────────┐  │
│  │         snowflake-core                                │  │
│  │  - Warehouses                                         │  │
│  │  - Databases                                          │  │
│  │  - Schemas                                            │  │
│  └──────────────────────────────────────────────────────┘  │
│                                                              │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐     │
│  │ aws-storage  │  │ gcp-storage  │  │azure-storage │     │
│  │ S3 + IAM     │  │ GCS + SA     │  │ Blob + MI    │     │
│  │ (if enabled) │  │ (if enabled) │  │ (if enabled) │     │
│  └──────────────┘  └──────────────┘  └──────────────┘     │
└─────────────────────────────────────────────────────────────┘
                            ↓
                  (Wait for all to complete)
                            ↓
┌─────────────────────────────────────────────────────────────┐
│         snowflake-integrations                               │
│         (After Phase 1 & 2)                                  │
│                                                              │
│  - Storage Integrations                                     │
│  - External Stages                                          │
│  - Snowpipes                                                │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│              create-release                                  │
│              (if main branch)                                │
└─────────────────────────────────────────────────────────────┘
```

## Related Documentation

- [Terraform Architecture](../infra/snowflake/tf/ARCHITECTURE.md)
- [Getting Started](../infra/snowflake/tf/GETTING_STARTED.md)
- [Migration Guide](../infra/MIGRATION_GUIDE.md)
