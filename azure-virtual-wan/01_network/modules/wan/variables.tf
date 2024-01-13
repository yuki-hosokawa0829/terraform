# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

variable "prefix" {
  description = "The prefix which should be used for all resources in this example"
}

variable "resource_group_name" {
  description = "The name of resource group"
}

variable "vhub_location01_address_range" {
  description = "The address range of the virtual hub in Japan West"
}

variable "vhub_location02_address_range" {
  description = "The address range of the virtual hub in Japan East"
}

variable "location01" {
  description = "The Azure Region in which most of all resources in this example should be created."
}

variable "location02" {
  description = "The Azure Region in which a hub resources in this example should be created."
}

variable "network_onprem_address_range" {
  description = "The address range of the virtual network on Premises"
}

variable "network_jw_id" {
  description = "ID for the virtual network in Japan West"
}

variable "network_je_id" {
  description = "ID for the virtual network in Japan East"
}

variable "vpngw_pip" {
  description = "IP address of the Virtual Network Gateway"
}

variable "dc_jw_private_address" {
  description = "Private IP address of the domain controller in Japan West"
}