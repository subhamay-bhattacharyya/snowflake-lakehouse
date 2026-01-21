# ============================================================================
# Multi-Cloud Snowflake Lakehouse - Root Configuration
# ============================================================================
# This configuration orchestrates:
# Snowflake objects (Databases, Schemas)
# ============================================================================

# ----------------------------------------------------------------------------
# Phase 1: Snowflake Core Resources (Cloud-agnostic)
# ----------------------------------------------------------------------------

module "warehouses" {
  source = "./modules/warehouse"

  warehouses = local.warehouses
}

module "databases" {
  source = "./modules/database"

  databases = local.databases
}
