# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

#Virtual Network in Japan West
resource "azurerm_virtual_network" "network_jw" {
  name                = join("-", [var.prefix, "network-jw"])
  location            = var.location01
  address_space       = ["${var.network_jw_address_range}"]
  resource_group_name = var.resource_group_name
  dns_servers         = ["${var.dc_jw_private_address}", "${var.dc_je_private_address}", "${var.dc_onprem_private_address}", "168.63.129.16", "8.8.8.8"]
}

resource "azurerm_subnet" "domain_controllers_jw" {
  name                 = "domain-controllers"
  address_prefixes     = ["${var.domain_controllers_jw_address_range}"]
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.network_jw.name
}

#Virtual Network in Japan East
resource "azurerm_virtual_network" "network_je" {
  name                = join("-", [var.prefix, "network-je"])
  location            = var.location02
  address_space       = ["${var.network_je_address_range}"]
  resource_group_name = var.resource_group_name
  dns_servers         = ["${var.dc_jw_private_address}", "${var.dc_je_private_address}", "${var.dc_onprem_private_address}", "168.63.129.16", "8.8.8.8"]
}

resource "azurerm_subnet" "domain_controllers_je" {
  name                 = "domain-controllers"
  address_prefixes     = ["${var.domain_controllers_je_address_range}"]
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.network_je.name
}

#virtual Network on Premises
resource "azurerm_virtual_network" "network_onprem" {
  name                = join("-", [var.prefix, "network-onprem"])
  location            = var.location02
  address_space       = ["${var.network_onprem_address_range}"]
  resource_group_name = var.resource_group_name
  dns_servers         = ["${var.dc_jw_private_address}", "${var.dc_je_private_address}", "${var.dc_onprem_private_address}", "168.63.129.16", "8.8.8.8"]
}

resource "azurerm_subnet" "domain_controllers_onprem" {
  name                 = "domain-controllers"
  address_prefixes     = ["${var.domain_controllers_onprem_address_range}"]
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.network_onprem.name
}

resource "azurerm_subnet" "domain_controllers_gateway" {
  name                 = "GatewaySubnet"
  address_prefixes     = ["${var.domain_controllers_gateway_address_range}"]
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.network_onprem.name
}

#NSG
resource "azurerm_network_security_group" "nsg_jw" {
  name                = join("-", [var.prefix, "nsg-jw"])
  location            = var.location01
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
}

resource "azurerm_network_security_group" "nsg_je" {
  name                = join("-", [var.prefix, "nsg-je"])
  location            = var.location02
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

}

resource "azurerm_network_security_group" "nsg_onprem" {
  name                = join("-", [var.prefix, "nsg-onprem"])
  location            = var.location02
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

}

#NSG Association
resource "azurerm_subnet_network_security_group_association" "nsg_as_jw" {
  subnet_id                 = azurerm_subnet.domain_controllers_jw.id
  network_security_group_id = azurerm_network_security_group.nsg_jw.id
}

resource "azurerm_subnet_network_security_group_association" "nsg_as_je" {
  subnet_id                 = azurerm_subnet.domain_controllers_je.id
  network_security_group_id = azurerm_network_security_group.nsg_je.id
}

resource "azurerm_subnet_network_security_group_association" "nsg_as_onprem" {
  subnet_id                 = azurerm_subnet.domain_controllers_onprem.id
  network_security_group_id = azurerm_network_security_group.nsg_onprem.id
}

#Virtual Network Gateway
resource "azurerm_public_ip" "gateway_pip" {
  name                = "${var.prefix}-vpngw-pip"
  location            = var.location02
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_virtual_network_gateway" "vpn_gateway" {
  name                = "${var.prefix}-vpngw"
  location            = var.location02
  resource_group_name = var.resource_group_name
  type                = "Vpn"
  vpn_type            = "RouteBased"
  active_active       = false
  enable_bgp          = false
  sku                 = "VpnGw1"

  ip_configuration {
    name                 = "VpnGwConfig"
    public_ip_address_id = azurerm_public_ip.gateway_pip.id
    subnet_id            = azurerm_subnet.domain_controllers_gateway.id
  }

}

#Local Network Gateway
resource "azurerm_local_network_gateway" "ln_gateway_instance0" {
  name                = "${var.prefix}-lng-instance0"
  location            = var.location02
  resource_group_name = var.resource_group_name
  gateway_address     = var.instance_0_pip
  address_space       = ["${var.vhub_location01_address_range}", "${var.vhub_location02_address_range}", "${var.network_jw_address_range}", "${var.network_je_address_range}"]
}

resource "azurerm_local_network_gateway" "ln_gateway_instance1" {
  name                = "${var.prefix}-lng-instance1"
  location            = var.location02
  resource_group_name = var.resource_group_name
  gateway_address     = var.instance_1_pip
  address_space       = ["${var.vhub_location01_address_range}", "${var.vhub_location02_address_range}", "${var.network_jw_address_range}", "${var.network_je_address_range}"]
}

