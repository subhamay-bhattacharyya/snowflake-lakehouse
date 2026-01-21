# ============================================================================
# Root Module Outputs
# ============================================================================

output "warehouses" {
  description = "Map of warehouse configurations with prefixes applied"
  value       = local.warehouses
}
