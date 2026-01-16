# ============================================================================
# GCP Infrastructure Outputs
# ============================================================================

output "raw_data_bucket_name" {
  description = "Name of the raw data GCS bucket"
  value       = google_storage_bucket.raw_data.name
}

output "raw_data_bucket_url" {
  description = "URL of the raw data GCS bucket"
  value       = google_storage_bucket.raw_data.url
}

output "processed_data_bucket_name" {
  description = "Name of the processed data GCS bucket"
  value       = google_storage_bucket.processed_data.name
}

output "processed_data_bucket_url" {
  description = "URL of the processed data GCS bucket"
  value       = google_storage_bucket.processed_data.url
}

output "snowflake_service_account_email" {
  description = "Email of the service account for Snowflake"
  value       = google_service_account.snowflake_sa.email
}
