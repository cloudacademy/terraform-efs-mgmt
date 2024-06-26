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

variable "core_backups_retention" {
  description = "The retention policy for backups"
  type        = string
  default     = "NOBACKUP"
}

variable "core_backups_retention_pitr" {
  description = "The retention PITR policy for backups"
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

variable "lifecycle_policy" {
  description = "The configuration for the EFS lifecycle policy"
  type = object({
    transition_to_archive               = optional(string)
    transition_to_ia                    = optional(string)
    transition_to_primary_storage_class = optional(string)
  })
  default = null
}
