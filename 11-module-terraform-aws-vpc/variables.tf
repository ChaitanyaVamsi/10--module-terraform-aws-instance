variable "vpc_cidr" {
  type        = string
  description = "enter cidr block range"
}

variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "vpc_tags" {
  type    = map(any)
  default = {}
}

variable "igw_tags" {
  type    = map(any)
  default = {}
}

variable "public_subent_cidrs" {
  type = list(any)
}

variable "public_subnet_tags" {
  type = map(any)
  default = {

  }
}

variable "private_subent_cidrs" {
  type = list(any)
}

variable "private_subnet_tags" {
  type = map(any)
  default = {

  }
}

variable "database_subent_cidrs" {
  type = list(any)
}

variable "database_subnet_tags" {
  type = map(any)
  default = {

  }
}

variable "public_routeTable_tags" {
  type = map(any)
  default = {

  }
}

variable "private_routeTable_tags" {
  type = map(any)
  default = {

  }
}

variable "database_routeTable_tags" {
  type = map(any)
  default = {

  }
}

variable "elastic_ip_tags" {
  type = map(any)
  default = {

  }
}

variable "nat_gateway_tags" {
  type = map(any)
  default = {

  }
}

variable "is_peering_required" {
  type    = bool
  default = true
}
