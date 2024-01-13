# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

provider "azurerm" {
  features {}
  subscription_id = var.usr_subscription_id
  tenant_id       = var.usr_tenant_id
  client_id       = var.usr_client_id
  client_secret   = var.usr_client_secret
}

data "azurerm_resource_group" "rg" {
  name = "${var.prefix}-rg"
}

module "network" {
  source = "./modules/network"

  location                                = var.location
  prefix                                  = var.prefix
  resource_group_name                     = data.azurerm_resource_group.rg.name
  vnet_address_range                      = var.vnet_address_range
  domain_controllers_subnet_address_range = local.domain_controllers_subnet_address_range
  sessionhost_subnet_address_range        = local.sessionhost_subnet_address_range
  domain_controller_private_ip_address    = local.domain_controller_private_ip_address
}

module "azure_virtual_desktop" {
  source = "./modules/avd"

  location            = var.location
  avd_location        = var.avd_location
  prefix              = var.prefix
  resource_group_name = data.azurerm_resource_group.rg.name
  workspace_name      = var.workspace_name
  hostpool_name       = var.hostpool_name
  rfc3339             = local.expiration_date
}

module "session_host" {
  source = "./modules/sessionhost"

  location              = var.location
  prefix                = var.prefix
  resource_group_name   = data.azurerm_resource_group.rg.name
  sessionhost_subnet_id = module.network.sessionhost_subnet_id
  rdsh_count            = var.rdsh_count
  domain_name           = var.domain_name
  domain_user_upn       = var.domain_user_upn
  domain_user_password  = var.domain_user_password
  domain_path           = var.domain_path
  ou_path               = var.ou_path
  local_admin_username  = var.local_admin_username
  local_admin_password  = var.local_admin_password
  hostpool_name         = var.hostpool_name
  registration_token    = module.azure_virtual_desktop.registration_token
  sessionhost_vm_size   = var.sessionhost_vm_size
}

module "domain_controller" {
  source = "./modules/domain-controller"

  location                             = var.location
  prefix                               = var.prefix
  resource_group_name                  = data.azurerm_resource_group.rg.name
  domain_controller_private_ip_address = local.domain_controller_private_ip_address
  aadc_server_private_ip_address       = local.aadc_server_private_ip_address
  domain_controllers_subnet_id         = module.network.domain_controllers_subnet_id
  domain_name                          = var.domain_name
  domain_path                          = var.domain_path
  ou_path                              = var.ou_path
  domain_netbios_name                  = var.domain_netbios_name
  domain_user_upn                      = var.domain_user_upn
  domain_user_password                 = var.domain_user_password
  aad_domain                           = var.aad_domain
}