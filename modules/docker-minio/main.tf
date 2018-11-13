locals {
  name        = "docker-minio-${var.environment}"
  disk_dev    = "/dev/xvdf"
  minio_port  = 9000
}

#data "template_file" "mount_ebs" {
#  template = "${file("${path.module}/mount_ebs.tpl.sh")}"
#
#  vars {
#    disk_dev = "${local.disk_dev}"
#  }
#}

resource "random_string" "minio_access_key" {
  length = 20
  special = false
}

resource "random_string" "minio_secret_key" {
  length = 40
  special = false
}

data "vsphere_tag_category" "name" {
  name = "Name"
}

data "vsphere_tag_category" "role" {
  name = "Role"
}

resource "vsphere_tag" "name" {
  name        = "${local.name}"
  category_id = "${data.vsphere_tag_category.name.id}"
}

resource "vsphere_tag" "role" {
  name = "${local.name}"
  category_id = "${data.vsphere_tag_category.role.id}"
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

variable "domain" {
  description = "Domain name"
}

data "vsphere_virtual_machine" "template" {
  name          = "${var.disk_template}"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

resource "vsphere_virtual_machine" "minio" {

  name               = "${local.name}"
  folder             = "${var.vsphere_folder}"
  resource_pool_id   = "${data.vsphere_compute_cluster.cluster.resource_pool_id}"
  datastore_id       = "${data.vsphere_datastore.datastore.id}"

  num_cpus = "${var.node_vcpu}"
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
          host_name = "${local.name}"
          domain    = "${var.domain}"
        }

        network_interface {}
    }
  }

  tags = ["${vsphere_tag.name.*.id}", "${vsphere_tag.role.id}"]

  # Add EBS volume for Minio storage
  # ebs_block_device {
  #  device_name = "${local.disk_dev}"
  #  delete_on_termination = true
  #  volume_size = "${var.minio_storage_size}"
  #}

provisioner "remote-exec" {
  connection = {
    type = "ssh"
    user = "root"
    password = "${var.root_password}"
  }
  inline = ["touch /foo.bar"]

}



  # Run the configuration script
  #provisioner "remote-exec" {
  #  connection = {
  #    type          = "ssh"
  #    private_key   = "${file(var.ssh_key_path)}"
  #    user          = "ec2-user"
  #    bastion_user  = "centos"
  #    bastion_host  = "${var.bastion_host}"
  #  }
  #  inline = [
#<<EOT
#sudo yum update -y
#sudo yum install docker -y
#sudo service docker start
#sudo usermod -a -G docker ec2-user
#
#chmod +x /tmp/mount_ebs.sh
#sudo /tmp/mount_ebs.sh || exit 1
#sudo mkdir /mnt/data/dtr

#sudo docker run -d -p ${local.minio_port}:${local.minio_port} --name minio --restart unless-stopped \
#  -e "MINIO_ACCESS_KEY=${random_string.minio_access_key.result}" \
#  -e "MINIO_SECRET_KEY=${random_string.minio_secret_key.result}" \
#  -e "MINIO_BROWSER=off" \
#  -e "MINIO_REGION=none" \
#  -v /mnt/data:/data \
#  -v /mnt/config:/root/.minio \
#  minio/minio server /data
#EOT
#    ]
#  }
}
