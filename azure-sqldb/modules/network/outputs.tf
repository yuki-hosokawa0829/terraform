output "subnet_ids" {
  value = azurerm_subnet.example[*].id
}