###################### vnet ######################
# add virtual network
resource "azurerm_virtual_network" "vnet" {
  name                = "vnet"
  location            = var.location
  address_space       = ["${var.vnet_address_range}"]
  resource_group_name = var.resource_group_name
}

# add vnet subnet
resource "azurerm_subnet" "vnet_subnet" {
  name                 = "vnet_subnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["${var.vnet_subnet_address_range}"]
}

# add subnet for vpn gateway
resource "azurerm_subnet" "vnet_gateway_subnet" {
  name                 = "GatewaySubnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["${var.vnet_gateway_subnet_address_range}"]
}

# add subnet for route server
resource "azurerm_subnet" "vnet_route_server_subnet" {
  name                 = "RouteServerSubnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["${var.vnet_route_server_subnet_address_range}"]
}

###################### vnet_peer ######################
# add peer virtual network
resource "azurerm_virtual_network" "vnet_peer" {
  name                = "vnet-peer"
  location            = var.location
  address_space       = ["${var.vnet_peer_address_range}"]
  resource_group_name = var.resource_group_name
}

# add vnet peer subnet
resource "azurerm_subnet" "vnet_peer_subnet" {
  name                 = "vnet_peer_subnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet_peer.name
  address_prefixes     = ["${var.vnet_peer_subnet_address_range}"]
}

# add subnet for vpn gateway
resource "azurerm_subnet" "vnet_peer_gateway_subnet" {
  name                 = "GatewaySubnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet_peer.name
  address_prefixes     = ["${var.vnet_peer_gateway_subnet_address_range}"]
}

###################### vnet_vpn ######################
# add vpn virtual network
resource "azurerm_virtual_network" "vnet_vpn" {
  name                = "vnet-vpn"
  location            = var.location
  address_space       = ["${var.vnet_vpn_address_range}"]
  resource_group_name = var.resource_group_name
}

# add vpn subnet
resource "azurerm_subnet" "vnet_vpn_subnet" {
  name                 = "vnet_vpn_subnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet_vpn.name
  address_prefixes     = ["${var.vnet_vpn_subnet_address_range}"]
}

# add subnet for vpn gateway
resource "azurerm_subnet" "vnet_vpn_gateway_subnet" {
  name                 = "GatewaySubnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet_vpn.name
  address_prefixes     = ["${var.vnet_vpn_gateway_subnet_address_range}"]
}

###################### vnet_onprem ######################
# add onprem virtual network
resource "azurerm_virtual_network" "vnet_onprem" {
  name                = "vnet-onprem"
  location            = var.location
  address_space       = ["${var.vnet_onprem_address_range}"]
  resource_group_name = var.resource_group_name
}

# add onprem subnet
resource "azurerm_subnet" "vnet_onprem_subnet" {
  name                 = "vnet_onprem_subnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet_onprem.name
  address_prefixes     = ["${var.vnet_onprem_subnet_address_range}"]
}

# add subnet for vpn gateway
resource "azurerm_subnet" "vnet_onprem_gateway_subnet" {
  name                 = "GatewaySubnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet_onprem.name
  address_prefixes     = ["${var.vnet_onprem_gateway_subnet_address_range}"]
}

###################### vnet_onprem02 ######################
# add onprem02 virtual network
resource "azurerm_virtual_network" "vnet_onprem02" {
  name                = "vnet-onprem02"
  location            = var.location
  address_space       = ["${var.vnet_onprem02_address_range}"]
  resource_group_name = var.resource_group_name
}

# add onprem02 subnet
resource "azurerm_subnet" "vnet_onprem02_subnet" {
  name                 = "vnet_onprem02_subnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet_onprem02.name
  address_prefixes     = ["${var.vnet_onprem02_subnet_address_range}"]
}

# add subnet for vpn gateway
resource "azurerm_subnet" "vnet_onprem02_gateway_subnet" {
  name                 = "GatewaySubnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet_onprem02.name
  address_prefixes     = ["${var.vnet_onprem02_gateway_subnet_address_range}"]
}

