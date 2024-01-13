# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

variable "prefix" {
  description = "The prefix which should be used for all resources in this example"
}

variable "location01" {
  description = "The Azure Region in which most of all resources in this example should be created."
}

variable "location02" {
  description = "The Azure Region in which a hub resources in this example should be created."
}

variable "resource_group_name" {
  description = "The name of the resource group"
}

variable "vhub_location01_address_range" {
  description = "The address range of the virtual hub in Japan West"
}

variable "vhub_location02_address_range" {
  description = "The address range of the virtual hub in Japan East"
}

variable "network_jw_address_range" {
  description = "The address range of the virtual network in Japan West"
}

variable "network_je_address_range" {
  description = "The address range of the virtual network in Japan East"
}

variable "network_onprem_address_range" {
  description = "The address range of the virtual network on Premises"
}

variable "domain_controllers_jw_address_range" {
  description = "The address range of the subnet in Japan West"
}

variable "domain_controllers_je_address_range" {
  description = "The address range of the subnet in Japan East"
}

variable "domain_controllers_onprem_address_range" {
  description = "The address range of the subnet on Premises"
}

variable "domain_controllers_gateway_address_range" {
  description = "The address range of the GatewaySubnet on Premises"
}

variable "dc_jw_private_address" {
  description = "Private IP Address of Domain Controller in Japan West"
}

variable "dc_je_private_address" {
  description = "Private IP Address of Domain Controller in Japan East"
}

variable "dc_onprem_private_address" {
  description = "Private IP Address of Domain Controller on Premises"
}

variable "instance_0_pip" {
  description = "Public IP Address of VPN Gateway in Azure Virtual WAN"
}

variable "instance_1_pip" {
  description = "Public IP Address of VPN Gateway in Azure Virtual WAN"
}