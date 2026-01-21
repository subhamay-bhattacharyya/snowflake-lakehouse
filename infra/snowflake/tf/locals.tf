# ============================================================================
# Local Values
# ============================================================================

data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

locals {
  # -------------------------------------------------------------------------
  # Snowflake Core Resources (from JSON files)
  # -------------------------------------------------------------------------
  
  snowflake_core_config = jsondecode(file("${path.module}/input-jsons/snowflake-core-objects.json"))
  warehouses            = local.snowflake_core_config["warehouses"]
  databases             = local.snowflake_core_config["databases"]

  # -------------------------------------------------------------------------
  # Snowflake Integrations (from JSON files)
  # -------------------------------------------------------------------------
  
  stages_config = jsondecode(file("${path.module}/input-jsons/stages.json"))
  stages        = local.stages_config["stages"]
}
