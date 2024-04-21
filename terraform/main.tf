locals {
  efs_run_preference = "prod"
}

module "kms" {
  source = "./modules/kms"

  kms_key_alias       = join("", [var.kms_key_alias, local.efs_run_preference])
  kms_key_description = "Key for EFS"
}

module "efs" {
  source = "./modules/efs"

  kms_key_arn            = module.kms.kms_key_arn
  aws_account_id         = var.aws_account_id
  CORE_BACKUPS_RETENTION = "NOBACKUP"

  # Access Points Settings
  posix_access_point_config = {
    posix_user_gid = "1001"
    posix_user_uid = "1001"
  }

  root_access_point_config = {
    path        = "/efs-tfe"
    owner_gid   = "1001"
    owner_uid   = "1001"
    permissions = "750"
  }
}
