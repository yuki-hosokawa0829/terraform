################# Create virtual networks #################
resource "random_string" "random01" {
  length  = 4
  special = false
  upper   = false
}

resource "random_pet" "virtual_network_name01" {
  prefix = "vnet-${random_string.random01.result}"
}

resource "azurerm_virtual_network" "vnet" {
  count               = local.num01
  name                = "${random_pet.virtual_network_name01.id}-0${count.index}"
  resource_group_name = var.resource_group_name
  location            = var.location
  address_space       = ["10.${count.index}.0.0/16"]
}

# Add a subnet to each virtual network
resource "azurerm_subnet" "subnet_vnet" {
  count                = local.num01
  name                 = "default"
  virtual_network_name = azurerm_virtual_network.vnet[count.index].name
  resource_group_name  = var.resource_group_name
  address_prefixes     = ["10.${count.index}.0.0/24"]
}

# Add GatewaySubnet to each virtual network
resource "azurerm_subnet" "gateway_subnet_vnet" {
  count                = local.num01
  name                 = "GatewaySubnet"
  virtual_network_name = azurerm_virtual_network.vnet[count.index].name
  resource_group_name  = var.resource_group_name
  address_prefixes     = ["10.${count.index}.1.0/24"]
}

################# Create onpremise virtual networks #################
resource "random_pet" "virtual_network_name02" {
  prefix = "onprem-${random_string.random01.result}"
}

resource "azurerm_virtual_network" "onprem_vnet" {
  count               = local.num01
  name                = "${random_pet.virtual_network_name02.id}-0${count.index}"
  resource_group_name = var.resource_group_name
  location            = var.location
  address_space       = ["192.168.${count.index}.0/24"]
}

# Add a subnet to each virtual network
resource "azurerm_subnet" "subnet_onprem_vnet" {
  count                = local.num01
  name                 = "default"
  virtual_network_name = azurerm_virtual_network.onprem_vnet[count.index].name
  resource_group_name  = var.resource_group_name
  address_prefixes     = ["192.168.${count.index}.0/27"]
}

# Add GatewaySubnet to each virtual network
resource "azurerm_subnet" "gateway_subnet_onprem_vnet" {
  count                = local.num01
  name                 = "GatewaySubnet"
  virtual_network_name = azurerm_virtual_network.onprem_vnet[count.index].name
  resource_group_name  = var.resource_group_name
  address_prefixes     = ["192.168.${count.index}.32/27"]
}

################# Create additional onprem virtual networks #################
resource "random_pet" "virtual_network_name03" {
  prefix = "peering-${random_string.random01.result}"
}

resource "azurerm_virtual_network" "peering_vnet" {
  count               = local.num01
  name                = "${random_pet.virtual_network_name03.id}-0${count.index}"
  resource_group_name = var.resource_group_name
  location            = var.location
  address_space       = ["192.168.${count.index + local.num01}.0/24"]
}

################# Create peering connections #################
resource "azurerm_virtual_network_peering" "vnet_peering01" {
  count                        = local.num01
  name                         = "peering-from-${azurerm_virtual_network.onprem_vnet[count.index].name}-to-${azurerm_virtual_network.peering_vnet[count.index].name}"
  resource_group_name          = var.resource_group_name
  virtual_network_name         = azurerm_virtual_network.onprem_vnet[count.index].name
  remote_virtual_network_id    = azurerm_virtual_network.peering_vnet[count.index].id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = true
  use_remote_gateways          = false

  depends_on = [
    azurerm_virtual_network_gateway.onprem_vnet_gw
  ]

}

resource "azurerm_virtual_network_peering" "vnet_peering02" {
  count                        = local.num01
  name                         = "peering-from-${azurerm_virtual_network.peering_vnet[count.index].name}-to-${azurerm_virtual_network.onprem_vnet[count.index].name}"
  resource_group_name          = var.resource_group_name
  virtual_network_name         = azurerm_virtual_network.peering_vnet[count.index].name
  remote_virtual_network_id    = azurerm_virtual_network.onprem_vnet[count.index].id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = false
  use_remote_gateways          = true

  depends_on = [
    azurerm_virtual_network_gateway.onprem_vnet_gw
  ]

}

################# Create virtual network gateways #################
# Create two public IP addresses for each virtual network gateway
resource "azurerm_public_ip" "public_ip_vnet01" {
  count               = local.num01
  name                = "vnet-gw-ip-0${count.index}"
  resource_group_name = var.resource_group_name
  location            = var.location
  allocation_method   = "Dynamic"
}

resource "azurerm_public_ip" "public_ip_vnet02" {
  count               = local.num01
  name                = "vnet-gw-ip-1${count.index}"
  resource_group_name = var.resource_group_name
  location            = var.location
  allocation_method   = "Dynamic"
}

