# ============================================================================
# Local Values
# ============================================================================

locals {
  # -------------------------------------------------------------------------
  # Snowflake Core Resources (from JSON files)
  # -------------------------------------------------------------------------

  snowflake_core_config = jsondecode(file("${path.module}/input-jsons/snowflake-core-objects.json"))

  # Add prefix to warehouse names
  warehouses = {
    for key, wh in local.snowflake_core_config["warehouses"] : key => merge(wh, {
      name = var.object_prefix != "" ? "${var.object_prefix}_${wh.name}" : wh.name
    })
  }

  # Add prefix to database names
  databases = {
    for key, db in local.snowflake_core_config["databases"] : key => merge(db, {
      name = var.object_prefix != "" ? "${var.object_prefix}_${db.name}" : db.name
    })
  }
}
