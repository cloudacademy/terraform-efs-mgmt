resource "aws_efs_file_system" "file_system" {
  encrypted        = true
  kms_key_id       = var.kms_key_arn
  performance_mode = "generalPurpose"
  throughput_mode  = "bursting"

  dynamic "lifecycle_policy" {
    for_each = var.lifecycle_policy == null ? [] : [1]

    content {
      transition_to_ia = var.lifecycle_policy.transition_to_ia != null ? var.lifecycle_policy.transition_to_ia : null
    }
  }

  dynamic "lifecycle_policy" {
    for_each = var.lifecycle_policy == null ? [] : [1]

    content {
      transition_to_primary_storage_class = var.lifecycle_policy.transition_to_primary_storage_class != null ? var.lifecycle_policy.transition_to_primary_storage_class : null
    }
  }

  tags = {
    Name                   = "efs-fs1"
    CORE_BACKUPS_RETENTION = var.core_backups_retention
  }
}

resource "aws_efs_file_system_policy" "tls_policy" {
  file_system_id = aws_efs_file_system.file_system.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          "AWS" : "*"
        }
        Action = [
          "elasticfilesystem:ClientRootAccess",
          "elasticfilesystem:ClientWrite",
          "elasticfilesystem:ClientMount"
        ]
        Resource = aws_efs_file_system.file_system.arn
        Condition = {
          "Bool" = {
            "elasticfilesystem:AccessedViaMountTarget" = "true"
          }
        }
      },
      {
        Effect = "Deny"
        Principal = {
          "AWS" : "*"
        }
        Action = [
          "*"
        ]
        Resource = aws_efs_file_system.file_system.arn
        Condition = {
          "Bool" = {
            "aws:SecureTransport" = "false"
          }
        }
      }
    ]
  })
}

resource "aws_efs_access_point" "access_point" {
  count = var.posix_access_point_config == null || var.root_access_point_config == null ? 0 : 1

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
