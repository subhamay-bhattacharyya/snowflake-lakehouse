# --- Snowflake Stage Variables ---

variable "name" {
  description = "Name of the stage"
  type        = string
}

variable "database" {
  description = "Database where the stage will be created"
  type        = string
}

variable "schema" {
  description = "Schema where the stage will be created"
  type        = string
}

variable "url" {
  description = "External location URL (e.g., s3://bucket/path/)"
  type        = string
}

variable "storage_integration_name" {
  description = "Name of the storage integration to use"
  type        = string
}

variable "file_format" {
  description = "File format for the stage"
  type        = string
  default     = null
}

variable "comment" {
  description = "Comment for the stage"
  type        = string
  default     = ""
}
