# ============================================================================
# Local Values
# ============================================================================

locals {
  # -------------------------------------------------------------------------
  # Snowflake Core Resources (from JSON files)
  # -------------------------------------------------------------------------

  snowflake_core_config = jsondecode(file("${path.module}/input-jsons/snowflake-core-objects.json"))
  warehouses            = local.snowflake_core_config["warehouses"]
  databases             = local.snowflake_core_config["databases"]
}
