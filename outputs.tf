output "manager_public_ips" {
  value = "${module.docker-manager.public_ips}"
}

output "worker_public_ips" {
  value = "${module.docker-worker.public_ips}"
}

output "dtr_public_ips" {
  value = "${module.docker-dtr.public_ips}"
}

output "minio_address" {
  value = "${module.minio.public_ip}"
}
