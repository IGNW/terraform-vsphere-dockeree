variable "environment" {
  description = "Name to be used as a affix on resource names"
}

variable "vpc_id" {}

variable "dns_zone" {
  description = "Zone managed by Amazon Route 53 to be used for the load balancers' DNS name"
}

variable "ucp_dns_name" {
  description = "DNS name for the load balancer in front of the UCP manager."
}

variable "dtr_dns_name" {
  description = "DNS name for the load balancer in front of the DTR nodes."
}

variable "public_subnet_ids" {
  type = "list"
}
variable "ucp_mgr_instance_ids" {
  type = "list"
}

variable "ucp_node_count" {
  description = "Number of UCP manager nodes"
}

variable "dtr_instance_ids" {
  type = "list"
}

variable "dtr_node_count" {
  description = "Number of DTR nodes"
}
