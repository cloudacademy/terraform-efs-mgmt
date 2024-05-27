resource "random_string" "kms" {
  length  = 5
  special = false
  upper   = false
}

resource "aws_kms_key" "key" {
  description             = var.kms_key_description
  key_usage               = "ENCRYPT_DECRYPT"
  deletion_window_in_days = 7
}

resource "aws_kms_alias" "alias" {
  name          = "alias/${var.kms_key_alias}-${random_string.kms.result}"
  target_key_id = aws_kms_key.key.key_id
}
