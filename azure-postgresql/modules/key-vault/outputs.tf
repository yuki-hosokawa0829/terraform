output "database_username" {
  value       = azurerm_key_vault_secret.database_username.value
  description = "Database username"
}

output "database_password" {
  value       = azurerm_key_vault_secret.database_password.value
  description = "Database password"
}