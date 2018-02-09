variable "environment" {
  description = "Name to be used as a affix on resources."
}

variable "vpc_id" {
  type = "string"
}

variable "public_subnets_cidr" {
  type = "list"
}

variable "private_subnets_cidr" {
  type = "list"
}

