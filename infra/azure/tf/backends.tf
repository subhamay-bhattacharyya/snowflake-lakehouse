# ============================================================================
# Terraform Backend Configuration
# ============================================================================

terraform {
  backend "azurerm" {
    # Configure these values in backend config file or via CLI
    # resource_group_name  = "terraform-state-rg"
    # storage_account_name = "tfstatestorage"
    # container_name       = "tfstate"
    # key                  = "snowflake-lakehouse/azure/terraform.tfstate"
  }
}
