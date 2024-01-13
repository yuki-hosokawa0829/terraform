variable "location" {
  description = "The Azure Region in which all resources in this example should be created."
}

variable "resource_group_name" {
  description = "The name of the resource group in which to create the virtual network."
}

variable "subnet_id" {
  description = "The ID of the subnet in which to create the virtual network."
}

variable "subnet_onprem_id" {
  description = "The ID of the subnet in which to create the virtual network."
}

variable "admin_username" {
  description = "The username of the local administrator to create on the virtual machine."
}

variable "admin_password" {
  description = "The password of the local administrator to create on the virtual machine."
}