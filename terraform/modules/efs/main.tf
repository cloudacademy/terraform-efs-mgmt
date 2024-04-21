resource "aws_efs_file_system" "file_system" {
  encrypted        = true
  kms_key_id       = var.kms_key_arn
  performance_mode = "generalPurpose"
  throughput_mode  = "bursting"
  lifecycle_policy {
    transition_to_ia = "AFTER_30_DAYS"
  }
  tags = {
    Name   = "efs-fs1"
    Backup = var.CORE_BACKUPS_RETENTION
  }
}

resource "aws_efs_access_point" "access_point" {
  file_system_id = aws_efs_file_system.file_system.id

  root_directory {
    path = var.root_access_point_config.path

    creation_info {
      owner_uid   = var.root_access_point_config.owner_uid
      owner_gid   = var.root_access_point_config.owner_gid
      permissions = var.root_access_point_config.permissions
    }
  }

  posix_user {
    uid = var.posix_access_point_config.posix_user_uid
    gid = var.posix_access_point_config.posix_user_gid
  }

  tags = {
    Name = "EFS-Access-Point-01"
    Env  = "Prod"
  }
}