###################### network security group ######################
# add nsg for vnet_subnet
resource "azurerm_network_security_group" "vnet_subnet_nsg" {
  name                = "vnet-subnet-nsg"
  location            = var.location
  resource_group_name = var.resource_group_name

  security_rule {
    name                       = "allow-rdp"
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

# add nsg for vnet_peer_subnet
resource "azurerm_network_security_group" "vnet_peer_subnet_nsg" {
  name                = "vnet-peer-subnet-nsg"
  location            = var.location
  resource_group_name = var.resource_group_name

  security_rule {
    name                       = "allow-rdp"
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

# add nsg for vnet_vpn_subnet
resource "azurerm_network_security_group" "vnet_vpn_subnet_nsg" {
  name                = "vnet-vpn-subnet-nsg"
  location            = var.location
  resource_group_name = var.resource_group_name

  security_rule {
    name                       = "allow-rdp"
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

# add nsg for vnet_onprem_subnet
resource "azurerm_network_security_group" "vnet_onprem_subnet_nsg" {
  name                = "vnet-onprem-subnet-nsg"
  location            = var.location
  resource_group_name = var.resource_group_name

  security_rule {
    name                       = "allow-rdp"
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

###################### link nsg to subnet ######################
# link nsg to vnet_subnet
resource "azurerm_subnet_network_security_group_association" "vnet_subnet_nsg_as" {
  subnet_id                 = azurerm_subnet.vnet_subnet.id
  network_security_group_id = azurerm_network_security_group.vnet_subnet_nsg.id
}

# link nsg to vnet_peer_subnet
resource "azurerm_subnet_network_security_group_association" "vnet_peer_subnet_nsg_as" {
  subnet_id                 = azurerm_subnet.vnet_peer_subnet.id
  network_security_group_id = azurerm_network_security_group.vnet_peer_subnet_nsg.id
}

# link nsg to vnet_vpn_subnet
resource "azurerm_subnet_network_security_group_association" "vnet_vpn_subnet_nsg_as" {
  subnet_id                 = azurerm_subnet.vnet_vpn_subnet.id
  network_security_group_id = azurerm_network_security_group.vnet_vpn_subnet_nsg.id
}

# link nsg to vnet_onprem_subnet
resource "azurerm_subnet_network_security_group_association" "vnet_onprem_subnet_nsg_as" {
  subnet_id                 = azurerm_subnet.vnet_onprem_subnet.id
  network_security_group_id = azurerm_network_security_group.vnet_onprem_subnet_nsg.id
}

###################### vnet peering ######################
# peering from vnet to vnet_peer #
resource "azurerm_virtual_network_peering" "vnet_to_vnet_peer" {
  name                         = "${azurerm_virtual_network.vnet.name}-to-${azurerm_virtual_network.vnet_peer.name}"
  resource_group_name          = var.resource_group_name
  virtual_network_name         = azurerm_virtual_network.vnet.name
  remote_virtual_network_id    = azurerm_virtual_network.vnet_peer.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = true
  use_remote_gateways          = false
}

# peering from vnet_peer to vnet #
resource "azurerm_virtual_network_peering" "vnet_peer_to_vnet" {
  name                         = "${azurerm_virtual_network.vnet_peer.name}-to-${azurerm_virtual_network.vnet.name}"
  resource_group_name          = var.resource_group_name
  virtual_network_name         = azurerm_virtual_network.vnet_peer.name
  remote_virtual_network_id    = azurerm_virtual_network.vnet.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = true
  use_remote_gateways          = false
}

# peering from vnet_onprem to vnet_onprem02 #
resource "azurerm_virtual_network_peering" "vnet_onprem_to_vnet_onprem02" {
  name                         = "${azurerm_virtual_network.vnet_onprem.name}-to-${azurerm_virtual_network.vnet_onprem02.name}"
  resource_group_name          = var.resource_group_name
  virtual_network_name         = azurerm_virtual_network.vnet_onprem.name
  remote_virtual_network_id    = azurerm_virtual_network.vnet_onprem02.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = true
  use_remote_gateways          = false
}

# peer from vnet_onprem02 to vnet_onprem #
resource "azurerm_virtual_network_peering" "vnet_onprem02_to_vnet_onprem" {
  name                         = "${azurerm_virtual_network.vnet_onprem02.name}-to-${azurerm_virtual_network.vnet_onprem.name}"
  resource_group_name          = var.resource_group_name
  virtual_network_name         = azurerm_virtual_network.vnet_onprem02.name
  remote_virtual_network_id    = azurerm_virtual_network.vnet_onprem.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = false
  use_remote_gateways          = true
}


###################### vnp gateway ######################
# add public ip for vnet vpn gateway
resource "azurerm_public_ip" "vnet_gateway_pip01" {
  name                = "vnet-gateway-pip01"
  resource_group_name = var.resource_group_name
  location            = var.location
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_public_ip" "vnet_gateway_pip02" {
  name                = "vnet-gateway-pip02"
  resource_group_name = var.resource_group_name
  location            = var.location
  allocation_method   = "Static"
  sku                 = "Standard"
}

# add vpn gateway
resource "azurerm_virtual_network_gateway" "vnet_gateway" {
  name                = "vnet-gateway"
  location            = var.location
  resource_group_name = var.resource_group_name
  type                = "Vpn"
  vpn_type            = "RouteBased"
  sku                 = "VpnGw1"
  active_active       = true
  enable_bgp          = true

  ip_configuration {
    name                          = local.vpn_gateway_conf_name01
    public_ip_address_id          = azurerm_public_ip.vnet_gateway_pip01.id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = azurerm_subnet.vnet_gateway_subnet.id
  }

  ip_configuration {
    name                          = local.vpn_gateway_conf_name02
    public_ip_address_id          = azurerm_public_ip.vnet_gateway_pip02.id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = azurerm_subnet.vnet_gateway_subnet.id
  }

  bgp_settings {
    asn = var.vnet_as_number

    peering_addresses {
      ip_configuration_name = local.vpn_gateway_conf_name01
    }

    peering_addresses {
      ip_configuration_name = local.vpn_gateway_conf_name02
    }

  }

}

###################### vnp gateway for peering network ######################
# add public ip for vnet peer vpn gateway
resource "azurerm_public_ip" "vnet_peer_gateway_pip01" {
  name                = "vnet-peer-gateway-pip01"
  resource_group_name = var.resource_group_name
  location            = var.location
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_public_ip" "vnet_peer_gateway_pip02" {
  name                = "vnet-peer-gateway-pip02"
  resource_group_name = var.resource_group_name
  location            = var.location
  allocation_method   = "Static"
  sku                 = "Standard"
}

# add vpn gateway
resource "azurerm_virtual_network_gateway" "vnet_peer_gateway" {
  name                = "vnet-peer-gateway"
  location            = var.location
  resource_group_name = var.resource_group_name
  type                = "Vpn"
  vpn_type            = "RouteBased"
  sku                 = "VpnGw1"
  active_active       = true
  enable_bgp          = true

  ip_configuration {
    name                          = local.vpn_peer_gateway_conf_name01
    public_ip_address_id          = azurerm_public_ip.vnet_peer_gateway_pip01.id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = azurerm_subnet.vnet_peer_gateway_subnet.id
  }

  ip_configuration {
    name                          = local.vpn_peer_gateway_conf_name02
    public_ip_address_id          = azurerm_public_ip.vnet_peer_gateway_pip02.id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = azurerm_subnet.vnet_peer_gateway_subnet.id
  }

  bgp_settings {
    asn = var.vnet_peer_as_number

    peering_addresses {
      ip_configuration_name = local.vpn_peer_gateway_conf_name01
    }

    peering_addresses {
      ip_configuration_name = local.vpn_peer_gateway_conf_name02
    }

  }

}

###################### vnp gateway for vpn network ######################
# add public ip for vnet vpn vpn gateway
resource "azurerm_public_ip" "vnet_vpn_gateway_pip01" {
  name                = "vnet-vpn-gateway-pip01"
  resource_group_name = var.resource_group_name
  location            = var.location
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_public_ip" "vnet_vpn_gateway_pip02" {
  name                = "vnet-vpn-gateway-pip02"
  resource_group_name = var.resource_group_name
  location            = var.location
  allocation_method   = "Static"
  sku                 = "Standard"
}

# add vpn gateway
resource "azurerm_virtual_network_gateway" "vnet_vpn_gateway" {
  name                = "vnet-vpn-gateway"
  location            = var.location
  resource_group_name = var.resource_group_name
  type                = "Vpn"
  vpn_type            = "RouteBased"
  sku                 = "VpnGw1"
  active_active       = true
  enable_bgp          = true

  ip_configuration {
    name                          = local.vpn_gateway_conf_name01
    public_ip_address_id          = azurerm_public_ip.vnet_vpn_gateway_pip01.id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = azurerm_subnet.vnet_vpn_gateway_subnet.id
  }

  ip_configuration {
    name                          = local.vpn_gateway_conf_name02
    public_ip_address_id          = azurerm_public_ip.vnet_vpn_gateway_pip02.id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = azurerm_subnet.vnet_vpn_gateway_subnet.id
  }

  bgp_settings {
    asn = var.vnet_vpn_as_number

    peering_addresses {
      ip_configuration_name = local.vpn_gateway_conf_name01
    }

    peering_addresses {
      ip_configuration_name = local.vpn_gateway_conf_name02
    }

  }

}

###################### vnp gateway for onprem network ######################
# add public ip for vnet onprem vpn gateway
resource "azurerm_public_ip" "vnet_onprem_gateway_pip01" {
  name                = "vnet-onprem-gateway-pip01"
  resource_group_name = var.resource_group_name
  location            = var.location
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_public_ip" "vnet_onprem_gateway_pip02" {
  name                = "vnet-onprem-gateway-pip02"
  resource_group_name = var.resource_group_name
  location            = var.location
  allocation_method   = "Static"
  sku                 = "Standard"
}

# add vpn gateway
resource "azurerm_virtual_network_gateway" "vnet_onprem_gateway" {
  name                = "vnet-onprem-gateway"
  location            = var.location
  resource_group_name = var.resource_group_name
  type                = "Vpn"
  vpn_type            = "RouteBased"
  sku                 = "VpnGw1"
  active_active       = true
  enable_bgp          = true

  ip_configuration {
    name                          = local.vpn_onprem_gateway_conf_name01
    public_ip_address_id          = azurerm_public_ip.vnet_onprem_gateway_pip01.id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = azurerm_subnet.vnet_onprem_gateway_subnet.id
  }

  ip_configuration {
    name                          = local.vpn_onprem_gateway_conf_name02
    public_ip_address_id          = azurerm_public_ip.vnet_onprem_gateway_pip02.id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = azurerm_subnet.vnet_onprem_gateway_subnet.id
  }

  bgp_settings {
    asn = var.vnet_onprem_as_number

    peering_addresses {
      ip_configuration_name = local.vpn_onprem_gateway_conf_name01
    }

    peering_addresses {
      ip_configuration_name = local.vpn_onprem_gateway_conf_name02
    }

  }

}


###################### create vpn connection between vnet_peer and vnet_onprem ######################
# add vpn connection between vnet_peer_gateway and vnet_onprem_gateway
resource "azurerm_virtual_network_gateway_connection" "vnet_peer_to_vnet_onprem01" {
  name                            = "vnet-peer-to-vnet-onprem01"
  location                        = var.location
  resource_group_name             = var.resource_group_name
  virtual_network_gateway_id      = azurerm_virtual_network_gateway.vnet_peer_gateway.id
  peer_virtual_network_gateway_id = azurerm_virtual_network_gateway.vnet_onprem_gateway.id
  type                            = "Vnet2Vnet"
  shared_key                      = "AzureA1b2C3"
  enable_bgp                      = true
}

resource "azurerm_virtual_network_gateway_connection" "vnet_onprem_to_vnet_peer01" {
  name                            = "vnet-onprem-to-vnet-peer01"
  location                        = var.location
  resource_group_name             = var.resource_group_name
  virtual_network_gateway_id      = azurerm_virtual_network_gateway.vnet_onprem_gateway.id
  peer_virtual_network_gateway_id = azurerm_virtual_network_gateway.vnet_peer_gateway.id
  type                            = "Vnet2Vnet"
  shared_key                      = "AzureA1b2C3"
  enable_bgp                      = true
}

######################### create vpn connection between vnet and vnet_vpn #########################
# add vpn connection between vnet_gateway and vnet_vpn_gateway
resource "azurerm_virtual_network_gateway_connection" "vnet_to_vnet_vpn01" {
  name                            = "vnet-to-vnet-vpn01"
  location                        = var.location
  resource_group_name             = var.resource_group_name
  virtual_network_gateway_id      = azurerm_virtual_network_gateway.vnet_gateway.id
  peer_virtual_network_gateway_id = azurerm_virtual_network_gateway.vnet_vpn_gateway.id
  type                            = "Vnet2Vnet"
  shared_key                      = "AzureA1b2C3"
  enable_bgp                      = true
}

resource "azurerm_virtual_network_gateway_connection" "vnet_vpn_to_vnet01" {
  name                            = "vnet-vpn-to-vnet01"
  location                        = var.location
  resource_group_name             = var.resource_group_name
  virtual_network_gateway_id      = azurerm_virtual_network_gateway.vnet_vpn_gateway.id
  peer_virtual_network_gateway_id = azurerm_virtual_network_gateway.vnet_gateway.id
  type                            = "Vnet2Vnet"
  shared_key                      = "AzureA1b2C3"
  enable_bgp                      = true
}