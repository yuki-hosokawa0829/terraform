# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

variable "location" {
  description = "The Azure Region in which resources in this example should be created."
}

variable "resource_group_name" {
  description = "The name of the resource group"
}

variable "vnet_subnet_id" {
  description = "ID for the vnet subnet"
}
variable "vnet_peer_subnet_id" {
  description = "ID for the vnet peer subnet"
}

variable "vnet_vpn_subnet_id" {
  description = "ID for the vnet vpn subnet"
}

variable "vnet_onprem_subnet_id" {
  description = "ID for the vnetonprem subnet"
}

variable "local_admin_username" {
  description = "local admin username"
}

variable "local_admin_password" {
  description = "local admin password"
}

locals {
  subnet_ids     = [var.vnet_subnet_id, var.vnet_peer_subnet_id, var.vnet_onprem_subnet_id, var.vnet_vpn_subnet_id]
  pfx            = ["vnet", "peer", "onprem", "vpn"]
  subnet_ids_map = zipmap(local.pfx, local.subnet_ids)
}
