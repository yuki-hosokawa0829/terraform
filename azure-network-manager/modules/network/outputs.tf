output "subnet_id01" {
  value = azurerm_subnet.subnet_vnet01[*].id
}

output "subnet_id02" {
  value = azurerm_subnet.subnet_vnet02[*].id
}

output "subnet_id03" {
  value = azurerm_subnet.subnet_vnet03[*].id
}