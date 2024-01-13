# add public ip for route server
resource "azurerm_public_ip" "route_server_public_ip" {
  name                = "route-server-pip"
  resource_group_name = var.resource_group_name
  location            = var.location
  allocation_method   = "Static"
  sku                 = "Standard"
}

# add azure route server
resource "azurerm_route_server" "route_server" {
  name                             = "route-server"
  resource_group_name              = var.resource_group_name
  location                         = var.location
  sku                              = "Standard"
  public_ip_address_id             = azurerm_public_ip.route_server_public_ip.id
  subnet_id                        = var.vnet_route_server_subnet_id
  branch_to_branch_traffic_enabled = true
}

# add route server bgp connection to peer_gateway
resource "azurerm_route_server_bgp_connection" "route_server_bgp_connection01" {
  name            = "route-server-bgp-connection01"
  route_server_id = azurerm_route_server.route_server.id
  peer_asn        = var.vnet_peer_as_number
  peer_ip         = var.peer_vpg_ip01
}


resource "azurerm_route_server_bgp_connection" "route_server_bgp_connection02" {
  name            = "route-server-bgp-connection02"
  route_server_id = azurerm_route_server.route_server.id
  peer_asn        = var.vnet_peer_as_number
  peer_ip         = var.peer_vpg_ip02
}

/* # add route server bgp connection to vpn_gateway
resource "azurerm_route_server_bgp_connection" "route_server_bgp_connection03" {
  name            = "route-server-bgp-connection03"
  route_server_id = azurerm_route_server.route_server.id
  peer_asn        = var.vnet_as_number
  peer_ip         = var.vnet_vpg_ip01
}

resource "azurerm_route_server_bgp_connection" "route_server_bgp_connection04" {
  name            = "route-server-bgp-connection04"
  route_server_id = azurerm_route_server.route_server.id
  peer_asn        = var.vnet_as_number
  peer_ip         = var.vnet_vpg_ip02
} */