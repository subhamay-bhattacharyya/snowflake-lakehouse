# -- infra/aws/tf/modules/s3_event_notification/versions.tf (Child Module)
# ============================================================================
# S3 Event Notification Module - Provider Requirements
# ============================================================================

terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0"
    }
  }
}
