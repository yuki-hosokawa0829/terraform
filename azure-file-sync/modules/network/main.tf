# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

#network on cloud
resource "azurerm_virtual_network" "example" {
  name                = join("-", [var.prefix, "network"])
  location            = var.location
  address_space       = ["${var.virtual_network_address_space}"]
  resource_group_name = var.resource_group_name
  dns_servers         = ["${local.domain_controller_private_ip_address}", "168.63.129.16", "8.8.8.8"]
}

resource "azurerm_subnet" "domain_controller_subnet" {
  name                 = local.subnet_name_dc
  address_prefixes     = ["${local.domain_controller_subnet_prefix}"]
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.example.name
}

resource "azurerm_subnet" "file_server_subnet" {
  name                 = local.subnet_name
  address_prefixes     = ["${local.file_server_subnet_prefix}"]
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.example.name
  service_endpoints    = ["Microsoft.Storage"]
}

#network on premises
resource "azurerm_virtual_network" "onpremises" {
  name                = join("-", [var.prefix, "network-onprem"])
  location            = var.location
  address_space       = ["${var.virtual_network_onprem_address_space}"]
  resource_group_name = var.resource_group_name
  dns_servers         = ["${local.domain_controller_private_ip_address}", "168.63.129.16", "8.8.8.8"]
}

resource "azurerm_subnet" "file_server_subnet_onprem" {
  name                 = local.subnet_name_onprem
  address_prefixes     = ["${local.file_server_onprem_subnet_prefix}"]
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.onpremises.name
  service_endpoints    = ["Microsoft.Storage"]
}

#NSG
resource "azurerm_network_security_group" "nsg_fs" {
  name                = "nsg-fs"
  location            = var.location
  resource_group_name = var.resource_group_name
}

resource "azurerm_network_security_rule" "AllowRDPInbound" {
  name                        = "AllowRDPInbound"
  priority                    = 1000
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "3389"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.nsg_fs.name
}

resource "azurerm_subnet_network_security_group_association" "nsg_as_fs" {
  subnet_id                 = azurerm_subnet.file_server_subnet.id
  network_security_group_id = azurerm_network_security_group.nsg_fs.id
}

resource "azurerm_network_security_group" "nsg_fs_onprem" {
  name                = "nsg-fs-onprem"
  location            = var.location
  resource_group_name = var.resource_group_name
}

resource "azurerm_network_security_rule" "AllowRDPInboundOnprem" {
  name                        = "AllowRDPInbound"
  priority                    = 1000
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "3389"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.nsg_fs_onprem.name
}

resource "azurerm_subnet_network_security_group_association" "nsg_as_fs_onprem" {
  subnet_id                 = azurerm_subnet.file_server_subnet_onprem.id
  network_security_group_id = azurerm_network_security_group.nsg_fs_onprem.id
}

resource "azurerm_network_security_group" "nsg_dc" {
  name                = "nsg-dc"
  location            = var.location
  resource_group_name = var.resource_group_name
}

resource "azurerm_network_security_rule" "AllowRDPInboundDC" {
  name                        = "AllowRDPInbound"
  priority                    = 1000
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "3389"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.nsg_dc.name
}

resource "azurerm_subnet_network_security_group_association" "nsg_as_dc" {
  subnet_id                 = azurerm_subnet.domain_controller_subnet.id
  network_security_group_id = azurerm_network_security_group.nsg_dc.id
}

#VNet Peering
resource "azurerm_virtual_network_peering" "peer_cloud_to_onprem" {
  name                      = join("-to-", [azurerm_virtual_network.example.name, azurerm_virtual_network.onpremises.name])
  resource_group_name       = var.resource_group_name
  virtual_network_name      = azurerm_virtual_network.example.name
  remote_virtual_network_id = azurerm_virtual_network.onpremises.id
}

resource "azurerm_virtual_network_peering" "peer_onprem_to_cloud" {
  name                      = join("-to-", [azurerm_virtual_network.onpremises.name, azurerm_virtual_network.example.name])
  resource_group_name       = var.resource_group_name
  virtual_network_name      = azurerm_virtual_network.onpremises.name
  remote_virtual_network_id = azurerm_virtual_network.example.id
}


