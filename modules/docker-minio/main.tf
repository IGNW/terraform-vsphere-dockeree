locals {
  name = "docker-minio-${var.environment}"
  disk_dev = "/dev/xvdf"
}

data "template_file" "mount_ebs" {
  template = "${file("${path.module}/mount_ebs.tpl.sh")}"

  vars {
    disk_dev = "${local.disk_dev}"
  }
}

resource "random_string" "minio_access_key" {
  length = 20
  special = false
}

resource "random_string" "minio_secret_key" {
  length = 40
  special = false
}

resource "aws_instance" "minio" {
  # Create this resource only if the user does define their own endpoint
  count                   = "${var.minio_endpoint == "" ? 1 : 0}"

  ami                     = "${var.ami_id}"
  instance_type           = "${var.instance_type}"
  key_name                = "${var.ssh_key_name}"
  vpc_security_group_ids  = ["${var.vpc_security_group_ids}"]
  subnet_id               = "${element(var.subnet_ids, 0)}"

  tags {
    Name = "${local.name}"
  }

  volume_tags {
    Name = "${local.name}"
  }

  # Add EBS volume for Minio storage
  ebs_block_device {
    device_name = "${local.disk_dev}"
    delete_on_termination = true
    volume_size = "${var.minio_storage_size}"
  }

  provisioner "file" {
    connection = {
      type          = "ssh"
      private_key   = "${file(var.ssh_key_path)}"
      user          = "ec2-user"
      bastion_user  = "centos"
      bastion_host  = "${var.bastion_host}"
    }

    content     = "${data.template_file.mount_ebs.rendered}"
    destination = "/tmp/mount_ebs.sh"
  }

  # Run the configuration script
  provisioner "remote-exec" {
    connection = {
      type          = "ssh"
      private_key   = "${file(var.ssh_key_path)}"
      user          = "ec2-user"
      bastion_user  = "centos"
      bastion_host  = "${var.bastion_host}"
    }
    inline = [
<<EOT
sudo yum update -y
sudo yum install docker -y
sudo service docker start
sudo usermod -a -G docker ec2-user

chmod +x /tmp/mount_ebs.sh
sudo /tmp/mount_ebs.sh || exit 1
sudo mkdir /mnt/data/dtr

sudo docker run -d -p 9000:9000 --name minio --restart unless-stopped \
  -e "MINIO_ACCESS_KEY=${random_string.minio_access_key.result}" \
  -e "MINIO_SECRET_KEY=${random_string.minio_secret_key.result}" \
  -e "MINIO_BROWSER=off" \
  -e "MINIO_REGION=none" \
  -v /mnt/data:/data \
  -v /mnt/config:/root/.minio \
  minio/minio server /data
EOT
    ]
  }
}
