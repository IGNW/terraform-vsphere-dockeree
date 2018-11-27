variable "vsphere_server" {
  description = "Name of the vsphere server on which to provision vms"
}

variable "vsphere_user" {
  description = "vsphere user name"
}

variable "vsphere_password" {
  description = "vsphere password for the account given above"
}

variable "vsphere_datacenter" {
  description = "vSphere datacenter to connect to"
}

variable "vsphere_datastore" {
  description = "vsphere datastore"
}

variable "vsphere_compute_cluster" {
  description = "vSphere compute cluster to use"
}

variable "vsphere_network" {
  description = "vSphere network to which to connect vms"
}

variable "domain" {
  description = "Domain name"
}

variable "environment" {
  description = "Name to be used as a affix on resource names"
  default     = "dev"
}

variable "vsphere_folder" {
  description = "folder within vsphere to place vms"
  default = "docker-ee"
}

variable "manager_vcpu" {
  description = "Number of virtual CPUs for manager nodes"
  default = 4
}

variable "manager_memory_mb" {
  description = "Memory (in MB) for manager nodes"
  default = 4000
}

variable "manager_node_count" {
  description = "Number of manager nodes to create. Should be an odd number."
  default = 3
}

variable "manager_root_volume_size" {
  description = "The size of the manager nodes' root volume in gigabytes."
  default = 80
}

variable "worker_vcpu" {
  description = "Number of virtual CPUs for worker nodes"
  default = 4
}

variable "worker_memory_mb" {
  description = "Memory (in MB) for worker nodes"
  default = 4000
}

variable "worker_node_count" {
  description = "Number of worker nodes to create."
  default = 4
}

variable "worker_root_volume_size" {
  description = "The size of the worker nodes' root volume in gigabytes."
  default = 80
}

variable "dtr_node_count" {
  description = "Number of DTR nodes to create. Should be an odd number."
  default = 3
}

variable "dtr_vcpu" {
  description = "Number of virtual CPUs for DTR nodes"
  default = 4
}

variable "dtr_memory_mb" {
  description = "Memory (in MB) for DTR nodes"
  default = 4000
}

variable "dtr_root_volume_size" {
  description = "The size of the DTR nodes' root volume in gigabytes. Not used for image storage."
  default = 20
}

variable "ucp_admin_username" {
  description = "Username for the UCP administrator, used for the GUI login"
  default = "ucpadmin"
}

variable "ucp_admin_password" {
  description = "Password for the UCP administrator, used for the GUI login"
  default = "ucpw123!"
}

variable "vm_template" {
  description = "VM template to use"
  default = "CentOS_7_Template"
}

variable "terraform_password" {
  description = "password for the terraform user account (for ssh)"
}

variable "minio_vcpu" {
  description = "Number of virtual CPUs for DTR nodes"
  default = 4
}

variable "minio_memory_mb" {
  description = "Memory (in MB) for DTR nodes"
  default = 4000
}

variable "minio_root_volume_size" {
  description = "The size of the worker nodes' root volume in gigabytes."
  default = 80
}

variable "minio_storage_size" {
  description = "Size in GB for Minio storage"
  default = 100
}
