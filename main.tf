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

module "docker-manager" {
  source                  = "modules/dockeree-node"

  node_type               = "mgr"
  environment             = "${var.environment}"

  vsphere_datacenter      = "${var.vsphere_datacenter}"
  vsphere_datastore       = "${var.vsphere_datastore}"
  vsphere_compute_cluster = "${var.vsphere_compute_cluster}"
  vsphere_network         = "${var.vsphere_network}"
  vsphere_folder          = "${var.vsphere_folder}"

  disk_template           = "${var.manager_vm_template}"
  domain                  = "${var.domain}"
  node_vcpu               = "${var.manager_vcpu}"
  node_memory             = "${var.manager_memory_mb}"
  root_volume_size        = "${var.manager_root_volume_size}"
  consul_secret           = "${random_id.consul_secret.b64_std}"
  ucp_admin_username      = "${var.ucp_admin_username}"
  ucp_admin_password      = "${var.ucp_admin_password}"
  # ucp_dns_name            = "${var.ucp_dns_name}"

  node_count              = "${var.manager_node_count}"
}

module "docker-worker" {
  source                  = "modules/dockeree-node"

  # bastion_host            = "${module.docker-manager.public_ips[0]}"
  node_type               = "wrk"
  environment             = "${var.environment}"

  vsphere_datacenter      = "${var.vsphere_datacenter}"
  vsphere_datastore       = "${var.vsphere_datastore}"
  vsphere_compute_cluster = "${var.vsphere_compute_cluster}"
  vsphere_network         = "${var.vsphere_network}"
  vsphere_folder          = "${var.vsphere_folder}"

  disk_template           = "${var.worker_vm_template}"
  domain                  = "${var.domain}"
  node_vcpu               = "${var.worker_vcpu}"
  node_memory             = "${var.worker_memory_mb}"
  root_volume_size        = "${var.worker_root_volume_size}"
  consul_secret           = "${random_id.consul_secret.b64_std}"

  node_count              = "${var.worker_node_count}"
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

  disk_template           = "${var.manager_vm_template}"
  domain                  = "${var.domain}"
  node_vcpu               = "${var.dtr_vcpu}"
  node_memory             = "${var.dtr_memory_mb}"
  root_volume_size        = "${var.dtr_root_volume_size}"
  consul_secret           = "${random_id.consul_secret.b64_std}"
  ucp_admin_username      = "${var.ucp_admin_username}"
  ucp_admin_password      = "${var.ucp_admin_password}"
  # ucp_dns_name            = "${var.ucp_dns_name}"
  # dtr_dns_name            = "${var.dtr_dns_name}"

#  minio_endpoint          = "${var.minio_endpoint != "" ? var.minio_endpoint : module.minio.minio_endpoint}"
#  minio_access_key        = "${var.minio_access_key != "" ? var.minio_access_key : module.minio.access_key}"
#  minio_secret_key        = "${var.minio_secret_key != "" ? var.minio_secret_key : module.minio.secret_key}"

   node_count              = "${var.dtr_node_count}"
}

#module "minio" {
#  source                  = "modules/docker-minio"
#
#  bastion_host            = "${module.docker-manager.public_ips[0]}"
#  ssh_key_name            = "${var.ssh_key_name}"
#  ssh_key_path            = "${var.ssh_key_path}"
#  environment             = "${var.environment}"
#  ami_id                  = "${data.aws_ami.amazon_linux.id}"
#
#  instance_type           = "${var.minio_instance_type}"
#  subnet_ids              = "${module.vpc.private_subnets}"
#  vpc_security_group_ids  = ["${module.security-group-rules.minio_id}"]
#
#  minio_endpoint          = "${var.minio_endpoint}"
#  minio_storage_size      = "${var.minio_storage_size}"
#}

#module "load-balancer" {
#  source = "modules/dockeree-lb"
#
#  environment           = "${var.environment}"
#  vpc_id                = "${module.vpc.vpc_id}"
#  dns_zone              = "${var.dns_zone}"
#  ucp_dns_name          = "${var.ucp_dns_name}"
#  dtr_dns_name          = "${var.dtr_dns_name}"
#  public_subnet_ids     = "${module.vpc.public_subnets}"
#  ucp_mgr_instance_ids  = "${module.docker-manager.instance_ids}"
#  ucp_node_count        = "${var.manager_node_count}"
#  dtr_instance_ids      = "${module.docker-dtr.instance_ids}"
#  dtr_node_count        = "${var.dtr_node_count}"
#}
# TODO: Create load balancer with master nodes behind it
