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

variable "domain" {
  description = "Domain name"
}

variable "node_vcpu" {
  description = "Virtual CPUs to configure for this node"
}

variable "node_memory" {
  description = "Memory in MB to configure for this node"
}

variable "node_count" {
  description = "Number of nodes to create."
}

variable "root_volume_size" {
  description = "The size of the root volume in gigabytes."
}

variable "vsphere_datastore" {
  description = "vSphere datastore to use for vms"
}

variable "vsphere_compute_cluster" {
  description = "vSphere compute cluster on which to run vms"
}

variable "disk_template" {
  description = "vSphere disk to use as a template"
}

variable "vsphere_network" {
  description = ""
}

variable "vsphere_folder" {
  description = "vSphere folder in which to place vms"
}

variable "vsphere_datacenter" {
  description = ""
}

variable "consul_secret" {
  description = "The secret key to use for encryption of Consul network traffic"
  type = "string"
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
