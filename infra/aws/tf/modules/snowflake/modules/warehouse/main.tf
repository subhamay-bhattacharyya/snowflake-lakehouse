# --- Snowflake Warehouse Sub-Module ---

resource "snowflake_warehouse" "this" {
  name                        = var.name
  warehouse_size              = var.warehouse_size
  auto_suspend                = var.auto_suspend
  auto_resume                 = var.auto_resume
  warehouse_type              = var.warehouse_type
  comment                     = var.comment
  enable_query_acceleration   = var.enable_query_acceleration
  min_cluster_count           = var.min_cluster_count
  max_cluster_count           = var.max_cluster_count
  scaling_policy              = var.scaling_policy
  initially_suspended         = var.initially_suspended
}
