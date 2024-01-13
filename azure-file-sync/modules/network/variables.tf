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

variable "virtual_network_onprem_address_space" {
  description = "IP Address Space of On-Premise Network"
}

locals {
  subnet_name                          = join("-", [var.prefix, "subnet"])
  subnet_name_onprem                   = join("-", [var.prefix, "subnet-onprem"])
  subnet_name_dc                       = join("-", [var.prefix, "subnet-dc"])
  domain_controller_subnet_prefix      = cidrsubnet("${var.virtual_network_address_space}", 2, 0)
  file_server_subnet_prefix            = cidrsubnet("${var.virtual_network_address_space}", 2, 1)
  file_server_onprem_subnet_prefix     = cidrsubnet("${var.virtual_network_onprem_address_space}", 2, 0)
  domain_controller_private_ip_address = cidrhost("${local.domain_controller_subnet_prefix}", 4)
}