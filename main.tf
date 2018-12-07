provider "vsphere" {
  version              = "1.9.0"
  vsphere_server       = "${var.vsphere_server}"
  user                 = "${var.vsphere_user}"
  password             = "${var.vsphere_password}"
  allow_unverified_ssl = true
}

resource "random_id" "consul_secret" {
  byte_length = 16
}

# We create one manager node first so that we can know its IP address
module "docker-manager-primary" {
  source                  = "modules/dockeree-node"

  node_type               = "mgr"
  environment             = "${var.environment}"

  vsphere_datacenter      = "${var.vsphere_datacenter}"
  vsphere_datastore       = "${var.vsphere_datastore}"
  vsphere_compute_cluster = "${var.vsphere_compute_cluster}"
  vsphere_network         = "${var.vsphere_network}"
  vsphere_folder          = "${var.vsphere_folder}"

  disk_template           = "${var.vm_template}"
  terraform_password      = "${var.terraform_password}"
  domain                  = "${var.domain}"
  node_vcpu               = "${var.manager_vcpu}"
  node_memory             = "${var.manager_memory_mb}"
  root_volume_size        = "${var.manager_root_volume_size}"
  consul_secret           = "${random_id.consul_secret.b64_std}"
  ucp_admin_username      = "${var.ucp_admin_username}"
  ucp_admin_password      = "${var.ucp_admin_password}"
  node_count              = "1"
}

module "docker-manager" {
  source                  = "modules/dockeree-node"

  node_type               = "mgr"
  environment             = "${var.environment}"
  start_id                = 1
  primary_manager_ip      = "${ module.docker-manager-primary.public_ips[0]}"

  vsphere_datacenter      = "${var.vsphere_datacenter}"
  vsphere_datastore       = "${var.vsphere_datastore}"
  vsphere_compute_cluster = "${var.vsphere_compute_cluster}"
  vsphere_network         = "${var.vsphere_network}"
  vsphere_folder          = "${var.vsphere_folder}"

  disk_template           = "${var.vm_template}"
  terraform_password      = "${var.terraform_password}"
  domain                  = "${var.domain}"
  node_vcpu               = "${var.manager_vcpu}"
  node_memory             = "${var.manager_memory_mb}"
  root_volume_size        = "${var.manager_root_volume_size}"
  consul_secret           = "${random_id.consul_secret.b64_std}"
  ucp_admin_username      = "${var.ucp_admin_username}"
  ucp_admin_password      = "${var.ucp_admin_password}"
  # ucp_dns_name          = "${var.ucp_dns_name}"

  node_count              = "${var.manager_node_count - 1}"
}

module "docker-worker" {
  source                  = "modules/dockeree-node"

  node_type               = "wrk"
  environment             = "${var.environment}"
  primary_manager_ip      = "${ module.docker-manager-primary.public_ips[0]}"

  vsphere_datacenter      = "${var.vsphere_datacenter}"
  vsphere_datastore       = "${var.vsphere_datastore}"
  vsphere_compute_cluster = "${var.vsphere_compute_cluster}"
  vsphere_network         = "${var.vsphere_network}"
  vsphere_folder          = "${var.vsphere_folder}"

  disk_template           = "${var.vm_template}"
  terraform_password      = "${var.terraform_password}"
  domain                  = "${var.domain}"
  node_vcpu               = "${var.worker_vcpu}"
  node_memory             = "${var.worker_memory_mb}"
  root_volume_size        = "${var.worker_root_volume_size}"
  consul_secret           = "${random_id.consul_secret.b64_std}"
  ucp_admin_username      = "${var.ucp_admin_username}"
  ucp_admin_password      = "${var.ucp_admin_password}"

  node_count              = "${var.worker_node_count}"
}

# Docker Trusted Registry
module "docker-dtr" {
  source                  = "modules/dockeree-node"
  node_type               = "dtr"
  environment             = "${var.environment}"
  primary_manager_ip      = "${ module.docker-manager-primary.public_ips[0]}"

  vsphere_datacenter      = "${var.vsphere_datacenter}"
  vsphere_datastore       = "${var.vsphere_datastore}"
  vsphere_compute_cluster = "${var.vsphere_compute_cluster}"
  vsphere_network         = "${var.vsphere_network}"
  vsphere_folder          = "${var.vsphere_folder}"

  disk_template           = "${var.vm_template}"
  terraform_password      = "${var.terraform_password}"
  domain                  = "${var.domain}"
  node_vcpu               = "${var.dtr_vcpu}"
  node_memory             = "${var.dtr_memory_mb}"
  root_volume_size        = "${var.dtr_root_volume_size}"
  consul_secret           = "${random_id.consul_secret.b64_std}"
  ucp_admin_username      = "${var.ucp_admin_username}"
  ucp_admin_password      = "${var.ucp_admin_password}"
  # ucp_dns_name            = "${var.ucp_dns_name}"
  # dtr_dns_name            = "${var.dtr_dns_name}"

   minio_endpoint          = "${module.minio.minio_endpoint}"
   minio_access_key        = "${module.minio.access_key}"
   minio_secret_key        = "${module.minio.secret_key}"

   node_count              = "${var.dtr_node_count}"
}

module "minio" {
  source                  = "modules/docker-minio"
  environment             = "${var.environment}"

  vsphere_datacenter      = "${var.vsphere_datacenter}"
  vsphere_datastore       = "${var.vsphere_datastore}"
  vsphere_compute_cluster = "${var.vsphere_compute_cluster}"
  vsphere_network         = "${var.vsphere_network}"
  vsphere_folder          = "${var.vsphere_folder}"

  disk_template           = "${var.vm_template}"
  terraform_password      = "${var.terraform_password}"
  domain                  = "${var.domain}"
  node_vcpu               = "${var.minio_vcpu}"
  node_memory             = "${var.minio_memory_mb}"
  root_volume_size        = "${var.minio_root_volume_size}"
  consul_secret           = "${random_id.consul_secret.b64_std}"
  dtr_storage_host        = "${var.dtr_storage_host}"
  dtr_storage_path        = "${var.dtr_storage_path}"
}