# Create a virtual network gateway for each virtual network
resource "azurerm_virtual_network_gateway" "vnet_gw" {
  count               = local.num01
  name                = "vnet-gw-0${count.index}"
  location            = var.location
  resource_group_name = var.resource_group_name
  type                = "Vpn"
  vpn_type            = "RouteBased"
  sku                 = "VpnGw1"
  active_active       = true
  enable_bgp          = true

  ip_configuration {
    name                          = "vnet-gw-ipconf-0${count.index}"
    public_ip_address_id          = azurerm_public_ip.public_ip_vnet01[count.index].id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = azurerm_subnet.gateway_subnet_vnet[count.index].id
  }

  ip_configuration {
    name                          = "vnet-gw-ipconf-1${count.index}"
    public_ip_address_id          = azurerm_public_ip.public_ip_vnet02[count.index].id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = azurerm_subnet.gateway_subnet_vnet[count.index].id
  }

  bgp_settings {

    peering_addresses {
      ip_configuration_name = "vnet-gw-ipconf-0${count.index}"
    }

    peering_addresses {
      ip_configuration_name = "vnet-gw-ipconf-1${count.index}"
    }

    asn = local.bgp_asn[count.index]

  }

}

################# Create onprem network gateways #################
# Create two public IP addresses for each virtual network gateway
resource "azurerm_public_ip" "public_ip_onprem_vnet01" {
  count               = local.num01
  name                = "onprem-vnet-gw-ip-0${count.index}"
  resource_group_name = var.resource_group_name
  location            = var.location
  allocation_method   = "Dynamic"
}

resource "azurerm_public_ip" "public_ip_onprem_vnet02" {
  count               = local.num01
  name                = "onprem-vnet-gw-ip-1${count.index}"
  resource_group_name = var.resource_group_name
  location            = var.location
  allocation_method   = "Dynamic"
}

# Create a virtual network gateway for each virtual network
resource "azurerm_virtual_network_gateway" "onprem_vnet_gw" {
  count               = local.num01
  name                = "onprem-vnet-gw-0${count.index}"
  location            = var.location
  resource_group_name = var.resource_group_name
  type                = "Vpn"
  vpn_type            = "RouteBased"
  sku                 = "VpnGw1"
  active_active       = true
  enable_bgp          = true

  ip_configuration {
    name                          = "onprem-vnet-gw-ipconf-0${count.index}"
    public_ip_address_id          = azurerm_public_ip.public_ip_onprem_vnet01[count.index].id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = azurerm_subnet.gateway_subnet_onprem_vnet[count.index].id
  }

  ip_configuration {
    name                          = "onprem-vnet-gw-ipconf-1${count.index}"
    public_ip_address_id          = azurerm_public_ip.public_ip_onprem_vnet02[count.index].id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = azurerm_subnet.gateway_subnet_onprem_vnet[count.index].id
  }

  bgp_settings {

    peering_addresses {
      ip_configuration_name = "onprem-vnet-gw-ipconf-0${count.index}"
    }

    peering_addresses {
      ip_configuration_name = "onprem-vnet-gw-ipconf-1${count.index}"
    }

    asn = local.onprem_bgp_asn[count.index]

  }

}


################# Create local network gateway #################
# Create two local network gateways that represents onprem network gateway
resource "azurerm_local_network_gateway" "onprem_vnet_lng01" {
  count               = local.num01
  name                = "onprem-vnet-lng-1${count.index}"
  location            = var.location
  resource_group_name = var.resource_group_name
  gateway_address     = azurerm_public_ip.public_ip_onprem_vnet01[count.index].ip_address

  bgp_settings {
    asn                 = local.onprem_bgp_asn[count.index]
    bgp_peering_address = azurerm_virtual_network_gateway.onprem_vnet_gw[count.index].bgp_settings[0].peering_addresses[0].default_addresses[0]
  }

  depends_on = [
    azurerm_public_ip.public_ip_onprem_vnet01
  ]

}

resource "azurerm_local_network_gateway" "onprem_vnet_lng02" {
  count               = local.num01
  name                = "onprem-vnet-lng-2${count.index}"
  location            = var.location
  resource_group_name = var.resource_group_name
  gateway_address     = azurerm_public_ip.public_ip_onprem_vnet02[count.index].ip_address

  bgp_settings {
    asn                 = local.onprem_bgp_asn[count.index]
    bgp_peering_address = azurerm_virtual_network_gateway.onprem_vnet_gw[count.index].bgp_settings[0].peering_addresses[1].default_addresses[0]
  }

  depends_on = [
    azurerm_public_ip.public_ip_onprem_vnet02
  ]

}

# Create two local network gateways that represents vpn gateway
resource "azurerm_local_network_gateway" "vnet_lng01" {
  count               = local.num01
  name                = "vnet-lng-1${count.index}"
  location            = var.location
  resource_group_name = var.resource_group_name
  gateway_address     = azurerm_public_ip.public_ip_vnet01[count.index].ip_address

  bgp_settings {
    asn                 = local.bgp_asn[count.index]
    bgp_peering_address = azurerm_virtual_network_gateway.vnet_gw[count.index].bgp_settings[0].peering_addresses[0].default_addresses[0]
  }

  depends_on = [
    azurerm_public_ip.public_ip_vnet01
  ]

}

