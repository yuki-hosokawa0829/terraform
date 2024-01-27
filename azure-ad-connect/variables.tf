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
  default     = "azureadmin"
}

variable "local_admin_password" {
  description = "local admin password"
  default     = "P@ssw0rd0123"
  sensitive   = true
}

variable "domain_user_upn" {
  description = "Username for domain join (do not include domain name as this is appended)"
  default     = "azureadmin"
}

variable "domain_user_password" {
  description = "Password of the user to authenticate with the domain"
  default     = "P@ssw0rd0123"
  sensitive   = true
}

variable "usr_subscription_id" {
  description = "The Azure Subscription ID"
  default     = "your-azure-subscription-id"
}

variable "usr_tenant_id" {
  description = "Tenant ID"
  default     = "your-entra-id-tenant-id"
}

variable "usr_client_id" {
  description = "Service Principal ID"
  default     = "your-terraform-service-principal-id"
}

variable "usr_client_secret" {
  description = "Password for the Administrator account"
  default     = "your-terraform-service-principal-secrets"
}

locals {
  subnet_address_range        = cidrsubnet(var.vnet_address_range, 8, 0)
  member_subnet_address_range = cidrsubnet(var.vnet_address_range, 8, 1)
  vm_dc_private_ip_address    = cidrhost(local.subnet_address_range, 4)
  vm_aadc_private_ip_address  = cidrhost(local.subnet_address_range, 5)
}