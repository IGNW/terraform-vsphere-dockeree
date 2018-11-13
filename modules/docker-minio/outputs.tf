output "public_ip" {
  value = "${vsphere_virtual_machine.minio.0.default_ip_address}"
}

output "minio_endpoint" {
  value = "${vsphere_virtual_machine.minio.0.default_ip_address}:${local.minio_port}"
}

output "access_key" {
  value = "${random_string.minio_access_key.result}"
}

output "secret_key" {
  value = "${random_string.minio_secret_key.result}"
}
