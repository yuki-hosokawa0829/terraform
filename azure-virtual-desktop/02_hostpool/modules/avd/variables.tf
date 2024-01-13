# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

variable "prefix" {
  description = "The prefix which should be used for all resources in this example"
}

variable "location" {
  description = "The Azure Region in which all resources in this example should be created."
}

variable "avd_location" {
  description = "The Azure Region in which Hostpool and workspace should be created."
}

variable "resource_group_name" {
  description = "Name of the Resource Group"
}

variable "workspace_name" {
  description = "Name of the Azure Virtual Desktop workspace"
}

variable "hostpool_name" {
  description = "Name of the Azure Virtual Desktop host pool"
}

variable "rfc3339" {
  description = "Registration token expiration"
}