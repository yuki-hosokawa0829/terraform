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

  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  # vnet parameter
  vnet_address_range                     = var.vnet_address_range
  vnet_subnet_address_range              = local.vnet_subnet_address_range
  vnet_gateway_subnet_address_range      = local.vnet_gateway_subnet_address_range
  vnet_route_server_subnet_address_range = local.vnet_route_server_subnet_address_range
  vnet_as_number                         = local.vnet_as_number
  # peering vnet parameter
  vnet_peer_address_range                = var.vnet_peer_address_range
  vnet_peer_subnet_address_range         = local.vnet_peer_subnet_address_range
  vnet_peer_gateway_subnet_address_range = local.vnet_peer_gateway_subnet_address_range
  vnet_peer_as_number                    = local.vnet_peer_as_number
  # vpn vnet parameter
  vnet_vpn_address_range                = var.vnet_vpn_address_range
  vnet_vpn_subnet_address_range         = local.vnet_vpn_subnet_address_range
  vnet_vpn_gateway_subnet_address_range = local.vnet_vpn_gateway_subnet_address_range
  vnet_vpn_as_number                    = local.vnet_vpn_as_number
  # onprem vnet parameter
  vnet_onprem_address_range                = var.vnet_onprem_address_range
  vnet_onprem_subnet_address_range         = local.vnet_onprem_subnet_address_range
  vnet_onprem_gateway_subnet_address_range = local.vnet_onprem_gateway_subnet_address_range
  vnet_onprem_as_number                    = local.vnet_onprem_as_number
  # onprem02 vnet parameter
  vnet_onprem02_address_range                = var.vnet_onprem02_address_range
  vnet_onprem02_subnet_address_range         = local.vnet_onprem02_subnet_address_range
  vnet_onprem02_gateway_subnet_address_range = local.vnet_onprem02_gateway_subnet_address_range
}

module "route_server" {
  source = "./modules/route-server"

  location                    = var.location
  resource_group_name         = azurerm_resource_group.rg.name
  vnet_route_server_subnet_id = module.network.vnet_route_server_subnet_id
  vnet_peer_as_number         = local.vnet_peer_as_number
  vnet_as_number              = local.vnet_as_number
  peer_vpg_ip01               = module.network.peer_vpg_ip01
  peer_vpg_ip02               = module.network.peer_vpg_ip02
  vnet_vpg_ip01               = module.network.vnet_vpg_ip01
  vnet_vpg_ip02               = module.network.vnet_vpg_ip02
}

module "virtual_machine" {
  source = "./modules/virtual-machine"

  location              = var.location
  resource_group_name   = azurerm_resource_group.rg.name
  vnet_subnet_id        = module.network.vnet_subnet_id
  vnet_peer_subnet_id   = module.network.vnet_peer_subnet_id
  vnet_vpn_subnet_id    = module.network.vnet_vpn_subnet_id
  vnet_onprem_subnet_id = module.network.vnet_onprem_subnet_id
  local_admin_username  = var.local_admin_username
  local_admin_password  = var.local_admin_password
}
