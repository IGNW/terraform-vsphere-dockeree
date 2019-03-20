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
  vsphere_cluster         = "${var.manager_vsphere_cluster}"
  vsphere_network         = "${var.manager_vsphere_network}"
  vsphere_folder          = "${var.vsphere_folder}"

  vm_template             = "${var.vm_template}"
  ssh_username            = "${var.ssh_username}"
  ssh_password            = "${var.ssh_password}"
  domain                  = "${var.domain}"
  node_vcpu               = "${var.manager_vcpu}"
  node_memory             = "${var.manager_memory_mb}"
  root_volume_size        = "${var.manager_root_volume_size}"
  thin_provisioned        = "${var.thin_provisioned}"
  eagerly_scrub           = "${var.eagerly_scrub}"
  scsi_type               = "${var.scsi_type}"
  ucp_admin_username      = "${var.ucp_admin_username}"
  ucp_admin_password      = "${var.ucp_admin_password}"

  node_count              = "${var.manager_node_count}"
  ucp_version             = "${var.ucp_version}"
  consul_version          = "${var.consul_version}"
  script_path             = "${var.script_path}"
}

module "docker-worker-a" {
  source                  = "modules/dockeree-node"

  node_type               = "wrk"
  environment             = "${var.environment}-${var.worker_a_label}"

  vsphere_datacenter      = "${var.vsphere_datacenter}"
  vsphere_datastore       = "${var.vsphere_datastore}"
  vsphere_cluster         = "${var.worker_a_vsphere_cluster}"
  vsphere_network         = "${var.worker_a_vsphere_network}"
  vsphere_folder          = "${var.vsphere_folder}"

  vm_template             = "${var.vm_template}"
  ssh_username            = "${var.ssh_username}"
  ssh_password            = "${var.ssh_password}"
  domain                  = "${var.domain}"
  node_vcpu               = "${var.worker_vcpu}"
  node_memory             = "${var.worker_memory_mb}"
  root_volume_size        = "${var.worker_root_volume_size}"
  thin_provisioned        = "${var.thin_provisioned}"
  eagerly_scrub           = "${var.eagerly_scrub}"
  scsi_type               = "${var.scsi_type}"
  ucp_admin_username      = "${var.ucp_admin_username}"
  ucp_admin_password      = "${var.ucp_admin_password}"

  node_count              = "${var.worker_a_node_count}"
  consul_version          = "${var.consul_version}"
  script_path             = "${var.script_path}"
}

module "docker-worker-b" {
  source                  = "modules/dockeree-node"

  node_type               = "wrk"
  environment             = "${var.environment}-${var.worker_b_label}"

  vsphere_datacenter      = "${var.vsphere_datacenter}"
  vsphere_datastore       = "${var.vsphere_datastore}"
  vsphere_cluster         = "${var.worker_b_vsphere_cluster}"
  vsphere_network         = "${var.worker_b_vsphere_network}"
  vsphere_folder          = "${var.vsphere_folder}"

  vm_template             = "${var.vm_template}"
  ssh_username            = "${var.ssh_username}"
  ssh_password            = "${var.ssh_password}"
  domain                  = "${var.domain}"
  node_vcpu               = "${var.worker_vcpu}"
  node_memory             = "${var.worker_memory_mb}"
  root_volume_size        = "${var.worker_root_volume_size}"
  thin_provisioned         = "${var.thin_provisioned}"
  eagerly_scrub           = "${var.eagerly_scrub}"
  scsi_type               = "${var.scsi_type}"
  ucp_admin_username      = "${var.ucp_admin_username}"
  ucp_admin_password      = "${var.ucp_admin_password}"

  node_count              = "${var.worker_b_node_count}"
  consul_version          = "${var.consul_version}"
  script_path             = "${var.script_path}"
}



# Docker Trusted Registry
module "docker-dtr" {
  source                  = "modules/dockeree-node"
  node_type               = "dtr"
  environment             = "${var.environment}"

