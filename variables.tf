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

variable "manager_vsphere_datastore" {
  description = "vsphere datastore for manager and DTR nodes"
}

variable "manager_vsphere_cluster" {
  description = "vSphere compute cluster to use for manager and DTR nodes"
}

variable "manager_vsphere_network" {
  description = "vSphere network to which to connect manager and dtr vms"
}

variable "manager_vm_template" {
  description = "VM template to use for manager nodes"
}

variable "worker_a_label" {
  description = "Label to apply to nodes in worker group 1"
  default = "a"
}

variable "worker_a_vsphere_datastore" {
  description = "vsphere datastore for worker group A"
}

variable "worker_a_vsphere_cluster" {
  description = "vSphere compute cluster to use for worker group A"
}

variable "worker_a_vsphere_network" {
  description = "vSphere network to which to connect vms for worker group A"
}

variable "worker_a_vm_template" {
  description = "VM template to use for vms in worker group A"
}

variable "worker_b_label" {
  description = "Label to apply to nodes in worker group N"
  default = "b"
}

variable "worker_b_vsphere_datastore" {
  description = "vsphere datastore for worker group B"
}

variable "worker_b_vsphere_cluster" {
  description = "vSphere compute cluster to use for worker group B"
}

variable "worker_b_vsphere_network" {
  description = "vSphere network to which to connect vms for worker group B"
  default = ""
}

variable "worker_b_vm_template" {
  description = "VM template to use for vms in worker group B"
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
  default="latest"
}

variable "dtr_version" {
  description = "Version of the DTR to install"
  default="latest"
}

variable "consul_version" {
  description = "Version of Consul to install"
  default="latest"
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

variable "run_init" {
  description = "Set to 0 to skip running init scripts"
  default = "1"
}

variable "dockeree_license" {
  description = "Docker EE lilcense text (JSON)"
  default = ""
}

variable "load_balancer_count" {
  default = "0"
  description = "Number of load balancers"
}

variable "load_balancer_ips" {
  type = "list"
  description = "List of load balancer IPs"
  default = ["0.0.0.0"]
}

variable "load_balancer_username" {
  description = "Username to use when connecting to load balancer hosts"
  default = ""
}

variable "load_balancer_password" {
  description = "Password to use when connecting to load balancer hosts"
  default = ""
}

variable "load_balancer_script_path" {
  description = "Path to upload scripts and files on the load balancers"
  default = "/tmp"
}

variable "ucp_fqdn" {
  description = "FQDN of the UCP load balancer"
}

variable "dtr_fqdn" {
  description = "FQND of the DTR load balancer"
}

variable "use_custom_ssl" {
  description = "Set to 1 to use custom ssl certs"
  default = "0"
}

variable "ssl_ca_file" {
  description = "CA Cert"
}

variable "ssl_cert_file" {
  description = "SSL Cert"
}

variable "ssl_key_file" {
  description = "SSL Key"
}
