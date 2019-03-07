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

variable "vsphere_cluster" {
  description = "vSphere compute cluster on which to run vms"
}

variable "vm_template" {
  description = "vSphere disk to use as a template"
}

variable "ssh_username" {
  description = "Username with passwordless sudo privileges on disk image"
}

variable "ssh_password" {
  description = "password for the account given in ssh_username"
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

variable "dtr_storage_host" {
  description = "Host with NFS share for DTR storage"
}

variable "dtr_storage_path" {
  description = "Path to NFS share on storage host"
  default = "/data/dtr"
}

variable "minio_version" {
  description = "Version of Minio to install"
}
