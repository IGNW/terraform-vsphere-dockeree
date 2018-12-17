variable "environment" {
  description = "Name to be used as a affix on resource names"
}

variable "node_vcpu" {
  description = "Virtual CPUs to configure for this node"
}

variable "node_memory" {
  description = "Memory in MB to configure for this node"
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

variable "terraform_password" {
  description = "password to use when ssh'ing as 'terraform'"
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

variable "dtr_storage_host" {
  description = "Host with NFS share for DTR storage"
}

variable "dtr_storage_path" {
  description = "Path to NFS share on storage host"
  default = "/data/dtr"
}

variable "docker_registry" {
  description = "Path from which to pull docker images"
}
