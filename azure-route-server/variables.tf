# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

variable "prefix" {
  description = "The prefix which should be used for all resources in this example"
  default     = "ars"
}

variable "location" {
  description = "The Azure Region in which most of all resources in this example should be created."
  default     = "JapanWest"
}

variable "vnet_address_range" {
  description = "The address range of the virtual network"
  default     = "10.0.0.0/16"
}

variable "vnet_peer_address_range" {
  description = "The address range of the virtual network peer"
  default     = "10.1.0.0/16"
}

variable "vnet_vpn_address_range" {
  description = "The address range of the virtual network vnp"
  default     = "10.2.0.0/16"
}

variable "vnet_onprem_address_range" {
  description = "The address range of the virtual network onprem"
  default     = "192.168.0.0/24"
}

variable "vnet_onprem02_address_range" {
  description = "The address range of the virtual network onprem02"
  default     = "192.168.1.0/24"
}

variable "local_admin_username" {
  description = "local admin username"
  default     = "ppt-admin"
}

variable "local_admin_password" {
  description = "local admin password"
  default     = "P@ssw0rd0123"
  sensitive   = true
}

variable "usr_subscription_id" {
  description = "The Azure Subscription ID"
  default     = "4d55c914-726b-4a03-b002-54c4bf217ad5"
}

variable "usr_tenant_id" {
  description = "Tenant ID"
  default     = "9781ab08-ef7d-4e4f-b6f0-c595b7a023cb"
}

variable "usr_client_id" {
  description = "Service Principal ID"
  default     = "78fedf0d-7c87-4643-b4dc-13062b0752ed"
}

variable "usr_client_secret" {
  description = "Password for the Administrator account"
  default     = "eQ28Q~S5MT4nodAKe3MrLD_mnVQyb7zXP3HanaxE"
}

locals {
  # vnet parameter
  vnet_subnet_address_range              = cidrsubnet(var.vnet_address_range, 8, 0)
  vnet_gateway_subnet_address_range      = cidrsubnet(var.vnet_address_range, 8, 1)
  vnet_route_server_subnet_address_range = cidrsubnet(var.vnet_address_range, 8, 2)
  vnet_as_number                         = "65515"
  # vnet peer parameter
  vnet_peer_subnet_address_range         = cidrsubnet(var.vnet_peer_address_range, 8, 0)
  vnet_peer_gateway_subnet_address_range = cidrsubnet(var.vnet_peer_address_range, 8, 1)
  vnet_peer_as_number                    = "65500"
  # vnet vnp parameter
  vnet_vpn_subnet_address_range         = cidrsubnet(var.vnet_vpn_address_range, 8, 0)
  vnet_vpn_gateway_subnet_address_range = cidrsubnet(var.vnet_vpn_address_range, 8, 1)
  vnet_vpn_as_number                    = "65100"
  # vnet onprem parameter
  vnet_onprem_subnet_address_range         = cidrsubnet(var.vnet_onprem_address_range, 3, 0)
  vnet_onprem_gateway_subnet_address_range = cidrsubnet(var.vnet_onprem_address_range, 3, 1)
  vnet_onprem_as_number                    = "65000"
  # vnet onprem02 parameter
  vnet_onprem02_subnet_address_range         = cidrsubnet(var.vnet_onprem02_address_range, 3, 0)
  vnet_onprem02_gateway_subnet_address_range = cidrsubnet(var.vnet_onprem02_address_range, 3, 1)
}