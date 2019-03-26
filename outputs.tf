output "ucp_url" {
  value = "https://${module.docker-manager.node_ips[0]}"
}

output "dtr_url" {
  value = "https://${module.docker-dtr.node_ips[0]}"
}

output "manager_ips" {
  value = "${module.docker-manager.node_ips}"
}

output "dtr_ips" {
  value = "${module.docker-dtr.node_ips}"
}
