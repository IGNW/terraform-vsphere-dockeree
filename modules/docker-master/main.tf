resource "aws_instance" "dockeree" {
  ami                     = "${var.ami_id}"
  instance_type           = "${var.instance_type}"
  key_name                = "${var.ssh_key_name}"
  vpc_security_group_ids  = ["${var.vpc_security_group_ids}"]
  subnet_id               = "${element(var.subnet_ids, 0)}"

  tags {
    Name = "${var.name_prefix}-0"
  }

  volume_tags {
    Name = "${var.name_prefix}-0"
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
    }
    inline = [
<<EOT
sudo docker container run --rm -it --name ucp \
    -v /var/run/docker.sock:/var/run/docker.sock \
    docker/ucp:2.2.5 install \
    --host-address $(/sbin/ip -f inet addr show dev eth0 | grep -Po 'inet \K[\d.]+') \
    --admin-username ${var.ucp_admin_username} \
    --admin-password ${var.ucp_admin_password}
EOT
    ]
  }
}
