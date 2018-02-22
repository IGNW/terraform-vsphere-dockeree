variable "ssh_key_name" {
  description = "Name of the EC2 Key Pair to be used for SSH."
}

variable "ssh_key_path" {
  description = "Local path to the SSH key matching the key name given above."
}

variable "bastion_host" {
  description = "Host to connect to first before making the provisioning connection."
  default = ""
}

variable "environment" {
  description = "Name to be used as a affix on resource names"
}

variable "node_type" {
  description = "Short code indicating the role of this node."
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

variable "root_volume_size" {
  description = "The size of the root volume in gigabytes."
}

variable "consul_secret" {
  description = "The secret key to use for encryption of Consul network traffic"
  type = "string"
}

variable "iam_profile_id" {
  description = "Optional IAM Instance Profile ID to assign to these instances"
  default = ""
}

variable "ucp_admin_username" {
  description = "Username for the UCP administrator account."
  default = ""
}

variable "ucp_admin_password" {
  description = "Password for the UCP administrator acount."
  default = ""
}

variable "ucp_dns_name" {
  description = "DNS name for the load balancer in front of the UCP manager."
  default     = ""
}

variable "dtr_dns_name" {
  description = "DNS name for the load balancer in front of the DTR nodes."
  default     = ""
}

variable "minio_endpoint" {
  default = ""
}
variable "minio_access_key" {
  default = ""
}
variable "minio_secret_key" {
  default = ""
}
