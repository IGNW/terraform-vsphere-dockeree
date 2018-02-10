resource "aws_instance" "dockeree" {
  count                   = "${var.node_count}"

  ami                     = "${var.ami_id}"
  instance_type           = "${var.instance_type}"
  key_name                = "${var.ssh_key_name}"
  vpc_security_group_ids  = ["${var.vpc_security_group_ids}"]
  subnet_id               = "${element(var.subnet_ids, count.index + var.count_offset)}"

  tags {
    Name = "${var.name_prefix}-${count.index + var.count_offset}"
  }

  volume_tags {
    Name = "${var.name_prefix}-${count.index + var.count_offset}"
  }

  # Add EBS volume for Jira install/opt directory
  root_block_device {
    volume_size = "${var.root_volume_size}"
    delete_on_termination = true
  }
  # Run the configuration script
  provisioner "remote-exec" {
    connection = {
      type        = "ssh"
      user        = "centos"
      private_key = "${file(var.ssh_key_path)}"
      bastion_host = "${var.basion_host}"

    }
    inline = [
      "sudo docker swarm join --token ${var.join_token} ${var.join_address}:2377"
    ]
  }
}
