variable "prefix" {
  description = "The prefix which should be used for all resources in this example"
}

variable "resource_group_name" {
  description = "The name of Rsource Group"
}

variable "regions" {
  description = "Info about Regions"
}

variable "vnet_con_id" {
  description = "ID for VNet"
}

variable "subnet_con_id" {
  description = "ID for Subnet"
}

variable "subnet_private_endpoint_id" {
  description = "ID for Subnet"
}

variable "local_admin_username" {
  description = "Local Admin Username"
}

variable "local_admin_password" {
  description = "Password for Local Admin"
}

locals {
  region_key = [
    for k, v in var.regions : k
  ]
}