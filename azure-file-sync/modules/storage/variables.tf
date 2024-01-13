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

variable "resource_group_id" {
  description = "ID of the resource group"
}

variable "subnet_id" {
  description = "Subnet ID for the File Server"
}

variable "subnet_onprem_id" {
  description = "Subnet ID for the File Server on premise"
}