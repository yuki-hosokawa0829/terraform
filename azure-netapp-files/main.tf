# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

provider "azurerm" {
  features {}
  subscription_id = var.usr_subscription_id
  tenant_id       = var.usr_tenant_id
  client_id       = var.usr_client_id
  client_secret   = var.usr_client_secret
}

resource "azurerm_resource_group" "example" {
  location = var.location
  name     = "${var.prefix}-rg"
}

module "network" {
  source = "./modules/network"

  location                                = var.location
  prefix                                  = var.prefix
  resource_group_name                     = azurerm_resource_group.example.name
  vnet_address_space                      = var.vnet_address_space
  domain_controllers_subnet_address_space = local.domain_controllers_subnet_address_space
  anf_subnet_address_space                = local.anf_subnet_address_space
  domain_controller_private_ip_address    = local.domain_controller_private_ip_address
  domain_member01_private_ip_address      = local.domain_member01_private_ip_address
}

module "active-directory-domain" {
  source = "./modules/active-directory-domain"

  resource_group_name                  = azurerm_resource_group.example.name
  location                             = azurerm_resource_group.example.location
  prefix                               = var.prefix
  domain_controller_private_ip_address = local.domain_controller_private_ip_address
  domain_member01_private_ip_address   = local.domain_member01_private_ip_address
  active_directory_domain_name         = "${var.prefix}.local"
  active_directory_netbios_name        = var.prefix
  admin_username                       = var.admin_username
  admin_password                       = var.admin_password
  domain_controllers_subnet_id         = module.network.domain_controllers_subnet_id
}

module "anf" {
  source = "./modules/anf"

  prefix                               = var.prefix
  location                             = var.location
  resource_group_name                  = azurerm_resource_group.example.name
  admin_username                       = var.admin_username
  admin_password                       = var.admin_password
  domain_controller_private_ip_address = local.domain_controller_private_ip_address
  domain_member01_private_ip_address   = local.domain_member01_private_ip_address
  anf_subnet_id                        = module.network.anf_subnet_id
}