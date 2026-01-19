# --- root/aws/tf/root/backend.tf ---

terraform {
  cloud {

    organization = "subhamay-bhattacharyya-projects"

    workspaces {
      name = "snowflake-datalake-aws"
    }
  }
}