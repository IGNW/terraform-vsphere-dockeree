provider "vsphere" {
  version              = "1.9.1"
  vsphere_server       = "${var.vsphere_server}"
  user                 = "${var.vsphere_user}"
  password             = "${var.vsphere_password}"
  allow_unverified_ssl = true
}

resource "random_id" "consul_secret" {
  byte_length = 16
}

module "docker-manager" {
  source                  = "modules/dockeree-node"

  node_type               = "mgr"
  environment             = "${var.environment}"

  vsphere_datacenter      = "${var.vsphere_datacenter}"
  vsphere_datastore       = "${var.vsphere_datastore}"
  vsphere_compute_cluster = "${var.vsphere_compute_cluster}"
  vsphere_network         = "${var.vsphere_network}"
  vsphere_folder          = "${var.vsphere_folder}"

  vm_template             = "${var.vm_template}"
  ssh_username            = "${var.ssh_username}"
  ssh_password            = "${var.ssh_password}"
  domain                  = "${var.domain}"
  node_vcpu               = "${var.manager_vcpu}"
  node_memory             = "${var.manager_memory_mb}"
  root_volume_size        = "${var.manager_root_volume_size}"
  ucp_admin_username      = "${var.ucp_admin_username}"
  ucp_admin_password      = "${var.ucp_admin_password}"

  node_count              = "${var.manager_node_count}"
  ucp_version             = "${var.ucp_version}"
  consul_version          = "${var.consul_version}"
}

module "docker-worker" {
  source                  = "modules/dockeree-node"

  node_type               = "wrk"
  environment             = "${var.environment}"

  vsphere_datacenter      = "${var.vsphere_datacenter}"
  vsphere_datastore       = "${var.vsphere_datastore}"
  vsphere_compute_cluster = "${var.vsphere_compute_cluster}"
  vsphere_network         = "${var.vsphere_network}"
  vsphere_folder          = "${var.vsphere_folder}"

  vm_template             = "${var.vm_template}"
  ssh_username            = "${var.ssh_username}"
  ssh_password            = "${var.ssh_password}"
  domain                  = "${var.domain}"
  node_vcpu               = "${var.worker_vcpu}"
  node_memory             = "${var.worker_memory_mb}"
  root_volume_size        = "${var.worker_root_volume_size}"
  ucp_admin_username      = "${var.ucp_admin_username}"
  ucp_admin_password      = "${var.ucp_admin_password}"

  node_count              = "${var.worker_node_count}"
  consul_version          = "${var.consul_version}"
}

# Docker Trusted Registry
module "docker-dtr" {
  source                  = "modules/dockeree-node"
  node_type               = "dtr"
  environment             = "${var.environment}"

  vsphere_datacenter      = "${var.vsphere_datacenter}"
  vsphere_datastore       = "${var.vsphere_datastore}"
  vsphere_compute_cluster = "${var.vsphere_compute_cluster}"
  vsphere_network         = "${var.vsphere_network}"
  vsphere_folder          = "${var.vsphere_folder}"

  vm_template             = "${var.vm_template}"
  ssh_username            = "${var.ssh_username}"
  ssh_password            = "${var.ssh_password}"
  domain                  = "${var.domain}"
  node_vcpu               = "${var.dtr_vcpu}"
  node_memory             = "${var.dtr_memory_mb}"
  root_volume_size        = "${var.dtr_root_volume_size}"
  ucp_admin_username      = "${var.ucp_admin_username}"
  ucp_admin_password      = "${var.ucp_admin_password}"

  minio_endpoint          = "${module.minio.minio_endpoint}"
  minio_access_key        = "${module.minio.access_key}"
  minio_secret_key        = "${module.minio.secret_key}"

  node_count              = "${var.dtr_node_count}"
  dtr_version             = "${var.dtr_version}"
  consul_version          = "${var.consul_version}"
}

# Run the scripts to initialize the Docker EE cluster

module "manager-init" {
  source = "github.com/IGNW/terraform-ssh-dockeree-init"

  node_count         = "${var.manager_node_count}"
  public_ips         = "${module.docker-manager.node_ips}"
  private_ips        = "${module.docker-manager.node_ips}"
  resource_ids       = "${module.docker-manager.resource_ids}"
  node_type          = "mgr"
  ssh_username       = "${var.ssh_username}"
  ssh_password       = "${var.ssh_password}"
  ucp_admin_username = "${var.ucp_admin_username}"
  ucp_admin_password = "${var.ucp_admin_password}"
  ucp_url            = "${module.docker-manager.node_ips[0]}"
  ucp_version        = "${var.ucp_version}"
  consul_secret      = "${random_id.consul_secret.b64_std}"
  dtr_url            = "${module.docker-dtr.node_ips[0]}"
  manager_ip         = "${module.docker-manager.node_ips[0]}"
}

module "worker-init" {
  source = "github.com/IGNW/terraform-ssh-dockeree-init"

  node_count         = "${var.worker_node_count}"
  public_ips         = "${module.docker-manager.node_ips}"
  private_ips         = "${module.docker-manager.node_ips}"
  resource_ids       = "${module.docker-worker.resource_ids}"
  node_type          = "wrk"
  ssh_username       = "${var.ssh_username}"
  ssh_password       = "${var.ssh_password}"
  ucp_url            = "${module.docker-manager.node_ips[0]}"
  consul_secret      = "${random_id.consul_secret.b64_std}"
  dtr_url            = "${module.docker-dtr.node_ips[0]}"
  manager_ip         = "${module.docker-manager.node_ips[0]}"
}

module "dtr-init" {
  source = "github.com/IGNW/terraform-ssh-dockeree-init"

  node_count         = "${var.dtr_node_count}"
  public_ips         = "${module.docker-manager.node_ips}"
  private_ips         = "${module.docker-manager.node_ips}"
  resource_ids       = "${module.docker-dtr.resource_ids}"
  node_type          = "dtr"
  ssh_username       = "${var.ssh_username}"
  ssh_password       = "${var.ssh_password}"
  ucp_url            = "${module.docker-manager.node_ips[0]}"
  consul_secret      = "${random_id.consul_secret.b64_std}"
  dtr_url            = "${module.docker-dtr.node_ips[0]}"
  manager_ip         = "${module.docker-manager.node_ips[0]}"
}

module "minio" {
  source                  = "modules/docker-minio"
  environment             = "${var.environment}"

  vsphere_datacenter      = "${var.vsphere_datacenter}"
  vsphere_datastore       = "${var.vsphere_datastore}"
  vsphere_compute_cluster = "${var.vsphere_compute_cluster}"
  vsphere_network         = "${var.vsphere_network}"
  vsphere_folder          = "${var.vsphere_folder}"

  vm_template             = "${var.vm_template}"
  ssh_username            = "${var.ssh_username}"
  ssh_password            = "${var.ssh_password}"
  domain                  = "${var.domain}"
  node_vcpu               = "${var.minio_vcpu}"
  node_memory             = "${var.minio_memory_mb}"
  root_volume_size        = "${var.minio_root_volume_size}"
  dtr_storage_host        = "${var.dtr_storage_host}"
  dtr_storage_path        = "${var.dtr_storage_path}"
  minio_version           = "${var.minio_version}"
}
