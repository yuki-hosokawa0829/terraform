output "subnet_id" {
  value = azurerm_subnet.subnet_vnet[*].id
}

output "subnet_onprem_id" {
  value = azurerm_subnet.subnet_onprem_vnet[*].id
}