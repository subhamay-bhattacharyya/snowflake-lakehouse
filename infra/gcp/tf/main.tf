# ============================================================================
# GCP Infrastructure for Snowflake Lakehouse
# Description: GCS buckets, IAM roles, and other GCP resources
# ============================================================================

terraform {
  required_version = ">= 1.0"
  
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

provider "google" {
  project = var.gcp_project_id
  region  = var.gcp_region
}

# GCS bucket for raw data
resource "google_storage_bucket" "raw_data" {
  name     = "${var.project_name}-raw-data-${var.environment}"
  location = var.gcp_region
  
  uniform_bucket_level_access = true
  
  versioning {
    enabled = true
  }
  
  encryption {
    default_kms_key_name = var.kms_key_name
  }
  
  labels = {
    environment = var.environment
    purpose     = "raw-data"
    managed_by  = "terraform"
  }
}

# GCS bucket for processed data
resource "google_storage_bucket" "processed_data" {
  name     = "${var.project_name}-processed-data-${var.environment}"
  location = var.gcp_region
  
  uniform_bucket_level_access = true
  
  versioning {
    enabled = true
  }
  
  encryption {
    default_kms_key_name = var.kms_key_name
  }
  
  labels = {
    environment = var.environment
    purpose     = "processed-data"
    managed_by  = "terraform"
  }
}

# Service account for Snowflake
resource "google_service_account" "snowflake_sa" {
  account_id   = "${var.project_name}-snowflake-${var.environment}"
  display_name = "Snowflake Service Account"
  description  = "Service account for Snowflake to access GCS buckets"
}

# IAM binding for raw data bucket
resource "google_storage_bucket_iam_member" "raw_data_reader" {
  bucket = google_storage_bucket.raw_data.name
  role   = "roles/storage.objectViewer"
  member = "serviceAccount:${google_service_account.snowflake_sa.email}"
}

# IAM binding for processed data bucket
resource "google_storage_bucket_iam_member" "processed_data_admin" {
  bucket = google_storage_bucket.processed_data.name
  role   = "roles/storage.objectAdmin"
  member = "serviceAccount:${google_service_account.snowflake_sa.email}"
}
