# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

variable "prefix" {
  description = "The prefix which should be used for all resources in this example"
}

variable "regions" {
  description = "Regional variables"
  type        = map(any)
}

variable "resource_group_name" {
  description = "Name of Resource Group"
}

# Output from azure_virtual_wan module
variable "virtual_hub_id" {
  description = "ID for Azure Virtual WAN Hub"
}

/* variable "usr_tenant_id" {
  description = "Tenant ID"
} */

locals {
  regions_key = [
    for k, v in var.regions : k
  ]
}