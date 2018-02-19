variable "ssh_key_name" {
  description = "Name of the EC2 Key Pair to be used for SSH."
}

variable "ssh_key_path" {
  description = "Local path to the SSH key matching the key name given above."
}

variable "environment" {
  description = "Name to be used as a affix on resource names"
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
  description = "Internal networks for instances that are exposed publicly."
  type        = "list"
  default     = ["10.0.0.0/25", "10.0.0.128/25"]
}

variable "private_subnets" {
  description = "Internal networks for instances that aren't exposed publicly."
  type        = "list"
  default     = ["10.0.1.0/25", "10.0.1.128/25"]
}

variable "manager_instance_type" {
  description = "EC2 instance type to use for the manager nodes"
  default = "t2.medium"
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
  default = 3
}

variable "worker_root_volume_size" {
  description = "The size of the worker node's root volume in gigabytes."
  default = 8
}

variable "dtr_instance_type" {
  description = "EC2 instance type to use for Docker Trusted Registry nodes"
  default = "t2.medium"
}

variable "dtr_node_count" {
  description = "Number of DTR nodes to create. Should be an odd number."
  default = 3
}

variable "dtr_root_volume_size" {
  description = "The size of the DTR node's root volume in gigabytes. Not used for image storage."
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

variable "minio_instance_type" {
  default = "t2.micro"
}

variable "minio_storage_size" {
  description = "Size in GB for Minio storage"
  default = 100
}

variable "minio_endpoint" {
  description = "Optional Minio endpoint address for the DTR storage backend. Example:  10.0.0.65:9000"
  default = ""
}

variable "minio_access_key" {
  default = "(Optional) Minio access key for the DTR storage backend."
}

variable "minio_secret_key" {
  default = "(Optional) Minio secret key for the DTR storage backend."
}
