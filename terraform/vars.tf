variable "aws_account_id" {
  description = "The AWS account ID"
  type        = string
  default     = "111111111111"
}

variable "kms_key_alias" {
  description = "The alias for the KMS key"
  type        = string
  default     = "lab-kms-key"
}

variable "public_instance_sg_ports" {
  description = "Define the ports and protocols for instance the security group"
  type        = list(any)
  default = [
    {
      "port" : 22,
      "protocol" : "tcp"
    },
  ]
}

variable "efs_sg_ports" {
  description = "Define the ports and protocols for efs the security group"
  type        = list(any)
  default = [
    {
      "port" : 2049,
      "protocol" : "tcp"
    },
  ]
}
