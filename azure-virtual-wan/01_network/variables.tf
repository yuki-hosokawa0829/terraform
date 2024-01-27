# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

variable "prefix" {
  description = "The prefix which should be used for all resources in this example"
  default     = "wan"
}

variable "location01" {
  description = "The Azure Region in which most of all resources in this example should be created."
  default     = "JapanWest"
}

variable "location02" {
  description = "The Azure Region in which a hub resources in this example should be created."
  default     = "JapanEast"
}

variable "vhub_location01_address_range" {
  description = "The address range of the virtual hub in Japan West"
  default     = "10.0.0.0/24"
}

variable "vhub_location02_address_range" {
  description = "The address range of the virtual hub in Japan East"
  default     = "10.0.1.0/24"
}

variable "network_jw_address_range" {
  description = "The address range of the virtual network in Japan West"
  default     = "192.168.0.0/24"
}

variable "network_je_address_range" {
  description = "The address range of the virtual network in Japan East"
  default     = "192.168.1.0/24"
}

variable "network_onprem_address_range" {
  description = "The address range of the virtual network on Premises"
  default     = "172.16.0.0/24"
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
  domain_controllers_jw_address_range            = cidrsubnet(var.network_jw_address_range, 1, 0)
  domain_controllers_je_address_range            = cidrsubnet(var.network_je_address_range, 1, 0)
  domain_controllers_onprem_address_range        = cidrsubnet(var.network_onprem_address_range, 2, 0)
  domain_controller_onprem_gateway_address_range = cidrsubnet(var.network_onprem_address_range, 2, 1)
  dc_jw_private_address                          = cidrhost(local.domain_controllers_jw_address_range, 4)
  dc_je_private_address                          = cidrhost(local.domain_controllers_je_address_range, 4)
  dc_onprem_private_address                      = cidrhost(local.domain_controllers_onprem_address_range, 4)
}