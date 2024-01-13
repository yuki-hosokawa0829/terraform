# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

provider "azurerm" {
  features {}
  subscription_id = var.usr_subscription_id
  tenant_id       = var.usr_tenant_id
  client_id       = var.usr_client_id
  client_secret   = var.usr_client_secret
}

################### import data source ###################
# add resource group data source
data "azurerm_resource_group" "rg" {
  name = "${var.prefix}-rg"
}

# add virtual network in Japan West data source
data "azurerm_virtual_network" "network_jw" {
  name                = join("-", [var.prefix, "network-jw"])
  resource_group_name = data.azurerm_resource_group.rg.name
}

# add virtual network in Japan East data source
data "azurerm_virtual_network" "network_je" {
  name                = join("-", [var.prefix, "network-je"])
  resource_group_name = data.azurerm_resource_group.rg.name
}

# add virtual network gateway data source
data "azurerm_virtual_network_gateway" "vpn_gateway" {
  name                = "${var.prefix}-vpngw"
  resource_group_name = data.azurerm_resource_group.rg.name
}

# add local network gateway0 data source
data "azurerm_local_network_gateway" "ln_gateway_instance0" {
  name                = "${var.prefix}-lng-instance0"
  resource_group_name = data.azurerm_resource_group.rg.name
}

# add local network gateway1 data source
data "azurerm_local_network_gateway" "ln_gateway_instance1" {
  name                = "${var.prefix}-lng-instance1"
  resource_group_name = data.azurerm_resource_group.rg.name
}

# add virtual hub in Japan West data source
data "azurerm_virtual_hub" "vhub_jw" {
  name                = "${var.prefix}-vWAN-hub-01"
  resource_group_name = data.azurerm_resource_group.rg.name
}

# add virtual hub in Japan East data source
data "azurerm_virtual_hub" "vhub_je" {
  name                = "${var.prefix}-vWAN-hub-02"
  resource_group_name = data.azurerm_resource_group.rg.name
}

################### create resource ###################
#S2S Connection between vHUB and Azure Virtual WAN
resource "azurerm_virtual_network_gateway_connection" "s2s_connection0" {
  name                       = "${var.prefix}-s2s-connection0"
  location                   = var.location02
  resource_group_name        = data.azurerm_resource_group.rg.name
  type                       = "IPsec"
  virtual_network_gateway_id = data.azurerm_virtual_network_gateway.vpn_gateway.id
  local_network_gateway_id   = data.azurerm_local_network_gateway.ln_gateway_instance0.id
  shared_key                 = local.shared_key
}

resource "azurerm_virtual_network_gateway_connection" "s2s_connection1" {
  name                       = "${var.prefix}-s2s-connection1"
  location                   = var.location02
  resource_group_name        = data.azurerm_resource_group.rg.name
  type                       = "IPsec"
  virtual_network_gateway_id = data.azurerm_virtual_network_gateway.vpn_gateway.id
  local_network_gateway_id   = data.azurerm_local_network_gateway.ln_gateway_instance1.id
  shared_key                 = local.shared_key
}

# Connection between vHub and virtual network
resource "azurerm_virtual_hub_connection" "connection_jw" {
  name                      = "${var.prefix}-vhub-connection-jw"
  virtual_hub_id            = data.azurerm_virtual_hub.vhub_jw.id
  remote_virtual_network_id = data.azurerm_virtual_network.network_jw.id
  internet_security_enabled = true # set to true if you deploy Azure Firewall
}

resource "azurerm_virtual_hub_connection" "connection_je" {
  name                      = "${var.prefix}-vhub-connection-je"
  virtual_hub_id            = data.azurerm_virtual_hub.vhub_je.id
  remote_virtual_network_id = data.azurerm_virtual_network.network_je.id
  internet_security_enabled = false # set to true if you deploy Azure Firewall
}