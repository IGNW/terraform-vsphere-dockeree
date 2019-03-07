locals {
  hostname_prefix = "dockeree-${var.environment}-${var.node_type}"
}

data "vsphere_datacenter" "dc" {
  name = "${var.vsphere_datacenter}"
}

data "vsphere_datastore" "datastore" {
  name          = "${var.vsphere_datastore}"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

data "vsphere_compute_cluster" "cluster" {
  name          = "${var.vsphere_cluster}"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

data "vsphere_network" "network" {
  name          = "${var.vsphere_network}"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

data "vsphere_virtual_machine" "template" {
  name          = "${var.vm_template}"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

resource "vsphere_virtual_machine" "dockeree" {
  count              = "${var.node_count}"

  name               = "${local.hostname_prefix}-${var.start_id + count.index}"
  folder             = "${var.vsphere_folder}"
  resource_pool_id   = "${data.vsphere_compute_cluster.cluster.resource_pool_id}"
  datastore_id       = "${data.vsphere_datastore.datastore.id}"

  num_cpus = "${var.node_vcpu}"
  memory = "${var.node_memory}"
  memory_reservation = "${var.node_memory}"
  scsi_type = "${var.scsi_type}"
  guest_id = "${data.vsphere_virtual_machine.template.guest_id}"

  network_interface {
      network_id = "${data.vsphere_network.network.id}"
  }
  disk {
      label = "disk0"
      size  = "${var.root_volume_size}"
      thin_provisioned = "${var.thin_provisioned}"
      eagerly_scrub    = "${var.eagerly_scrub}"
  }

  clone {
      template_uuid = "${data.vsphere_virtual_machine.template.id}"

      customize {
        linux_options {
          host_name = "${local.hostname_prefix}-${var.start_id + count.index}"
          domain    = "${var.domain}"
        }
        network_interface {}
        # dns_server_list = ["8.8.8.8"]
        # dns_suffix_list = ["${var.domain}"]
    }
  }

}
