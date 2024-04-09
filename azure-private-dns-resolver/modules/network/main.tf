### resources on cloud ###
# add virtual network for cloud
resource "azurerm_virtual_network" "dns_virtual_network" {
  name                = "${var.prefix}-dns-vnet"
  resource_group_name = var.resource_group_name
  location            = var.location
  address_space       = ["${var.dns_vnet_address_space}"]
}

# add inbound subnet
resource "azurerm_subnet" "inbound_subnet" {
  name                 = "${var.prefix}-inbound-subnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.dns_virtual_network.name
  address_prefixes     = ["${var.inbound_subnet_address_space}"]

  delegation {
    name = "Microsoft.Network.dnsResolvers"

    service_delegation {
      actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
      name    = "Microsoft.Network/dnsResolvers"
    }

  }

}

# add outbound subnet
resource "azurerm_subnet" "outbound_subnet" {
  name                 = "${var.prefix}-outbound-subnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.dns_virtual_network.name
  address_prefixes     = ["${var.outbound_subnet_address_space}"]

  delegation {
    name = "Microsoft.Network.dnsResolvers"

    service_delegation {
      actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
      name    = "Microsoft.Network/dnsResolvers"
    }

  }

}

# add virtual network gateway subnet
resource "azurerm_subnet" "gateway_subnet" {
  name                 = "GatewaySubnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.dns_virtual_network.name
  address_prefixes     = ["${var.gateway_subnet_address_space}"]
}

# add public ip address for gateway
resource "azurerm_public_ip" "gateway_cloud_public_ip" {
  name                = "${var.prefix}-gateway-cloud-public-ip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Dynamic"
}

# add virtual network gateway
resource "azurerm_virtual_network_gateway" "gateway_cloud" {
  name                = "${var.prefix}-gateway"
  location            = var.location
  resource_group_name = var.resource_group_name
  type                = "Vpn"
  vpn_type            = "RouteBased"
  sku                 = "VpnGw1"
  enable_bgp          = false
  active_active       = false

  ip_configuration {
    name                          = "gwipconfig1"
    public_ip_address_id          = azurerm_public_ip.gateway_cloud_public_ip.id
    subnet_id                     = azurerm_subnet.gateway_subnet.id
    private_ip_address_allocation = "Dynamic"
  }

}

# add local network gateway
# it represents gateway on premises
resource "azurerm_local_network_gateway" "lgw_onprem" {
  name                = "${var.prefix}-lgw-onprem"
  location            = var.location
  resource_group_name = var.resource_group_name
  gateway_address     = azurerm_public_ip.gateway_onprem_public_ip.ip_address
  address_space       = ["${var.onprem_address_space}"]

  depends_on = [
    azurerm_public_ip.gateway_onprem_public_ip
  ]
}

#add virtual network for peerings
resource "azurerm_virtual_network" "peering_virtual_network" {
  name                = "${var.prefix}-peering-vnet"
  resource_group_name = var.resource_group_name
  location            = var.location
  address_space       = ["${var.peering_vnet_address_space}"]
}

# add subnet for peerings
resource "azurerm_subnet" "peering_subnet" {
  name                 = "${var.prefix}-peering-subnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.peering_virtual_network.name
  address_prefixes     = ["${var.peering_subnet_address_space}"]
}

# add subnet for private endpoint
resource "azurerm_subnet" "pe_subnet" {
  name                 = "${var.prefix}-pe-subnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.peering_virtual_network.name
  address_prefixes     = ["${var.pe_subnet_address_space}"]
}

# add virtual network peering from dns to peering
resource "azurerm_virtual_network_peering" "from_dns" {
  name                         = "${azurerm_virtual_network.dns_virtual_network.name}-to-${azurerm_virtual_network.peering_virtual_network.name}"
  resource_group_name          = var.resource_group_name
  virtual_network_name         = azurerm_virtual_network.dns_virtual_network.name
  remote_virtual_network_id    = azurerm_virtual_network.peering_virtual_network.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = true
}

# add virtual network peering from peering to dns
resource "azurerm_virtual_network_peering" "from_peering" {
  name                         = "${azurerm_virtual_network.peering_virtual_network.name}-to-${azurerm_virtual_network.dns_virtual_network.name}"
  resource_group_name          = var.resource_group_name
  virtual_network_name         = azurerm_virtual_network.peering_virtual_network.name
  remote_virtual_network_id    = azurerm_virtual_network.dns_virtual_network.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  use_remote_gateways          = true
}

