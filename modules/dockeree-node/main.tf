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

resource "aws_instance" "dockeree" {
  count                   = "${var.node_count}"

  ami                     = "${var.ami_id}"
  instance_type           = "${var.instance_type}"
  key_name                = "${var.ssh_key_name}"
  vpc_security_group_ids  = ["${var.vpc_security_group_ids}"]
  subnet_id               = "${element(var.subnet_ids, count.index)}"
  iam_instance_profile    = "${var.iam_profile_id}"

  tags {
    Name = "${local.name_prefix}-${count.index}"
    Role = "${local.name_prefix}"
  }

  volume_tags {
    Name = "${local.name_prefix}-${count.index}"
  }

  # Add EBS volume for Jira install/opt directory
  root_block_device {
    volume_size = "${var.root_volume_size}"
    delete_on_termination = true
  }

  provisioner "file" {
    connection = {
      type          = "ssh"
      user          = "centos"
      private_key   = "${file(var.ssh_key_path)}"
      bastion_host  = "${var.bastion_host}"
    }

    content     = "${data.template_file.swarm_init.rendered}"
    destination = "/tmp/swarm_init.sh"
  }

  provisioner "file" {
    connection = {
      type          = "ssh"
      user          = "centos"
      private_key   = "${file(var.ssh_key_path)}"
      bastion_host  = "${var.bastion_host}"
    }

    content     = "${data.template_file.config_dtr_minio.rendered}"
    destination = "/tmp/config_dtr_minio.sh"
  }

  provisioner "remote-exec" {
    connection = {
      type          = "ssh"
      user          = "centos"
      private_key   = "${file(var.ssh_key_path)}"
      bastion_host  = "${var.bastion_host}"
    }

    inline = [
      <<EOT
NODE_NAME="${local.hostname_prefix}-${count.index}"
echo "127.0.0.1 $NODE_NAME" | sudo tee --append /etc/hosts
sudo hostnamectl set-hostname $NODE_NAME
echo "${var.node_count}" > /tmp/node_count

chmod +x /tmp/swarm_init.sh /tmp/config_dtr_minio.sh
sudo /tmp/swarm_init.sh
EOT
    ]
  }
}