resource "azurerm_local_network_gateway" "vnet_lng02" {
  count               = local.num01
  name                = "vnet-lng-2${count.index}"
  location            = var.location
  resource_group_name = var.resource_group_name
  gateway_address     = azurerm_public_ip.public_ip_vnet02[count.index].ip_address

  bgp_settings {
    asn                 = local.bgp_asn[count.index]
    bgp_peering_address = azurerm_virtual_network_gateway.vnet_gw[count.index].bgp_settings[0].peering_addresses[1].default_addresses[0]
  }

  depends_on = [
    azurerm_public_ip.public_ip_vnet02
  ]

}


################# Create V2V connections #################
resource "azurerm_virtual_network_gateway_connection" "v2v_gw_connection01" {
  name                            = "connection-from-${azurerm_virtual_network_gateway.vnet_gw[0].name}-to-${azurerm_virtual_network_gateway.vnet_gw[1].name}"
  location                        = var.location
  resource_group_name             = var.resource_group_name
  virtual_network_gateway_id      = azurerm_virtual_network_gateway.vnet_gw[0].id
  peer_virtual_network_gateway_id = azurerm_virtual_network_gateway.vnet_gw[1].id
  type                            = "Vnet2Vnet"
  shared_key                      = "AzureA1b2C3"
  enable_bgp                      = true
}

resource "azurerm_virtual_network_gateway_connection" "v2v_gw_connection02" {
  name                            = "connection-from-${azurerm_virtual_network_gateway.vnet_gw[1].name}-to-${azurerm_virtual_network_gateway.vnet_gw[0].name}"
  location                        = var.location
  resource_group_name             = var.resource_group_name
  virtual_network_gateway_id      = azurerm_virtual_network_gateway.vnet_gw[1].id
  peer_virtual_network_gateway_id = azurerm_virtual_network_gateway.vnet_gw[0].id
  type                            = "Vnet2Vnet"
  shared_key                      = "AzureA1b2C3"
  enable_bgp                      = true
}

################# Create S2S connections #################
resource "azurerm_virtual_network_gateway_connection" "s2s_from_cloud_to_onprem_connection01" {
  count                      = local.num01
  name                       = "connection01-from-${azurerm_virtual_network_gateway.vnet_gw[count.index].name}-to-${azurerm_local_network_gateway.onprem_vnet_lng01[count.index].name}"
  location                   = var.location
  resource_group_name        = var.resource_group_name
  virtual_network_gateway_id = azurerm_virtual_network_gateway.vnet_gw[count.index].id
  local_network_gateway_id   = azurerm_local_network_gateway.onprem_vnet_lng01[count.index].id
  type                       = "IPsec"
  shared_key                 = "AzureA1b2C3"
  enable_bgp                 = true
}

resource "azurerm_virtual_network_gateway_connection" "s2s_from_onprem_to_cloud_connection01" {
  count                      = local.num01
  name                       = "connection01-from-${azurerm_virtual_network_gateway.onprem_vnet_gw[count.index].name}-to-${azurerm_local_network_gateway.vnet_lng01[count.index].name}"
  location                   = var.location
  resource_group_name        = var.resource_group_name
  virtual_network_gateway_id = azurerm_virtual_network_gateway.onprem_vnet_gw[count.index].id
  local_network_gateway_id   = azurerm_local_network_gateway.vnet_lng01[count.index].id
  type                       = "IPsec"
  shared_key                 = "AzureA1b2C3"
  enable_bgp                 = true
}

resource "azurerm_virtual_network_gateway_connection" "s2s_from_cloud_to_onprem_connection02" {
  count                      = local.num01
  name                       = "connection02-from-${azurerm_virtual_network_gateway.vnet_gw[count.index].name}-to-${azurerm_local_network_gateway.onprem_vnet_lng02[count.index].name}"
  location                   = var.location
  resource_group_name        = var.resource_group_name
  virtual_network_gateway_id = azurerm_virtual_network_gateway.vnet_gw[count.index].id
  local_network_gateway_id   = azurerm_local_network_gateway.onprem_vnet_lng02[count.index].id
  type                       = "IPsec"
  shared_key                 = "AzureA1b2C3"
  enable_bgp                 = true
}

resource "azurerm_virtual_network_gateway_connection" "s2s_from_onprem_to_cloud_connection02" {
  count                      = local.num01
  name                       = "connection02-from-${azurerm_virtual_network_gateway.onprem_vnet_gw[count.index].name}-to-${azurerm_local_network_gateway.vnet_lng02[count.index].name}"
  location                   = var.location
  resource_group_name        = var.resource_group_name
  virtual_network_gateway_id = azurerm_virtual_network_gateway.onprem_vnet_gw[count.index].id
  local_network_gateway_id   = azurerm_local_network_gateway.vnet_lng02[count.index].id
  type                       = "IPsec"
  shared_key                 = "AzureA1b2C3"
  enable_bgp                 = true
}