# --- root/aws/tf/root/main.tf ---

module "s3" {
  source            = "./modules/s3"
  s3_static_website = local.s3_config
}