variable "cidr_block" {

}

variable "enable_dns_support" {
default = "true"
}

variable "enable_dns_hostnames" {
 default = "true"
}

variable "common_tags" {
type = map
default = {} # this indicates tags are optional, always good practice to give default values
}

variable "vpc_tags" {
    type = map
    default = {}
}

variable "project_name" {
  
}

variable "gw_tags" {
    type = map
    default = {}
}

variable "public_cidr_block"{

validation {
    condition     = length(var.public_cidr_block) == 2 # will allow values only when this condition is true
    error_message = "Please enter only 2 cidr values."
  }

}

variable "private_cidr_block"{

validation {
    condition     = length(var.private_cidr_block) == 2 # will allow values only when this condition is true
    error_message = "Please enter only 2 cidr values."
  }

}

variable "database_cidr_block"{

validation {
    condition     = length(var.database_cidr_block) == 2 # will allow values only when this condition is true
    error_message = "Please enter only 2 cidr values."
  }

}
variable "public_route_table_tags" {
    type = map
    default = {}
}

variable "nat_gateway_tags" {
    type = map
    default = {}
}

variable "private_route_table_tags" {
    type = map
    default = {}
}

variable "database_route_table_tags" {
    type = map
    default = {}
}
variable "database_route_table_group_tags" {
    type = map
    default = {}
}

