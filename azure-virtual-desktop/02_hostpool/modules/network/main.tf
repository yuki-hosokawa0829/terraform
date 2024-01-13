# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

/* data "azurerm_virtual_network" "vnet" {
  name                = "vnet-img"
  resource_group_name = var.resource_group_name
} */

resource "azurerm_virtual_network" "example" {
  name                = join("-", [var.prefix, "network"])
  location            = var.location
  address_space       = ["${var.vnet_address_range}"]
  resource_group_name = var.resource_group_name
  dns_servers         = ["${var.domain_controller_private_ip_address}", "168.63.129.16", "8.8.8.8"]
}

resource "azurerm_subnet" "domain_controllers" {
  name                 = "domain-controllers"
  address_prefixes     = ["${var.domain_controllers_subnet_address_range}"]
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.example.name
}

resource "azurerm_subnet" "sessionhost" {
  name                 = "sessionhost"
  address_prefixes     = ["${var.sessionhost_subnet_address_range}"]
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.example.name
}

resource "azurerm_network_security_group" "nsg_dc" {
  name                = join("-", [var.prefix, "nsg-dc"])
  location            = var.location
  resource_group_name = var.resource_group_name

  security_rule {
    name                       = "AllowRDPInbound"
    priority                   = 1000
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "219.166.164.110"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "AllowRDPInboundAlt"
    priority                   = 1010
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "121.82.111.99"
    destination_address_prefix = "*"
  }

}

resource "azurerm_network_security_group" "nsg_sh" {
  name                = join("-", [var.prefix, "nsg-sh"])
  location            = var.location
  resource_group_name = var.resource_group_name

  security_rule {
    name                       = "AllowRDPInbound"
    priority                   = 1000
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "219.166.164.110"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "AllowRDPInboundAlt"
    priority                   = 1010
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "121.82.111.99"
    destination_address_prefix = "*"
  }

}

resource "azurerm_subnet_network_security_group_association" "nsg_as_dc" {
  subnet_id                 = azurerm_subnet.domain_controllers.id
  network_security_group_id = azurerm_network_security_group.nsg_dc.id
}

resource "azurerm_subnet_network_security_group_association" "nsg_as_dm" {
  subnet_id                 = azurerm_subnet.sessionhost.id
  network_security_group_id = azurerm_network_security_group.nsg_sh.id
}

/* ########################### add vnet peering ###########################
# add vnet peering from vnet to avd-network
resource "azurerm_virtual_network_peering" "vnet_to_avd" {
  name                         = "${data.azurerm_virtual_network.vnet.name}-to-${azurerm_virtual_network.example.name}"
  resource_group_name          = var.resource_group_name
  virtual_network_name         = data.azurerm_virtual_network.vnet.name
  remote_virtual_network_id    = azurerm_virtual_network.example.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = false
  use_remote_gateways          = false
}

# add vnet peering from avd-network to vnet
resource "azurerm_virtual_network_peering" "avd_to_vnet" {
  name                         = "${azurerm_virtual_network.example.name}-to-${data.azurerm_virtual_network.vnet.name}"
  resource_group_name          = var.resource_group_name
  virtual_network_name         = azurerm_virtual_network.example.name
  remote_virtual_network_id    = data.azurerm_virtual_network.vnet.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = false
  use_remote_gateways          = false
} */