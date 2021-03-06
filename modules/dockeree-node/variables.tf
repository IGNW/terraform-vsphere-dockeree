variable "environment" {
  description = "Name to be used as a affix on resource names"
}

variable "node_type" {
  description = "Short code indicating the role of this node."
}

variable "ssh_username" {
  description = "Username with passwordless sudo privileges on disk image"
}

variable "ssh_password" {
  description = "password for the account given in ssh_username"
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

variable "vsphere_cluster" {
  description = "vSphere compute cluster on which to run vms"
}

variable "vm_template" {
  description = "vSphere template to use for configuring disk"
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

variable "thin_provisioned" {
  description = "Was the template created using thin provisioning (true/false)"
}

variable "eagerly_scrub" {
  description = "Was the template created using the eagerly_scrub option (true/false)"
}

variable "scsi_type" {
  default = "pvscsi"
}
