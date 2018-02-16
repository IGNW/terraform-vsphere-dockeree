variable "ssh_key_name" {
  description = "Name of the EC2 Key Pair to be used for SSH."
}

variable "ssh_key_path" {
  description = "Local path to the SSH key matching the key name given above."
}

variable "bastion_host" {
  description = "Host to connect to first before making the provisioning connection."
}

variable "environment" {
  description = "Name to be used as a affix on resource names"
}

variable "vpc_security_group_ids" {
  description = "A list of security group IDs to associate with."
  type = "list"
}

variable "subnet_ids" {
  description = "The VPC subnet IDs to launch instances in."
  type = "list"
}

variable "ami_id" {
  description = "Amazon Machine Image ID to use for creating EC2 instances."
}

variable "instance_type" {
  description = "EC2 instance type to use for this node."
}

variable "minio_storage_size" {
  description = "Size in GB for Minio storage"
}

variable "minio_endpoint" {
  description = "Optional user-provided Minio endpoint address"
}
