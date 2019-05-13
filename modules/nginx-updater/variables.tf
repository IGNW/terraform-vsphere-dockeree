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

variable "dtr_ips" {
  type = "list"
  description = "IP addresses of DTR nodes"
}

variable "ucp_ips" {
  type = "list"
  description = "IP addresses of UCP nodes"
}

variable "worker_ips" {
  type = "list"
  description = "IP addresses of UCP nodes"
}

variable "script_path" {
  description = "Path on load balancers to which scripts and templated files should be uploaded"
  default = "/tmp"
}
