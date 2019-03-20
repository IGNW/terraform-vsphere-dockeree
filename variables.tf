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

variable "manager_vsphere_cluster" {
  description = "vSphere compute cluster to use for manager and DTR nodes"
}

variable "manager_vsphere_network" {
  description = "vSphere network to which to connect manager and dtr vms"
}

variable "worker_a_vsphere_cluster" {
  description = "vSphere compute cluster to use for worker group A"
}

variable "worker_a_vsphere_network" {
  description = "vSphere network to which to connect vms for worker group A"
}

variable "worker_a_label" {
  description = "Label to apply to nodes in worker group 1"
  default = "a"
}
variable "worker_b_vsphere_cluster" {
  description = "vSphere compute cluster to use for worker group A"
}

variable "worker_b_vsphere_network" {
  description = "vSphere network to which to connect vms for worker group B"
  default = ""
}

variable "worker_b_label" {
  description = "Label to apply to nodes in worker group 2"
  default = "b"
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
  default = 6000
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
  default = 6000
}

variable "worker_a_node_count" {
  description = "Number of worker nodes to create in group A."
  default = 4
}

variable "worker_b_node_count" {
  description = "Number of worker nodes to create in group B."
  default = 0
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
  default = 6000
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
}

variable "ssh_username" {
  description = "Username with passwordless sudo privileges on disk image"
}

variable "ssh_password" {
  description = "password for the account given in ssh_username"
}

variable "dtr_nfs_url" {
  description = "URL of a nfs share to use for DTR storage"
  default = ""
}

variable "ucp_version" {
  description = "Version of the UCP to install"
  default = "3.1.3"
}

variable "dtr_version" {
  description = "Version of the DTR to install"
  default = "2.6.2"
}

variable "consul_version" {
  description = "Version of Consul to install"
  default = "1.4.2"
}

variable "thin_provisioned" {
  description = "Was the template created using thin provisioning (true/false)"
  default = "true"
}

variable "eagerly_scrub" {
  description = "Was the template created using the eagerly_scrub option (true/false)"
  default = "false"
}

variable "scsi_type" {
  default = "pvscsi"
}

variable "script_path" {
  description = "Location on VM to upload scripts for inline execution"
  default = "/tmp"
}
