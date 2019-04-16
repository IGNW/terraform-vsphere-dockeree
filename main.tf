provider "vsphere" {
  version              = "1.10.0"
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
  vsphere_datastore       = "${var.manager_vsphere_datastore}"
  vsphere_cluster         = "${var.manager_vsphere_cluster}"
  vsphere_network         = "${var.manager_vsphere_network}"
  vsphere_folder          = "${var.vsphere_folder}"
  vm_template             = "${var.manager_vm_template}"

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
  vsphere_datastore       = "${var.worker_a_vsphere_datastore}"
  vsphere_cluster         = "${var.worker_a_vsphere_cluster}"
  vsphere_network         = "${var.worker_a_vsphere_network}"
  vsphere_folder          = "${var.vsphere_folder}"
  vm_template             = "${var.worker_a_vm_template}"

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
  vsphere_datastore       = "${var.worker_b_vsphere_datastore}"
  vsphere_cluster         = "${var.worker_b_vsphere_cluster}"
  vsphere_network         = "${var.worker_b_vsphere_network}"
  vsphere_folder          = "${var.vsphere_folder}"
  vm_template             = "${var.worker_b_vm_template}"

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
  vsphere_datastore       = "${var.manager_vsphere_datastore}"
  vsphere_cluster         = "${var.manager_vsphere_cluster}"
  vsphere_network         = "${var.manager_vsphere_network}"
  vsphere_folder          = "${var.vsphere_folder}"
  vm_template             = "${var.manager_vm_template}"

  ssh_username            = "${var.ssh_username}"
  ssh_password            = "${var.ssh_password}"
  domain                  = "${var.domain}"
  node_vcpu               = "${var.dtr_vcpu}"
  node_memory             = "${var.dtr_memory_mb}"
  root_volume_size        = "${var.dtr_root_volume_size}"
  thin_provisioned        = "${var.thin_provisioned}"
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
  source = "github.com/IGNW/terraform-ssh-dockeree-init?ref=2.1.1"

  node_count         = "${var.manager_node_count}"
  public_ips         = "${module.docker-manager.node_ips}"
  private_ips        = "${module.docker-manager.node_ips}"
  resource_ids       = "${module.docker-manager.resource_ids}"
  node_type          = "mgr"
  ssh_username       = "${var.ssh_username}"
  ssh_password       = "${var.ssh_password}"
  ucp_admin_username = "${var.ucp_admin_username}"
  ucp_admin_password = "${var.ucp_admin_password}"
  ucp_fqdn           = "${var.ucp_fqdn}"
  ucp_version        = "${var.ucp_version}"
  consul_secret      = "${random_id.consul_secret.b64_std}"
  dockeree_license   = "${var.dockeree_license}"
  dtr_fqdn           = "${var.dtr_fqdn}"
  consul_server      = "${module.docker-manager.node_ips[0]}"
  script_path        = "${var.script_path}"
  run_init           = "${var.run_init}"
  use_custom_ssl     = "${var.use_custom_ssl}"
  ssl_ca_file        = "${var.ssl_ca_file}"
  ssl_cert_file      = "${var.ssl_cert_file}"
  ssl_key_file       = "${var.ssl_key_file}"
}

module "worker-a-init" {
  source = "github.com/IGNW/terraform-ssh-dockeree-init?ref=2.1.1"

  node_count         = "${var.worker_a_node_count}"
  public_ips         = "${module.docker-worker-a.node_ips}"
  private_ips        = "${module.docker-worker-a.node_ips}"
  resource_ids       = "${module.docker-worker-a.resource_ids}"
  node_type          = "wrk"
  ssh_username       = "${var.ssh_username}"
  ssh_password       = "${var.ssh_password}"
  ucp_fqdn           = "${var.ucp_fqdn}"
  consul_secret      = "${random_id.consul_secret.b64_std}"
  dtr_fqdn           = "${var.dtr_fqdn}"
  consul_server      = "${module.docker-manager.node_ips[0]}"
  script_path        = "${var.script_path}"
  run_init           = "${var.run_init}"
  ssl_ca_file        = "${var.ssl_ca_file}"
  ssl_cert_file      = "${var.ssl_cert_file}"
  ssl_key_file       = "${var.ssl_key_file}"
}

module "worker-b-init" {
  source = "github.com/IGNW/terraform-ssh-dockeree-init?ref=2.1.1"

  node_count         = "${var.worker_b_node_count}"
  public_ips         = "${module.docker-worker-b.node_ips}"
  private_ips        = "${module.docker-worker-b.node_ips}"
  resource_ids       = "${module.docker-worker-b.resource_ids}"
  node_type          = "wrk"
  ssh_username       = "${var.ssh_username}"
  ssh_password       = "${var.ssh_password}"
  ucp_fqdn           = "${var.ucp_fqdn}"
  consul_secret      = "${random_id.consul_secret.b64_std}"
  dtr_fqdn           = "${var.dtr_fqdn}"
  consul_server      = "${module.docker-manager.node_ips[0]}"
  script_path        = "${var.script_path}"
  run_init           = "${var.run_init}"
  ssl_ca_file        = "${var.ssl_ca_file}"
  ssl_cert_file      = "${var.ssl_cert_file}"
  ssl_key_file       = "${var.ssl_key_file}"
}

module "dtr-init" {
  source = "github.com/IGNW/terraform-ssh-dockeree-init?ref=2.1.1"

  node_count         = "${var.dtr_node_count}"
  public_ips         = "${module.docker-dtr.node_ips}"
  private_ips        = "${module.docker-dtr.node_ips}"
  resource_ids       = "${module.docker-dtr.resource_ids}"
  node_type          = "dtr"
  ssh_username       = "${var.ssh_username}"
  ssh_password       = "${var.ssh_password}"
  ucp_fqdn           = "${var.ucp_fqdn}"
  ucp_admin_username = "${var.ucp_admin_username}"
  ucp_admin_password = "${var.ucp_admin_password}"
  consul_secret      = "${random_id.consul_secret.b64_std}"
  dtr_fqdn           = "${var.dtr_fqdn}"
  consul_server      = "${module.docker-manager.node_ips[0]}"
  script_path        = "${var.script_path}"
  dtr_nfs_url        = "${var.dtr_nfs_url}"
  run_init           = "${var.run_init}"
  use_custom_ssl     = "${var.use_custom_ssl}"
  ssl_ca_file        = "${var.ssl_ca_file}"
  ssl_cert_file      = "${var.ssl_cert_file}"
  ssl_key_file       = "${var.ssl_key_file}"
}

module "nginx-update" {
  source       = "modules/nginx-updater"

  lb_count     = "${var.load_balancer_count}"
  lb_ips       = "${var.load_balancer_ips}"
  ssh_username = "${var.load_balancer_username}"
  ssh_password = "${var.load_balancer_password}"
  ucp_ips      = "${module.docker-manager.node_ips}"
  dtr_ips      = "${module.docker-dtr.node_ips}"
  script_path   = "${var.load_balancer_script_path}"
}
