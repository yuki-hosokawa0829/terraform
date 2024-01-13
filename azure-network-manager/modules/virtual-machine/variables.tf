variable "prefix" {
  description = "The prefix which should be used for all resources in this example"
}

variable "location" {
  description = "The Azure Region in which all resources in this example should be created."
}

variable "resource_group_name" {
  description = "The name of the resource group in which all resources in this example should be created."
}

variable "admin_username" {
  description = "Username for the Administrator account"
}

variable "admin_password" {
  description = "Password for the Administrator account"
}

variable "subnet_id01" {
  description = "The ID of the subnet in which the VM should be created."
}

variable "subnet_id02" {
  description = "The ID of the subnet in which the VM should be created."
}

variable "subnet_id03" {
  description = "The ID of the subnet in which the VM should be created."
}