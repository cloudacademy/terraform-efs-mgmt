# variable "version" {
#   description = "The module version"
#   type        = string
# }

variable "kms_key_arn" {
  description = "The ARN for the KMS key to encrypt the file system at rest"
  type        = string
}

variable "aws_account_id" {
  description = "The AWS account ID"
  type        = string

}

variable "CORE_BACKUPS_RETENTION" {
  description = "The retention policy for backups"
  type        = string
  default     = "NOBACKUP"
}

variable "posix_access_point_config" {
  description = "The configuration for the POSIX access point"
  type = object({
    posix_user_gid = string
    posix_user_uid = string
  })
  default = null
}

variable "root_access_point_config" {
  description = "The configuration for the root access point"
  type = object({
    path        = string
    owner_gid   = string
    owner_uid   = string
    permissions = string
  })
  default = null
}
