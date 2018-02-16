# Reference: https://docs.docker.com/datacenter/ucp/2.2/guides/admin/install/system-requirements/#ports-used

resource "aws_security_group" "manager_external" {
  description = "Internet-facing rules for the manager nodes"
  name_prefix = "dockeree_mgr_ext_${var.environment}"
  vpc_id = "${var.vpc_id}"

  tags {
    Name = "dockeree_mgr_ext_${var.environment}"
  }
}

resource "aws_security_group_rule" "ssh_in" {
  description = "SSH"
  type = "ingress"
  protocol = "tcp"
  from_port = 22
  to_port = 22
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = "${aws_security_group.manager_external.id}"
}

resource "aws_security_group_rule" "http_in" {
  description = "HTTP"
  type = "ingress"
  protocol = "tcp"
  from_port = 80
  to_port = 80
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = "${aws_security_group.manager_external.id}"
}

resource "aws_security_group_rule" "https_in" {
  description = "HTTPS"
  type = "ingress"
  protocol = "tcp"
  from_port = 443
  to_port = 443
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = "${aws_security_group.manager_external.id}"
}

#===========================================================================
resource "aws_security_group" "manager_internal" {
  description = "Rules for communication between managers"
  name_prefix = "dockeree_mgr_int_${var.environment}"
  vpc_id = "${var.vpc_id}"

  tags {
    Name = "dockeree_mgr_int_${var.environment}"
  }
}

resource "aws_security_group_rule" "swarm_manager" {
  description = "Port for the Docker Swarm manager. Used for backwards compatibility"
  type = "ingress"
  protocol = "tcp"
   from_port = 2376
  to_port = 2376
  cidr_blocks = ["${var.public_subnets_cidr}", "${var.private_subnets_cidr}"]

  security_group_id = "${aws_security_group.manager_internal.id}"
}

resource "aws_security_group_rule" "node_configuration" {
  description = "Ports for internal node configuration, cluster configuration, and HA"
  type = "ingress"
  protocol = "tcp"
  from_port = 12379
  to_port = 12380
  cidr_blocks = ["${var.public_subnets_cidr}", "${var.private_subnets_cidr}"]

  security_group_id = "${aws_security_group.manager_internal.id}"
}

resource "aws_security_group_rule" "ca" {
  description = "Port for the certificate authority"
  type = "ingress"
  protocol = "tcp"
  from_port = 12381
  to_port = 12381
  cidr_blocks = ["${var.public_subnets_cidr}", "${var.private_subnets_cidr}"]

  security_group_id = "${aws_security_group.manager_internal.id}"
}

resource "aws_security_group_rule" "ucp_ca" {
  description = "Port for the UCP certificate authority"
  type = "ingress"
  protocol = "tcp"
  from_port = 12382
  to_port = 12382
  cidr_blocks = ["${var.public_subnets_cidr}", "${var.private_subnets_cidr}"]

  security_group_id = "${aws_security_group.manager_internal.id}"
}

resource "aws_security_group_rule" "auth_storage_backend" {
  description = "Port for the authentication storage backend"
  type = "ingress"
  protocol = "tcp"
  from_port = 12383
  to_port = 12383
  cidr_blocks = ["${var.public_subnets_cidr}", "${var.private_subnets_cidr}"]

  security_group_id = "${aws_security_group.manager_internal.id}"
}


resource "aws_security_group_rule" "auth_storage_backend_replication" {
  description = "Port for the authentication storage backend for replication across managers"
  type = "ingress"
  protocol = "tcp"
  from_port = 12384
  to_port = 12384
  cidr_blocks = ["${var.public_subnets_cidr}", "${var.private_subnets_cidr}"]

  security_group_id = "${aws_security_group.manager_internal.id}"
}


resource "aws_security_group_rule" "auth_service_api" {
  description = "Port for the authentication service API"
  type = "ingress"
  protocol = "tcp"
  from_port = 12385
  to_port = 12385
  cidr_blocks = ["${var.public_subnets_cidr}", "${var.private_subnets_cidr}"]

  security_group_id = "${aws_security_group.manager_internal.id}"
}


resource "aws_security_group_rule" "auth_worker" {
  description = "Port for the authentication worker"
  type = "ingress"
  protocol = "tcp"
  from_port = 12386
  to_port = 12386
  cidr_blocks = ["${var.public_subnets_cidr}", "${var.private_subnets_cidr}"]

  security_group_id = "${aws_security_group.manager_internal.id}"
}


resource "aws_security_group_rule" "metrics_service" {
  description = "Port for the metrics service"
  type = "ingress"
  protocol = "tcp"
  from_port = 12387
  to_port = 12387
  cidr_blocks = ["${var.public_subnets_cidr}", "${var.private_subnets_cidr}"]

  security_group_id = "${aws_security_group.manager_internal.id}"
}

