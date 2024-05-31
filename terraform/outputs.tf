output "efs_filesystem_id" {
  value = module.efs.file_system_id
}

output "efs_filesystem_fqdn" {
  value = module.efs.file_system_fqdn
}

output "customer_managed_security_group_id" {
  value = module.efs.customer_managed_security_group_id
}
