# ============================================================================
# Multi-Cloud Snowflake Lakehouse - Root Configuration
# ============================================================================
# This configuration orchestrates:
# Snowflake objects (Databases, Schemas, Warehouses, File Formats, Storage Integrations, Stages)
# ============================================================================

# ----------------------------------------------------------------------------
# Phase 1: Snowflake Core Resources (Cloud-agnostic)
# ----------------------------------------------------------------------------

module "warehouses" {
  source = "./modules/warehouse"

  warehouses = [for k, v in local.warehouses : v]
}

module "databases" {
  source = "./modules/database"

  databases = [for k, v in local.databases : v]
}

module "file_formats" {
  source = "./modules/file_format"

  file_formats = local.file_formats

  depends_on = [module.databases]
}

module "storage_integrations" {
  source = "./modules/storage_integration"

  storage_integrations = local.storage_integrations

  depends_on = [module.databases]
}

module "stages" {
  source = "./modules/stage"

  stage_config = local.stages

  depends_on = [
    module.databases,
    module.storage_integrations,
    module.file_formats
  ]
}

# module "snowpipes" {
#   source = "./modules/snowpipe"

#   snowpipe_config = local.snowpipes

#   depends_on = [
#     module.databases,
#     module.stages,
#     module.file_formats
#   ]
# }