  vsphere_datacenter      = "${var.vsphere_datacenter}"
  vsphere_datastore       = "${var.vsphere_datastore}"
  vsphere_cluster         = "${var.manager_vsphere_cluster}"
  vsphere_network         = "${var.manager_vsphere_network}"
  vsphere_folder          = "${var.vsphere_folder}"

  vm_template             = "${var.vm_template}"
  ssh_username            = "${var.ssh_username}"
  ssh_password            = "${var.ssh_password}"
  domain                  = "${var.domain}"
  node_vcpu               = "${var.dtr_vcpu}"
  node_memory             = "${var.dtr_memory_mb}"
  root_volume_size        = "${var.dtr_root_volume_size}"
  thin_provisioned         = "${var.thin_provisioned}"
  eagerly_scrub           = "${var.eagerly_scrub}"
  scsi_type               = "${var.scsi_type}"
  ucp_admin_username      = "${var.ucp_admin_username}"
  ucp_admin_password      = "${var.ucp_admin_password}"

  node_count              = "${var.dtr_node_count}"
  dtr_version             = "${var.dtr_version}"
  consul_version          = "${var.consul_version}"
  script_path             = "${var.script_path}"
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
  ucp_url            = "https://${module.docker-manager.node_ips[0]}"
  ucp_version        = "${var.ucp_version}"
  consul_secret      = "${random_id.consul_secret.b64_std}"
  dtr_url            = "https://${module.docker-dtr.node_ips[0]}"
  manager_ip         = "${module.docker-manager.node_ips[0]}"
  script_path        = "${var.script_path}"
}

module "worker-a-init" {
  source = "github.com/IGNW/terraform-ssh-dockeree-init"

  node_count         = "${var.worker_a_node_count}"
  public_ips         = "${module.docker-worker-a.node_ips}"
  private_ips        = "${module.docker-worker-a.node_ips}"
  resource_ids       = "${module.docker-worker-a.resource_ids}"
  node_type          = "wrk"
  ssh_username       = "${var.ssh_username}"
  ssh_password       = "${var.ssh_password}"
  ucp_url            = "https://${module.docker-manager.node_ips[0]}"
  consul_secret      = "${random_id.consul_secret.b64_std}"
  dtr_url            = "https://${module.docker-dtr.node_ips[0]}"
  manager_ip         = "${module.docker-manager.node_ips[0]}"
  script_path        = "${var.script_path}"
}

module "worker-b-init" {
  source = "github.com/IGNW/terraform-ssh-dockeree-init"

  node_count         = "${var.worker_b_node_count}"
  public_ips         = "${module.docker-worker-b.node_ips}"
  private_ips        = "${module.docker-worker-b.node_ips}"
  resource_ids       = "${module.docker-worker-b.resource_ids}"
  node_type          = "wrk"
  ssh_username       = "${var.ssh_username}"
  ssh_password       = "${var.ssh_password}"
  ucp_url            = "https://${module.docker-manager.node_ips[0]}"
  consul_secret      = "${random_id.consul_secret.b64_std}"
  dtr_url            = "https://${module.docker-dtr.node_ips[0]}"
  manager_ip         = "${module.docker-manager.node_ips[0]}"
  script_path        = "${var.script_path}"
}

module "dtr-init" {
  source = "github.com/IGNW/terraform-ssh-dockeree-init"

  node_count         = "${var.dtr_node_count}"
  public_ips         = "${module.docker-dtr.node_ips}"
  private_ips         = "${module.docker-dtr.node_ips}"
  resource_ids       = "${module.docker-dtr.resource_ids}"
  node_type          = "dtr"
  ssh_username       = "${var.ssh_username}"
  ssh_password       = "${var.ssh_password}"
  ucp_url            = "https://${module.docker-manager.node_ips[0]}"
  ucp_admin_username = "${var.ucp_admin_username}"
  ucp_admin_password = "${var.ucp_admin_password}"
  consul_secret      = "${random_id.consul_secret.b64_std}"
  dtr_url            = "https://${module.docker-dtr.node_ips[0]}"
  manager_ip         = "${module.docker-manager.node_ips[0]}"
  script_path        = "${var.script_path}"
  dtr_nfs_url        = "${var.dtr_nfs_url}"
}
