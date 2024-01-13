variable "prefix" {
  description = "The prefix which should be used for all resources in this example"
}

variable "resource_group_name" {
  description = "The name of Rsource Group"
}

variable "regions" {
  description = "Info about Regions"
}

variable "subnet_bastion_id" {
  description = "ID for Bastion Subnet"
}

locals {
  region_key = [
    for k, v in var.regions : k
  ]
}