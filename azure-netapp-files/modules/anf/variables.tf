variable "prefix" {
  description = "The prefix which should be used for all resources in this example"
}

variable "location" {
  description = "The Azure Region in which all resources in this example should be created."
}

variable "resource_group_name" {
  description = "The name of the resource group"
}

variable "admin_username" {
  description = "Username for the Administrator account"
}

variable "admin_password" {
  description = "Password for the Administrator account"
}

variable "domain_controller_private_ip_address" {
  description = "The private IP address of the domain controller"
}

variable "domain_member01_private_ip_address" {
  description = "The private IP address of the domain member01"
}

variable "anf_subnet_id" {
  description = "Subnet ID for the ANF volume"
}