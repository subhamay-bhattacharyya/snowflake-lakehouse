# ============================================================================
# Azure Infrastructure Outputs
# ============================================================================

output "resource_group_name" {
  description = "Name of the resource group"
  value       = azurerm_resource_group.main.name
}

output "raw_data_storage_account_name" {
  description = "Name of the raw data storage account"
  value       = azurerm_storage_account.raw_data.name
}

output "raw_data_container_name" {
  description = "Name of the raw data container"
  value       = azurerm_storage_container.raw_data.name
}

output "processed_data_storage_account_name" {
  description = "Name of the processed data storage account"
  value       = azurerm_storage_account.processed_data.name
}

output "processed_data_container_name" {
  description = "Name of the processed data container"
  value       = azurerm_storage_container.processed_data.name
}

output "snowflake_identity_id" {
  description = "ID of the managed identity for Snowflake"
  value       = azurerm_user_assigned_identity.snowflake.id
}
