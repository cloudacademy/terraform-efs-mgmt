output "efs_filesystem_id" {
  value = module.efs.file_system_id
}

output "efs_filesystem_fqdn" {
  value = module.efs.file_system_fqdn
}

output "instance1_public_ip" {
  value = aws_instance.instance_1.public_ip
}

output "instance2_public_ip" {
  value = aws_instance.instance_2.public_ip
}
