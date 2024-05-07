output "postgres_subnet_id" {
  value = azurerm_subnet.postgressubnet.id
}

output "vm_subnet_id" {
  value = azurerm_subnet.vmsubnet.id
}

output "private_dns_zone_id" {
  value = azurerm_private_dns_zone.example.id
}