# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

provider "azurerm" {
  features {}
  subscription_id = var.usr_subscription_id
  tenant_id       = var.usr_tenant_id
  client_id       = var.usr_client_id
  client_secret   = var.usr_client_secret
}

resource "azurerm_resource_group" "rg" {
  location = var.location
  name     = "${var.prefix}-rg"
}

module "network" {
  source = "./modules/network"

  prefix                      = var.prefix
  location                    = var.location
  resource_group_name         = azurerm_resource_group.rg.name
  vnet_address_range          = var.vnet_address_range
  subnet_address_range        = local.subnet_address_range
  member_subnet_address_range = local.member_subnet_address_range
  vm_dc_private_ip_address    = local.vm_dc_private_ip_address
}

module "aadc_server" {
  source = "./modules/servers"

  prefix                        = var.prefix
  location                      = var.location
  resource_group_name           = azurerm_resource_group.rg.name
  subnet_id                     = module.network.subnet_id
  member_subnet_id              = module.network.member_subnet_id
  vm_dc_private_ip_address      = local.vm_dc_private_ip_address
  vm_aadc_private_ip_address    = local.vm_aadc_private_ip_address
  local_admin_username          = var.local_admin_username
  local_admin_password          = var.local_admin_password
  active_directory_domain_name  = "${var.prefix}.local"
  active_directory_netbios_name = upper(var.prefix)
  domain_user_upn               = var.domain_user_upn
  domain_user_password          = var.domain_user_password
}
