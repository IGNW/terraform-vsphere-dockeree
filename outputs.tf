output "manager_public_ips" {
  value = "${module.docker-manager.public_ips}"
}

output "dtr_public_ips" {
  value = "${module.docker-dtr.public_ips}"
}

output "dtr_private_ips" {
  value = "${module.docker-dtr.private_ips}"
}

output "minio_address" {
  value = "${module.minio.private_ip}"
}
