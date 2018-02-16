provider "aws" {
  region = "${var.aws_region}"
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name               = "dockeree-vpc-${var.environment}"
  cidr               = "${var.vpc_cidr}"
  public_subnets     = "${var.public_subnets}"
  private_subnets    = "${var.private_subnets}"
  azs                = "${var.availability_zones}"
  create_database_subnet_group = false

  # Add tags to objects created by this module to help identify their purpose/origin in AWS.
  tags = {
    Terraform = "true"
    Environment = "${var.environment}"
  }
}

data "aws_ami" "dockeree" {
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
    values = ["docker-centos7-*"]
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

module "docker-master" {
  source = "modules/docker-master"

  ssh_key_name            = "${var.ssh_key_name}"
  ssh_key_path            = "${var.ssh_key_path}"

  name_prefix             = "dockeree-${var.environment}-mgr"
  ami_id                  = "${data.aws_ami.dockeree.id}"
  instance_type           = "${var.manager_instance_type}"
  root_volume_size        = "${var.manager_root_volume_size}"

  subnet_ids              = "${module.vpc.public_subnets}"
  vpc_security_group_ids  = ["${module.security-group-rules.manager_external_id}", "${module.security-group-rules.manager_internal_id}", "${module.security-group-rules.swarm_common}"]

  ucp_admin_username      = "${var.ucp_admin_username}"
  ucp_admin_password      = "${var.ucp_admin_password}"
}

data "external" "get_join_tokens" {
  depends_on = ["module.docker-master"]
  program = ["bash", "get-join-tokens.sh"]

  # Set values passed to the external program as the data query.
  query = {
    mgr_addr     = "${module.docker-master.master_public_ip}"
    ssh_key_path = "${var.ssh_key_path}"
  }
}

module "docker-manager" {
  source                  = "modules/dockeree-node"

  ssh_key_name            = "${var.ssh_key_name}"
  ssh_key_path            = "${var.ssh_key_path}"

  name_prefix             = "dockeree-${var.environment}-mgr"
  ami_id                  = "${data.aws_ami.dockeree.id}"
  instance_type           = "${var.manager_instance_type}"
  root_volume_size        = "${var.manager_root_volume_size}"
  node_count              = "${var.manager_node_count - 1}"
  count_offset            = 1

  subnet_ids              = "${module.vpc.public_subnets}"
  vpc_security_group_ids  = ["${module.security-group-rules.manager_external_id}", "${module.security-group-rules.manager_internal_id}", "${module.security-group-rules.swarm_common}"]

  join_token              = "${lookup(data.external.get_join_tokens.result, "manager_token")}"
  join_address            = "${module.docker-master.master_private_ip}"
}

module "docker-worker" {
  source                  = "modules/dockeree-node"

  basion_host             = "${module.docker-master.master_public_ip}"
  ssh_key_name            = "${var.ssh_key_name}"
  ssh_key_path            = "${var.ssh_key_path}"

  name_prefix             = "dockeree-${var.environment}-wrk"
  ami_id                  = "${data.aws_ami.dockeree.id}"
  instance_type           = "${var.worker_instance_type}"
  root_volume_size        = "${var.worker_root_volume_size}"
  node_count              = "${var.worker_node_count}"
  count_offset            = 0

  subnet_ids              = "${module.vpc.private_subnets}"
  vpc_security_group_ids  = ["${module.security-group-rules.worker_internal_id}", "${module.security-group-rules.swarm_common}"]

  join_token              = "${lookup(data.external.get_join_tokens.result, "worker_token")}"
  join_address            = "${module.docker-master.master_private_ip}"
}

module "minio" {
  source                  = "modules/docker-minio"

  bastion_host            = "${module.docker-master.master_public_ip}"
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

# TODO: Create load balancer with master nodes behind it
