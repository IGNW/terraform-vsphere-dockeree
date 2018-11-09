locals {
  name_prefix = "dockeree-${var.environment}-${var.node_type}"
  hostname_prefix = "dockeree-${var.node_type}"
}

data "template_file" "swarm_init" {
  template = "${file("${path.module}/swarm_init.tpl.sh")}"

  vars {
    environment         = "${var.environment}"
    role                = "${local.name_prefix}"
    consul_secret       = "${var.consul_secret}"
    ucp_admin_username  = "${var.ucp_admin_username}"
    ucp_admin_password  = "${var.ucp_admin_password}"
    ucp_dns_name        = "${var.ucp_dns_name}"
    dtr_dns_name        = "${var.dtr_dns_name}"
  }
}

data "template_file" "config_dtr_minio" {
  template = "${file("${path.module}/config_dtr_minio.tpl.py")}"

  vars {
    ucp_admin_username  = "${var.ucp_admin_username}"
    ucp_admin_password  = "${var.ucp_admin_password}"
    minio_endpoint      = "${var.minio_endpoint}"
    minio_access_key    = "${var.minio_access_key}"
    minio_secret_key    = "${var.minio_secret_key}"
  }
}

data "vsphere_datacenter" "dc" {
  name = "${var.vsphere_datacenter}"
}

data "vsphere_datastore" "datastore" {
  name          = "${var.vsphere_datastore}"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

data "vsphere_compute_cluster" "cluster" {
  name          = "${var.vsphere_compute_cluster}"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

data "vsphere_network" "network" {
  name          = "${var.vsphere_network}"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

data "vsphere_virtual_machine" "template" {
  name          = "${var.disk_template}"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

data "vsphere_tag_category" "name" {
  name = "Name"
}

data "vsphere_tag_category" "role" {
  name = "Role"
}

resource "vsphere_tag" "name" {
  count       = "${var.node_count}"
  name        = "${local.hostname_prefix}-${count.index}"
  category_id = "${data.vsphere_tag_category.name.id}"
}

resource "vsphere_tag" "role" {
  name = "${local.name_prefix}"
  category_id = "${data.vsphere_tag_category.role.id}"
}

resource "vsphere_virtual_machine" "dockeree" {
  count                   = "${var.node_count}"

  name               = "${local.hostname_prefix}-${count.index}"
  folder             = "${var.vsphere_folder}"
  resource_pool_id   = "${data.vsphere_compute_cluster.cluster.resource_pool_id}"
  datastore_id       = "${data.vsphere_datastore.datastore.id}"

  num_cpus   = "${var.node_vcpu}"
  memory = "${var.node_memory}"
  memory_reservation = "${var.node_memory}"
  guest_id = "${data.vsphere_virtual_machine.template.guest_id}"

  network_interface {
      network_id = "${data.vsphere_network.network.id}"
  }
  disk {
      label = "disk0"
      size  = "${var.root_volume_size}"
  }

  clone {
      template_uuid = "${data.vsphere_virtual_machine.template.id}"

      customize {
        linux_options {
          host_name = "${local.hostname_prefix}-${count.index}"
          domain    = "${var.domain}"
        }

        network_interface {}
    }
  }

  tags = ["${element(vsphere_tag.name.*.id, count.index)}", "${vsphere_tag.role.id}"]

}
