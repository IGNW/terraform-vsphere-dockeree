variable "ssh_key_name" {
  description = "Name of the EC2 Key Pair to be used for SSH."
}

variable "ssh_key_path" {
  description = "Local path to the SSH key matching the key name given above."
}

variable "environment" {
  description = "Name to be used as a affix on resources"
  default     = "dev"
}

variable "aws_region" {
  description = "The AWS region to deploy into (e.g. us-east-1)."
  default     = "us-east-1"
}

variable "availability_zones" {
  description = "Availability Zones, used to configure the VPC"
  type = "list"
  default = ["us-east-1a", "us-east-1b"]
}

variable "vpc_cidr" {
  description = "Supernet for this VPC"
  default     = "10.0.0.0/23"
  type        = "string"
}

variable "public_subnets" {
  description = "Internal networks for instances that will be exposed to public"
  type        = "list"
  default     = ["10.0.0.0/25", "10.0.0.128/25"]
}

variable "private_subnets" {
  description = "Internal networks for instances that aren't exposed to public"
  type        = "list"
  default     = ["10.0.1.0/25", "10.0.1.128/25"]
}

variable "manager_instance_type" {
  description = "EC2 instance type to use for the manager nodes"
  default = "t2.large"
}

variable "manager_node_count" {
  description = "Number of manager nodes to create. Should be an odd number."
  default = 3
}

variable "manager_root_volume_size" {
  description = "The size of the manager node's root volume in gigabytes."
  default = 8
}

variable "worker_instance_type" {
  description = "EC2 instance type to use for the worker nodes"
  default = "t2.medium"
}

variable "worker_node_count" {
  description = "Number of worker nodes to create."
  default = 4
}

variable "worker_root_volume_size" {
  description = "The size of the worker node's root volume in gigabytes."
  default = 8
}

variable "ucp_admin_username" {
  description = "Username for the UCP administrator, used for the GUI login"
  default = "ucpadmin"
}

variable "ucp_admin_password" {
  description = "Password for the UCP administrator, used for the GUI login"
  default = "ucpw123!"
}
