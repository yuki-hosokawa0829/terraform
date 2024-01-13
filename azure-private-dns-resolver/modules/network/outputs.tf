# add output for dns virtual network id
output "dns_virtual_network_id" {
  value = azurerm_virtual_network.dns_virtual_network.id
}

# add output for peer virtual network id
output "peering_virtual_network_id" {
  value = azurerm_virtual_network.peering_virtual_network.id
}

# add output for inbound subnet id
output "inbound_subnet_id" {
  value = azurerm_subnet.inbound_subnet.id
}

# add output for outbound subnet id
output "outbound_subnet_id" {
  value = azurerm_subnet.outbound_subnet.id
}

# add output for virtual network peering subnet id
output "peering_subnet_id" {
  value = azurerm_subnet.peering_subnet.id
}

# add output for virtual network pe subnet id
output "pe_subnet_id" {
  value = azurerm_subnet.pe_subnet.id
}

# add output for virtual network onprem subnet id
output "onprem_subnet_id" {
  value = azurerm_subnet.onprem_subnet.id
} 