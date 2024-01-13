variable "prefix" {
  description = "The prefix which should be used for all resources in this example"
}

variable "location" {
  description = "The Azure Region in which all resources in this example should be created."
}

variable "resource_group_name" {
  description = "The name of the resource group in which all resources in this example should be created."
}

locals {
  num01 = 3 # Number of mesh virtual networks to create
  num02 = 3 # Number of hub-and-spoke virtual networks to create
  num03 = 3 # Number of virtual machines to create
}