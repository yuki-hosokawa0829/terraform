# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

variable "prefix" {
  description = "The prefix which should be used for all resources in this example"
  default     = "avd"
}

variable "location" {
  description = "The Azure Region in which all resources in this example should be created."
  default     = "JapanWest"
}

variable "avd_location" {
  description = "The Azure Region in which Hostpool and workspace should be created."
  default     = "westus2"
}

variable "workspace_name" {
  description = "Name of the Azure Virtual Desktop workspace"
  default     = "AVD TF Workspace"
}

variable "hostpool_name" {
  description = "Name of the Azure Virtual Desktop host pool"
  default     = "AVD-TF-HP"
}

variable "rdsh_count" {
  default = 2
}

variable "vnet_address_range" {
  description = "The address range of the virtual network"
  default     = "10.0.0.0/16"
}

variable "domain_name" {
  description = "Name of the domain to join"
  default     = "infra.local"
}

variable "domain_path" {
  description = "dc=yourdomain,dc=com"
  default     = "dc=infra,dc=local"
}

variable "ou_path" {
  description = "OU for session host"
  default     = "SessionHost"
}

variable "domain_netbios_name" {
  description = "The netbios name of the Active Directory domain, for example `consoto`"
  default     = "INFRA"
}

variable "domain_user_upn" {
  description = "Username for domain join (do not include domain name as this is appended)"
  default     = "azureadmin" # do not include domain name as this is appended
}

variable "domain_user_password" {
  description = "Password of the user to authenticate with the domain"
  default     = "P@ssw0rd0123"
  sensitive   = true
}

variable "sessionhost_vm_size" {
  description = "Size of the sessionhost machine to deploy"
  default     = "Standard_DS2_v2"
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

variable "aad_domain" {
  description = "Azure AD Domain"
  default     = "yourazureaddomain.onmicrosoft.com"
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
  expiration_date                         = timeadd(timestamp(), "720h")
  domain_controllers_subnet_address_range = cidrsubnet(var.vnet_address_range, 8, 0)
  sessionhost_subnet_address_range        = cidrsubnet(var.vnet_address_range, 8, 1)
  domain_controller_private_ip_address    = cidrhost(local.domain_controllers_subnet_address_range, 4)
  aadc_server_private_ip_address          = cidrhost(local.domain_controllers_subnet_address_range, 5)
}