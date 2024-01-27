# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

variable "prefix" {
  description = "The prefix which should be used for all resources in this example"
  default     = "glb"
}

variable "regions" {
  description = "Regional variables"
  type        = map(any)
  default = {

    region1 = {
      location = "uksouth"
      cidr     = "10.10.0.0/16"
    }

    region2 = {
      location = "japaneast"
      cidr     = "10.20.0.0/16"
    }

    region3 = {
      location = "japanwest"
      cidr     = "10.30.0.0/16"
    }

  }

}

variable "local_admin_username" {
  description = "local admin username"
  default     = "azureadmin"
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