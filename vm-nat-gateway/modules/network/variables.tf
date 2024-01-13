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

variable "virtual_network_address_space" {
  description = "IP Address Space of Virtual Network"
}

locals {
  subnet_name_nat     = join("-", [var.prefix, "subnet-nat"])
  subnet_name_admin   = join("-", [var.prefix, "subnet-admin"])
  nat_subnet_prefix   = cidrsubnet("${var.virtual_network_address_space}", 3, 0)
  admin_subnet_prefix = cidrsubnet("${var.virtual_network_address_space}", 3, 1)
}