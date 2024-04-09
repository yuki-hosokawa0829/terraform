# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

resource "azurerm_virtual_network" "example" {
  name                = join("-", [var.prefix, "network"])
  location            = var.location
  address_space       = ["${var.vnet_address_range}"]
  resource_group_name = var.resource_group_name
  dns_servers         = ["${var.vm_dc_private_ip_address}", "168.63.129.16", "8.8.8.8"]
}

resource "azurerm_subnet" "subnet" {
  name                 = "domain-controllers"
  address_prefixes     = ["${var.subnet_address_range}"]
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.example.name
}

resource "azurerm_subnet" "member" {
  name                 = "domain-members"
  address_prefixes     = ["${var.member_subnet_address_range}"]
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
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

}

resource "azurerm_network_security_group" "nsg_dm" {
  name                = join("-", [var.prefix, "nsg-dm"])
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
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

}

resource "azurerm_subnet_network_security_group_association" "nsg_as_dc" {
  subnet_id                 = azurerm_subnet.subnet.id
  network_security_group_id = azurerm_network_security_group.nsg_dc.id
}

resource "azurerm_subnet_network_security_group_association" "nsg_as_dm" {
  subnet_id                 = azurerm_subnet.member.id
  network_security_group_id = azurerm_network_security_group.nsg_dm.id
}