### resources on onpremises ###
# add virtual network for onpremises
resource "azurerm_virtual_network" "onprem_virtual_network" {
  name                = "${var.prefix}-onprem-vnet"
  resource_group_name = var.resource_group_name
  location            = var.location
  address_space       = ["${var.onprem_address_space}"]
  dns_servers         = ["${var.vm_onprem_private_ip_address}", "${var.inbound_endpoint_ip_address}", "168.63.129.16"]
}

# add subnet for onpremises
resource "azurerm_subnet" "onprem_subnet" {
  name                 = "${var.prefix}-onprem-subnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.onprem_virtual_network.name
  address_prefixes     = ["${var.onprem_subnet_address_space}"]
}

# add subnet for onpremises gateway
resource "azurerm_subnet" "onprem_gateway_subnet" {
  name                 = "GatewaySubnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.onprem_virtual_network.name
  address_prefixes     = ["${var.onprem_gateway_subnet_address_space}"]
}

# add public ip address for onpremise gateway
resource "azurerm_public_ip" "gateway_onprem_public_ip" {
  name                = "${var.prefix}-gateway-onprem-public-ip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Dynamic"
}

# add virtual network gateway for onpremises
resource "azurerm_virtual_network_gateway" "gateway_onprem" {
  name                = "${var.prefix}-gateway-onprem"
  location            = var.location
  resource_group_name = var.resource_group_name
  type                = "Vpn"
  vpn_type            = "RouteBased"
  sku                 = "VpnGw1"
  enable_bgp          = false
  active_active       = false

  ip_configuration {
    name                          = "gwipconfig1"
    public_ip_address_id          = azurerm_public_ip.gateway_onprem_public_ip.id
    subnet_id                     = azurerm_subnet.onprem_gateway_subnet.id
    private_ip_address_allocation = "Dynamic"
  }

}

# add local network gateway for cloud
# it represents gateway on cloud
resource "azurerm_local_network_gateway" "lgw_cloud" {
  name                = "${var.prefix}-lgw-cloud"
  location            = var.location
  resource_group_name = var.resource_group_name
  gateway_address     = azurerm_public_ip.gateway_cloud_public_ip.ip_address
  address_space       = ["${var.dns_vnet_address_space}", "${var.peering_vnet_address_space}"]

  depends_on = [
    azurerm_public_ip.gateway_cloud_public_ip
  ]
}


### S2S VPN Connection ###
# add S2S connection from cloud to onpremises
resource "azurerm_virtual_network_gateway_connection" "cloud_to_onpremise" {
  name                       = "cloud-to-onpremise"
  location                   = var.location
  resource_group_name        = var.resource_group_name
  type                       = "IPsec"
  virtual_network_gateway_id = azurerm_virtual_network_gateway.gateway_cloud.id
  local_network_gateway_id   = azurerm_local_network_gateway.lgw_onprem.id
  shared_key                 = local.shared_key
}

# add S2S connection from onpremises to cloud
resource "azurerm_virtual_network_gateway_connection" "onpremise_to_cloud" {
  name                       = "onpremise-to-cloud"
  location                   = var.location
  resource_group_name        = var.resource_group_name
  type                       = "IPsec"
  virtual_network_gateway_id = azurerm_virtual_network_gateway.gateway_onprem.id
  local_network_gateway_id   = azurerm_local_network_gateway.lgw_cloud.id
  shared_key                 = local.shared_key
}

# add nsgrules for peering subnet
resource "azurerm_network_security_group" "peering_subnet_nsg" {
  name                = "${var.prefix}-peering-subnet-nsg"
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

# add nsgrules for onprem subnet
resource "azurerm_network_security_group" "onprem_subnet_nsg" {
  name                = "${var.prefix}-onprem-subnet-nsg"
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

#link nsg to peering subnet
resource "azurerm_subnet_network_security_group_association" "peering_subnet_nsg_association" {
  subnet_id                 = azurerm_subnet.peering_subnet.id
  network_security_group_id = azurerm_network_security_group.peering_subnet_nsg.id
}

# link nsg to onprem subnet
resource "azurerm_subnet_network_security_group_association" "onprem_subnet_nsg_association" {
  subnet_id                 = azurerm_subnet.onprem_subnet.id
  network_security_group_id = azurerm_network_security_group.onprem_subnet_nsg.id
}