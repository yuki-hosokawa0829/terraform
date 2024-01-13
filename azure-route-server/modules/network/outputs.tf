output "peer_vpg_ip01" {
  value = azurerm_virtual_network_gateway.vnet_peer_gateway.bgp_settings.0.peering_addresses.0.default_addresses.0
}

output "peer_vpg_ip02" {
  value = azurerm_virtual_network_gateway.vnet_peer_gateway.bgp_settings.0.peering_addresses.1.default_addresses.0
}

output "vnet_vpg_ip01" {
  value = azurerm_virtual_network_gateway.vnet_gateway.bgp_settings.0.peering_addresses.0.default_addresses.0
}

output "vnet_vpg_ip02" {
  value = azurerm_virtual_network_gateway.vnet_gateway.bgp_settings.0.peering_addresses.1.default_addresses.0
}

output "vnet_route_server_subnet_id" {
  value = azurerm_subnet.vnet_route_server_subnet.id
}

output "vnet_subnet_id" {
  value = azurerm_subnet.vnet_subnet.id
}

output "vnet_peer_subnet_id" {
  value = azurerm_subnet.vnet_peer_subnet.id
}

output "vnet_vpn_subnet_id" {
  value = azurerm_subnet.vnet_vpn_subnet.id
}

output "vnet_onprem_subnet_id" {
  value = azurerm_subnet.vnet_onprem_subnet.id
}