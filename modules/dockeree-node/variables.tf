variable "ssh_key_name" {
  description = "Name of the EC2 Key Pair to be used for SSH."
}

variable "ssh_key_path" {
  description = "Local path to the SSH key matching the key name given above."
}

variable "basion_host" {
  description = "(Optional) Host to connect to first before making the provisioning connection."
  default = ""
}

variable "name_prefix" {
  description = "Name to be used as a prefix on resource names."
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

variable "node_count" {
  description = "Number of nodes to create."
}

variable "count_offset" {
  description = "Used to offset count.index to account for the master node."
}

variable "root_volume_size" {
  description = "The size of the root volume in gigabytes."
}

variable "join_token" {
  description = "Token used in the swarm join command."
}

variable "join_address" {
  description = "IP address used in the swarm join command."
}
