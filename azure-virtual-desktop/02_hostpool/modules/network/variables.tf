# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

variable "prefix" {
  description = "The prefix which should be used for all resources in this example"
}

variable "location" {
  description = "The Azure Region in which all resources in this example should be created."
}

variable "resource_group_name" {
  description = "The name of the resource group"
}

variable "vnet_address_range" {
  description = "The address range of the virtual network"
}

variable "domain_controllers_subnet_address_range" {
  description = "The address range of the domain controllers subnet"
}

variable "sessionhost_subnet_address_range" {
  description = "The address range of the session host subnet"
}

variable "domain_controller_private_ip_address" {
  description = "The private IP address of the domain controller"
}