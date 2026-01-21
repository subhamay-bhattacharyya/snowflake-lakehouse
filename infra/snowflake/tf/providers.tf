# ============================================================================
# Terraform and Provider Configuration
# ============================================================================

terraform {
  required_version = ">= 1.0"

  required_providers {
    snowflake = {
      source  = "snowflakedb/snowflake"
      version = "~> 0.98"
    }
  }
}

# ============================================================================
# Snowflake Provider Configuration
# ============================================================================
# Authentication: Uses private key authentication (passkey)
# The private key should be in PEM format without encryption
