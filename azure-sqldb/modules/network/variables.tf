variable "location" {
  description = "The Azure Region in which all resources will be created."
  type        = string
}

variable "prefix" {
  description = "A prefix to add to all resource names"
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group in which all resources will be created."
  type        = string
}

variable "network_range" {
  description = "The address space that is used by the virtual network."
  type        = string
}

variable "number_of_subnets" {
  description = "The number of subnets to create within the virtual network."
  type        = number
}