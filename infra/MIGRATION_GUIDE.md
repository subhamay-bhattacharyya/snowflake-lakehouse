# Migration Guide: Old Structure → New Structure

This guide explains how to migrate from the old `infra/aws/tf/` structure to the new unified `infra/snowflake/tf/` structure.

## Why Migrate?

### Old Structure Problems
❌ Snowflake module mixed with AWS-specific code
❌ Hard to add GCP/Azure support
❌ No clear dependency order
❌ Cloud-specific logic in Snowflake modules

### New Structure Benefits
✅ Snowflake core is cloud-agnostic
✅ Easy to enable multiple cloud providers
✅ Clear 3-phase execution order
✅ Proper dependency management
✅ Parallel cloud resource creation

## Architecture Comparison

### Old Structure
```
infra/aws/tf/
├── main.tf (mixed AWS + Snowflake)
└── modules/
    ├── s3/ (AWS)
    ├── iam/ (AWS)
    └── snowflake/ (mixed with AWS logic)
```

### New Structure
```
infra/snowflake/tf/
├── main.tf (orchestration only)
└── modules/
    ├── snowflake-core/ (cloud-agnostic)
    ├── cloud-storage/
    │   ├── aws/
    │   ├── gcp/
    │   └── azure/
    └── snowflake-integrations/ (uses cloud outputs)
```

## Migration Steps

### Step 1: Copy Warehouse Configuration

```bash
# Copy warehouses.json
cp infra/aws/tf/input-jsons/warehouses.json infra/snowflake/tf/input-jsons/
```

### Step 2: Create Database Configuration

Create `infra/snowflake/tf/input-jsons/databases.json`:

```json
{
  "databases": {
    "lakehouse": {
      "name": "LAKEHOUSE",
      "comment": "Main lakehouse database",
      "schemas": [
        { "name": "RAW", "comment": "Raw data layer" },
        { "name": "STAGING", "comment": "Staging layer" },
        { "name": "ANALYTICS", "comment": "Analytics layer" }
      ]
    }
  }
}
```

### Step 3: Copy Warehouse Sub-Module

```bash
# Copy the warehouse sub-module
cp -r infra/aws/tf/modules/snowflake/modules/warehouse \
      infra/snowflake/tf/modules/snowflake-core/modules/
```

### Step 4: Copy Database Sub-Module

```bash
# Copy the database sub-module
cp -r infra/aws/tf/modules/snowflake/modules/database \
      infra/snowflake/tf/modules/snowflake-core/modules/
```

### Step 5: Update Codespaces Secrets

No changes needed! Use the same secrets as before.

### Step 6: Initialize New Configuration

```bash
cd infra/snowflake/tf
terraform init
```

### Step 7: Import Existing Resources (Optional)

If you already have resources created with the old configuration:

```bash
# Import warehouses
terraform import 'module.snowflake_core.module.warehouse["load_wh"].snowflake_warehouse.this' LOAD_WH
terraform import 'module.snowflake_core.module.warehouse["transform_wh"].snowflake_warehouse.this' TRANSFORM_WH

# Import S3 bucket
terraform import 'module.aws_storage[0].aws_s3_bucket.this' your-bucket-name

# Import IAM role
terraform import 'module.aws_storage[0].aws_iam_role.this' your-role-name
```

### Step 8: Plan and Apply

```bash
terraform plan
terraform apply
```

## Module Mapping

| Old Location | New Location | Notes |
|--------------|--------------|-------|
| `modules/snowflake/` | `modules/snowflake-core/` | Now cloud-agnostic |
| `modules/s3/` | `modules/cloud-storage/aws/` | Part of AWS module |
| `modules/iam/` | `modules/cloud-storage/aws/` | Part of AWS module |
| N/A | `modules/cloud-storage/gcp/` | New GCP support |
| N/A | `modules/cloud-storage/azure/` | New Azure support |
| N/A | `modules/snowflake-integrations/` | New integration module |

## Configuration File Mapping

| Old File | New File | Changes |
|----------|----------|---------|
| `input-jsons/warehouses.json` | `input-jsons/warehouses.json` | No changes |
| N/A | `input-jsons/databases.json` | **New file required** |
| `input-jsons/s3-bucket.json` | `input-jsons/aws-s3.json` | Renamed |
| N/A | `input-jsons/gcp-gcs.json` | New (optional) |
| N/A | `input-jsons/azure-blob.json` | New (optional) |
| N/A | `input-jsons/stages.json` | New (for Phase 3) |

