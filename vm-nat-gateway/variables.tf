# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

variable "prefix" {
  description = "The prefix which should be used for all resources in this example"
  default     = "nat"
}

variable "location" {
  description = "The Azure Region in which most of all resources in this example should be created."
  default     = "JapanWest"
}

variable "virtual_network_address_space" {
  description = "IP Address Space of Virtual Network"
  default     = "10.0.0.0/24"
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