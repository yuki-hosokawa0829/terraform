# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

variable "prefix" {
  description = "The prefix which should be used for all resources in this example"
}

variable "location" {
  description = "The Azure Region in which all resources in this example should be created."
}

variable "resource_group_name" {
  description = "The name of the Resource Group"
}

variable "nat_subnet_id" {
  description = "ID for Subnet of nat_subnet"
}

variable "admin_subnet_id" {
  description = "ID for Subnet of admin_subnet"
}

variable "local_admin_username" {
  description = "Username for the Administrator account"
}

variable "local_admin_password" {
  description = "Password for the Administrator account"
}

locals {
  vm_count = 2 # number of VMs associated with nag gateway to create
}