output "manager_ips" {
  value = "${module.docker-manager.node_ips}"
}

#output "worker_ips" {
#  value = "${module.docker-worker.node_ips}"
#}

#output "dtr_ips" {
#  value = "${module.docker-dtr.node_ips}"
#}

#output "minio_ip" {
#  value = "${module.minio.public_ip}"
#}

output "ucp_url" {
  value = "https://${module.docker-manager.node_ips[0]}"
}

#output "dtr_url" {
#  value = "https://${module.docker-dtr.node_ips[0]}"
#}
