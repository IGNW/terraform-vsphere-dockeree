variable "lb_count" {
  default = "2"
  description = "Number of load balancers"
}

variable "lb_ips" {
  type = "list"
  description = "List of load balancer IPs"
}

variable "ssh_username" {
  description = "Username to use when connecting to load balancer hosts"
}

variable "ssh_password" {
  description = "Password to use when connecting to load balancer hosts"
}

variable "dtr_ip0" {
  description = "IP addreess of DTR node 0"
}

variable "dtr_ip1" {
  description = "IP addreess of DTR node 1"
}

variable "dtr_ip2" {
  description = "IP addreess of DTR node 2"
}

variable "ucp_ip0" {
  description = "IP addreess of DTR node 0"
}

variable "ucp_ip1" {
  description = "IP addreess of DTR node 0"
}

variable "ucp_ip2" {
  description = "IP addreess of DTR node 0"
}

variable "script_path" {
  description = "Path to upload scripts to"
  default = "/opt/terraform"
}
