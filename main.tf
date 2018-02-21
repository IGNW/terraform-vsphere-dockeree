provider "aws" {
  region = "${var.aws_region}"
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name                          = "dockeree-vpc-${var.environment}"
  cidr                          = "${var.vpc_cidr}"
  public_subnets                = "${var.public_subnets}"
  private_subnets               = "${var.private_subnets}"
  azs                           = "${var.availability_zones}"
  create_database_subnet_group  = false
  enable_dns_hostnames          = true
  enable_nat_gateway            = true

  # Add tags to objects created by this module to help identify their purpose/origin in AWS.
  tags = {
    Terraform = "true"
    Environment = "${var.environment}"
  }
}

data "aws_ami" "dockeree_centos7" {
  owners  = ["self"]
  most_recent      = true

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "is-public"
    values = ["false"]
  }

  filter {
    name   = "name"
    values = ["dockeree-centos7-*"]
  }
}

data "aws_ami" "amazon_linux" {
  owners  = ["amazon"]
  most_recent      = true

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "name"
    values = ["*amzn-ami-hvm-*"]
  }
}

module "security-group-rules" {
  source = "modules/dockeree-security-group-rules"

  environment           = "${var.environment}"
  vpc_id                = "${module.vpc.vpc_id}"
  private_subnets_cidr  = "${module.vpc.private_subnets_cidr_blocks}"
  public_subnets_cidr   = "${module.vpc.public_subnets_cidr_blocks}"
}

resource "aws_iam_role" "ec2_assume_role" {
  name = "ec2_assume_role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "ec2_describe" {
  name = "ec2_describe"
  role = "${aws_iam_role.ec2_assume_role.id}"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "ec2:DescribeInstances",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_instance_profile" "consul_profile" {
  name = "consul_profile"
  role = "${aws_iam_role.ec2_assume_role.name}"
}

module "docker-manager" {
  source                  = "modules/dockeree-node"

  ssh_key_name            = "${var.ssh_key_name}"
  ssh_key_path            = "${var.ssh_key_path}"
  node_type               = "mgr"
  environment             = "${var.environment}"
  ami_id                  = "${data.aws_ami.dockeree_centos7.id}"

  instance_type           = "${var.manager_instance_type}"
  root_volume_size        = "${var.manager_root_volume_size}"
  subnet_ids              = "${module.vpc.public_subnets}"
  vpc_security_group_ids  = ["${module.security-group-rules.manager_external_id}", "${module.security-group-rules.manager_internal_id}", "${module.security-group-rules.swarm_common_id}"]
  consul_secret           = "${random_id.consul_secret.b64_std}"
  iam_profile_id          = "${aws_iam_instance_profile.consul_profile.id}"
  ucp_admin_username      = "${var.ucp_admin_username}"
  ucp_admin_password      = "${var.ucp_admin_password}"

  node_count              = "${var.manager_node_count}"
}

module "docker-worker" {
  source                  = "modules/dockeree-node"

  bastion_host            = "${module.docker-manager.public_ips[0]}"
  ssh_key_name            = "${var.ssh_key_name}"
  ssh_key_path            = "${var.ssh_key_path}"
  node_type               = "wrk"
  environment             = "${var.environment}"
  ami_id                  = "${data.aws_ami.dockeree_centos7.id}"

  instance_type           = "${var.worker_instance_type}"
  root_volume_size        = "${var.worker_root_volume_size}"
  subnet_ids              = "${module.vpc.private_subnets}"
  vpc_security_group_ids  = ["${module.security-group-rules.worker_internal_id}", "${module.security-group-rules.swarm_common_id}"]
  consul_secret           = "${random_id.consul_secret.b64_std}"
  iam_profile_id          = "${aws_iam_instance_profile.consul_profile.id}"

  node_count              = "${var.worker_node_count}"
}

# Docker Trusted Registry
module "docker-dtr" {
  source                  = "modules/dockeree-node"

  ssh_key_name            = "${var.ssh_key_name}"
  ssh_key_path            = "${var.ssh_key_path}"
  node_type               = "dtr"
  environment             = "${var.environment}"
  ami_id                  = "${data.aws_ami.dockeree_centos7.id}"

  instance_type           = "${var.dtr_instance_type}"
  root_volume_size        = "${var.dtr_root_volume_size}"
  subnet_ids              = "${module.vpc.public_subnets}"
  vpc_security_group_ids  = ["${module.security-group-rules.dtr_id}", "${module.security-group-rules.swarm_common_id}"]
  consul_secret           = "${random_id.consul_secret.b64_std}"
  iam_profile_id          = "${aws_iam_instance_profile.consul_profile.id}"
  ucp_admin_username      = "${var.ucp_admin_username}"
  ucp_admin_password      = "${var.ucp_admin_password}"

  minio_endpoint          = "${var.minio_endpoint != "" ? var.minio_endpoint : module.minio.minio_endpoint}"
  minio_access_key        = "${var.minio_access_key != "" ? var.minio_access_key : module.minio.access_key}"
  minio_secret_key        = "${var.minio_secret_key != "" ? var.minio_secret_key : module.minio.secret_key}"

  node_count              = "${var.dtr_node_count}"
}

module "minio" {
  source                  = "modules/docker-minio"

  bastion_host            = "${module.docker-manager.public_ips[0]}"
  ssh_key_name            = "${var.ssh_key_name}"
  ssh_key_path            = "${var.ssh_key_path}"
  environment             = "${var.environment}"
  ami_id                  = "${data.aws_ami.amazon_linux.id}"

  instance_type           = "${var.minio_instance_type}"
  subnet_ids              = "${module.vpc.private_subnets}"
  vpc_security_group_ids  = ["${module.security-group-rules.minio_id}"]

  minio_endpoint          = "${var.minio_endpoint}"
  minio_storage_size      = "${var.minio_storage_size}"
}

resource "random_id" "consul_secret" {
  byte_length = 16
}

# TODO: Create load balancer with master nodes behind it
