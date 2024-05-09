output "file_system_id" {
  value = aws_efs_file_system.file_system.id
}

output "file_system_fqdn" {
  value = aws_efs_file_system.file_system.dns_name
}
