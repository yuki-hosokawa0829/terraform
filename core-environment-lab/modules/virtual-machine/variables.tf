# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

variable "prefix" {
  description = "The prefix which should be used for all resources in this example"
}

variable "vmsize" {
  description = "VM Size"
}

variable "regions" {
  description = "Regional variables"
  type        = map(any)
}

variable "local_admin_username" {
  description = "local admin username"
}

variable "resource_group_name" {
  description = "Name of Resource Group"
}

# Output from network module
variable "identity1_subnet_id" {
  description = "ID for Subnet of Azure VM identity1"
}

variable "identity2_subnet_id" {
  description = "ID for Subnet of Azure VM identity2"
}

#Output from key_vault module
variable "vmpassword" {
  description = "VM Password"
}

locals {
  regions_key = [
    for k, v in var.regions : k
  ]
}