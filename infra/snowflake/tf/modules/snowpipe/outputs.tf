# ============================================================================
# Snowflake Pipe Outputs
# ============================================================================

output "snowpipe_ids" {
  description = "Map of snowpipe names to their IDs"
  value       = { for k, v in snowflake_pipe.this : k => v.id }
}

output "snowpipe_notification_channels" {
  description = "Map of snowpipe names to their notification channels"
  value       = { for k, v in snowflake_pipe.this : k => v.notification_channel }
}