## Variable Changes

### Old Variables
```hcl
# In infra/aws/tf/variables.tf
variable "aws_region" {}
variable "snowflake_account" {}
# ... AWS-specific only
```

### New Variables
```hcl
# In infra/snowflake/tf/variables.tf
variable "enable_aws" { default = true }
variable "enable_gcp" { default = false }
variable "enable_azure" { default = false }

variable "aws_region" {}
variable "gcp_region" {}
variable "azure_location" {}

variable "snowflake_account" {}
# ... Multi-cloud support
```

## Execution Order Changes

### Old Order (Sequential)
```
1. S3 Bucket
2. IAM Role
3. Snowflake Warehouses (mixed with AWS logic)
```

### New Order (Phased)
```
Phase 1: Snowflake Core
  ├── Warehouses
  └── Databases

Phase 2: Cloud Storage (Parallel)
  ├── AWS (S3 + IAM)
  ├── GCP (GCS + SA)
  └── Azure (Blob + MI)

Phase 3: Integrations
  ├── Storage Integrations
  └── External Stages
```

## Testing the Migration

### 1. Test Snowflake Core Only

```hcl
# terraform.tfvars
enable_aws   = false
enable_gcp   = false
enable_azure = false
```

```bash
terraform apply
# Should create only warehouses and databases
```

### 2. Test with AWS

```hcl
# terraform.tfvars
enable_aws   = true
enable_gcp   = false
enable_azure = false
```

```bash
terraform apply
# Should create Snowflake + AWS resources
```

### 3. Test Multi-Cloud

```hcl
# terraform.tfvars
enable_aws   = true
enable_gcp   = true
enable_azure = true
```

```bash
terraform apply
# Should create Snowflake + all cloud resources
```

## Rollback Plan

If you need to rollback to the old structure:

1. **Keep the old directory**: Don't delete `infra/aws/tf/` until migration is complete
2. **Use separate state**: New structure uses different state
3. **Test in dev first**: Migrate dev environment before production

## Common Issues

### Issue: "Module not found"

**Cause**: Sub-modules not copied

**Fix**:
```bash
cp -r infra/aws/tf/modules/snowflake/modules/* \
      infra/snowflake/tf/modules/snowflake-core/modules/
```

### Issue: "databases.json not found"

**Cause**: New required file

**Fix**: Create `infra/snowflake/tf/input-jsons/databases.json` (see Step 2)

### Issue: "Duplicate resources"

**Cause**: Both old and new configurations trying to manage same resources

**Fix**: Either:
- Import existing resources to new state
- Destroy old resources first
- Use different resource names

## Gradual Migration Approach

### Option 1: Fresh Start (Recommended for Dev)
1. Create new resources with new structure
2. Test thoroughly
3. Destroy old resources
4. Update production

### Option 2: Import Existing (Recommended for Prod)
1. Set up new structure
2. Import all existing resources
3. Verify with `terraform plan` (should show no changes)
4. Gradually add new features

### Option 3: Parallel (Safest)
1. Keep old structure running
2. Create new resources with new structure (different names)
3. Migrate data
4. Switch over
5. Destroy old resources

## Checklist

- [ ] Copy warehouses.json
- [ ] Create databases.json
- [ ] Copy warehouse sub-module
- [ ] Copy database sub-module
- [ ] Update terraform.tfvars
- [ ] Run terraform init
- [ ] Run terraform plan
- [ ] Review plan carefully
- [ ] Run terraform apply
- [ ] Verify in Snowflake
- [ ] Test integrations
- [ ] Update CI/CD pipelines
- [ ] Update documentation
- [ ] Train team on new structure

## Timeline Estimate

- **Small project** (< 10 resources): 1-2 hours
- **Medium project** (10-50 resources): 4-8 hours
- **Large project** (> 50 resources): 1-2 days

## Support

If you encounter issues:
1. Check the troubleshooting section in `infra/snowflake/tf/README.md`
2. Review Terraform plan output carefully
3. Test in dev environment first
4. Keep backups of state files

## Benefits After Migration

✅ Can enable GCP/Azure with single variable change
✅ Clear separation of concerns
✅ Easier to test individual components
✅ Better dependency management
✅ Parallel cloud resource creation
✅ Cloud-agnostic Snowflake core
✅ Easier to maintain and extend