#===========================================================================
resource "aws_security_group" "worker_internal" {
  description = "Rules for communication only applicable to worker nodes"
  name_prefix = "dockeree_worker_internal_${var.environment}"
  vpc_id = "${var.vpc_id}"

  tags {
    Name = "dockeree_worker_internal_${var.environment}"
  }
}

resource "aws_security_group_rule" "worker_ssh_in" {
  description = "SSH"
  type = "ingress"
  protocol = "tcp"
  from_port = 22
  to_port = 22
  cidr_blocks = ["${var.public_subnets_cidr}", "${var.private_subnets_cidr}"]

  security_group_id = "${aws_security_group.worker_internal.id}"
}
#===========================================================================
resource "aws_security_group" "minio" {
  description = "Rules for the Minio storage service"
  name_prefix = "docker_minio_${var.environment}"
  vpc_id = "${var.vpc_id}"

  tags {
    Name = "docker_minio_${var.environment}"
  }
}

resource "aws_security_group_rule" "minio_egress_all" {
  type        = "egress"
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = "${aws_security_group.minio.id}"
}

resource "aws_security_group_rule" "minio_ssh" {
  description = "Allow SSH connections for provisioning from a bastion host"
  type = "ingress"
  protocol = "tcp"
  from_port = 22
  to_port = 22
  cidr_blocks = ["${var.public_subnets_cidr}"]

  security_group_id = "${aws_security_group.minio.id}"
}

resource "aws_security_group_rule" "minio" {
  description = "Allow DTRs to access Minio on the standard port"
  type = "ingress"
  protocol = "tcp"
  from_port = 9000
  to_port = 9000
  cidr_blocks = ["${var.public_subnets_cidr}"]

  security_group_id = "${aws_security_group.minio.id}"
}


#===========================================================================
resource "aws_security_group" "swarm_common" {
  description = "Rules for communication between all swarm nodes"
  name_prefix = "dockeree_swarm_common_${var.environment}"
  vpc_id = "${var.vpc_id}"

  tags {
    Name = "dockeree_swarm_common_${var.environment}"
  }
}

resource "aws_security_group_rule" "egress_all" {
  type        = "egress"
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = "${aws_security_group.swarm_common.id}"
}

resource "aws_security_group_rule" "ucp_api" {
  description = "Port for the UCP web UI and API"
  type = "ingress"
  protocol = "tcp"
  from_port = 443
  to_port = 443
  cidr_blocks = ["${var.public_subnets_cidr}", "${var.private_subnets_cidr}"]

  security_group_id = "${aws_security_group.swarm_common.id}"
}

resource "aws_security_group_rule" "ingress_swarm" {
  description = "Port for communication between swarm nodes"
  type = "ingress"
  protocol = "tcp"
  from_port = 2377
  to_port = 2377
  cidr_blocks = ["${var.public_subnets_cidr}", "${var.private_subnets_cidr}"]

  security_group_id = "${aws_security_group.swarm_common.id}"
}

resource "aws_security_group_rule" "ingress_overlay_networking" {
  description = "Port for overlay networking"
  type = "ingress"
  protocol = "udp"
  from_port = 4789
  to_port = 4789
  cidr_blocks = ["${var.public_subnets_cidr}", "${var.private_subnets_cidr}"]

  security_group_id = "${aws_security_group.swarm_common.id}"
}

resource "aws_security_group_rule" "ingress_gossip_tcp" {
  description = "Port for gossip-based clustering"
  type = "ingress"
  protocol = "tcp"
  from_port = 7946
  to_port = 7946
  cidr_blocks = ["${var.public_subnets_cidr}", "${var.private_subnets_cidr}"]

  security_group_id = "${aws_security_group.swarm_common.id}"
}

resource "aws_security_group_rule" "ingress_gossip_udp" {
  description = "Port for gossip-based clustering"
  type = "ingress"
  protocol = "udp"
  from_port = 7946
  to_port = 7946
  cidr_blocks = ["${var.public_subnets_cidr}", "${var.private_subnets_cidr}"]

  security_group_id = "${aws_security_group.swarm_common.id}"
}

resource "aws_security_group_rule" "tls_proxy" {
  description = "Port for a TLS proxy that provides access to UCP, Docker Engine, and Docker Swarm"
  type = "ingress"
  protocol = "tcp"
  from_port = 12376
  to_port = 12376
  cidr_blocks = ["${var.public_subnets_cidr}"]

  security_group_id = "${aws_security_group.swarm_common.id}"
}
