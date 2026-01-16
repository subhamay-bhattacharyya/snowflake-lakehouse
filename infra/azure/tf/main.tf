# ============================================================================
# Azure Infrastructure for Snowflake Lakehouse
# Description: Azure Storage, managed identities, and other Azure resources
# ============================================================================

terraform {
  required_version = ">= 1.0"
  
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

# Resource group
resource "azurerm_resource_group" "main" {
  name     = "${var.project_name}-${var.environment}-rg"
  location = var.azure_region
  
  tags = merge(
    var.tags,
    {
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  )
}

# Storage account for raw data
resource "azurerm_storage_account" "raw_data" {
  name                     = "${replace(var.project_name, "-", "")}raw${var.environment}"
  resource_group_name      = azurerm_resource_group.main.name
  location                 = azurerm_resource_group.main.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "StorageV2"
  is_hns_enabled           = true  # Enable hierarchical namespace for Data Lake
  
  blob_properties {
    versioning_enabled = true
  }
  
  tags = merge(
    var.tags,
    {
      Purpose = "raw-data"
    }
  )
}

# Container for raw data
resource "azurerm_storage_container" "raw_data" {
  name                  = "raw-data"
  storage_account_name  = azurerm_storage_account.raw_data.name
  container_access_type = "private"
}

# Storage account for processed data
resource "azurerm_storage_account" "processed_data" {
  name                     = "${replace(var.project_name, "-", "")}proc${var.environment}"
  resource_group_name      = azurerm_resource_group.main.name
  location                 = azurerm_resource_group.main.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "StorageV2"
  is_hns_enabled           = true
  
  blob_properties {
    versioning_enabled = true
  }
  
  tags = merge(
    var.tags,
    {
      Purpose = "processed-data"
    }
  )
}

# Container for processed data
resource "azurerm_storage_container" "processed_data" {
  name                  = "processed-data"
  storage_account_name  = azurerm_storage_account.processed_data.name
  container_access_type = "private"
}

# Managed identity for Snowflake (placeholder)
# Note: Configure this based on your Snowflake Azure integration requirements
resource "azurerm_user_assigned_identity" "snowflake" {
  name                = "${var.project_name}-snowflake-identity-${var.environment}"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  
  tags = var.tags
}
