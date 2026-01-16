# ============================================================================
# Terraform Backend Configuration
# ============================================================================

terraform {
  backend "gcs" {
    # Configure these values in backend config file or via CLI
    # bucket = "your-terraform-state-bucket"
    # prefix = "snowflake-lakehouse/gcp"
  }
}
