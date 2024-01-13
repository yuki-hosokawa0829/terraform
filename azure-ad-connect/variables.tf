# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

variable "prefix" {
  description = "The prefix which should be used for all resources in this example"
  default     = "aadc"
}

variable "location" {
  description = "The Azure Region in which most of all resources in this example should be created."
  default     = "JapanWest"
}

variable "vnet_address_range" {
  description = "The address range of the virtual network"
  default     = "10.0.0.0/16"
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

variable "domain_user_upn" {
  description = "Username for domain join (do not include domain name as this is appended)"
  default     = "ppt-admin"
}

variable "domain_user_password" {
  description = "Password of the user to authenticate with the domain"
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
  subnet_address_range        = cidrsubnet(var.vnet_address_range, 8, 0)
  member_subnet_address_range = cidrsubnet(var.vnet_address_range, 8, 1)
  vm_dc_private_ip_address    = cidrhost(local.subnet_address_range, 4)
  vm_aadc_private_ip_address  = cidrhost(local.subnet_address_range, 5)
}