# ============================================================================
# Terraform Backend Configuration
# ============================================================================

terraform {
  backend "s3" {
    # Configure these values in backend config file or via CLI
    # bucket         = "your-terraform-state-bucket"
    # key            = "snowflake-lakehouse/aws/terraform.tfstate"
    # region         = "us-east-1"
    # encrypt        = true
    # dynamodb_table = "terraform-state-lock"
  }
}
