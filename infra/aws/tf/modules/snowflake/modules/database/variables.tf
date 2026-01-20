# --- Snowflake Database Variables ---

variable "name" {
  description = "Name of the database"
  type        = string
}

variable "comment" {
  description = "Comment for the database"
  type        = string
  default     = ""
}

variable "schemas" {
  description = "List of schemas to create in the database"
  type = list(object({
    name    = string
    comment = optional(string, "")
  }))
  default = []
}
