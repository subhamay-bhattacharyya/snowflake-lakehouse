# ============================================================================
# Multi-Cloud Snowflake Lakehouse - Root Configuration
# ============================================================================
# This configuration orchestrates:
# 1. Snowflake core resources (warehouses, databases, schemas)
# 2. Cloud storage (AWS S3, GCP GCS, Azure Blob)
# 3. Snowflake integrations (storage integrations, external stages)
# ============================================================================

# ----------------------------------------------------------------------------
# Phase 1: Snowflake Core Resources (Cloud-agnostic)
# ----------------------------------------------------------------------------

module "snowflake_core" {
  source = "./modules/snowflake-core"

  warehouses = local.warehouses
  databases  = local.databases
}

# ----------------------------------------------------------------------------
# Phase 2: Cloud Provider Resources (Parallel execution)
# ----------------------------------------------------------------------------

# AWS Resources
module "aws_storage" {
  source = "./modules/cloud-storage/aws"
  count  = var.enable_aws ? 1 : 0

  project_name = var.project_name
  environment  = var.environment
  s3_config    = local.aws_s3_config
  tags         = var.tags
}

# GCP Resources
module "gcp_storage" {
  source = "./modules/cloud-storage/gcp"
  count  = var.enable_gcp ? 1 : 0

  project_name = var.project_name
  environment  = var.environment
  gcs_config   = local.gcp_gcs_config
}

# Azure Resources
module "azure_storage" {
  source = "./modules/cloud-storage/azure"
  count  = var.enable_azure ? 1 : 0

  project_name = var.project_name
  environment  = var.environment
  blob_config  = local.azure_blob_config
}

# ----------------------------------------------------------------------------
# Phase 3: Snowflake Integrations (Depends on Phase 1 & 2)
# ----------------------------------------------------------------------------

module "snowflake_integrations" {
  source = "./modules/snowflake-integrations"

  # Dependencies
  depends_on = [
    module.snowflake_core,
    module.aws_storage,
    module.gcp_storage,
    module.azure_storage
  ]

  # AWS Integration
  aws_storage_integration = var.enable_aws ? {
    enabled               = true
    storage_allowed_locations = [module.aws_storage[0].s3_url]
    storage_aws_role_arn  = module.aws_storage[0].iam_role_arn
  } : null

  # GCP Integration
  gcp_storage_integration = var.enable_gcp ? {
    enabled               = true
    storage_allowed_locations = [module.gcp_storage[0].gcs_url]
  } : null

  # Azure Integration
  azure_storage_integration = var.enable_azure ? {
    enabled               = true
    storage_allowed_locations = [module.azure_storage[0].blob_url]
    azure_tenant_id       = module.azure_storage[0].tenant_id
  } : null

  # External Stages
  stages = local.stages
  
  # Databases (for stage creation)
  databases = module.snowflake_core.databases
}
