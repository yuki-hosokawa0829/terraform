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

  location            = var.location
  prefix              = var.prefix
  resource_group_name = azurerm_resource_group.example.name
}

module "virtual_machine" {
  source = "./modules/virtual-machine"

  location            = var.location
  prefix              = var.prefix
  resource_group_name = azurerm_resource_group.example.name
  admin_username      = var.admin_username
  admin_password      = var.admin_password
  subnet_id01         = module.network.subnet_id01
  subnet_id02         = module.network.subnet_id02
  subnet_id03         = module.network.subnet_id03
}