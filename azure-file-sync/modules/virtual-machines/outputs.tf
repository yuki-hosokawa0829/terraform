output "principal_id" {
  value = azurerm_windows_virtual_machine.file_server.identity.0.principal_id
}

output "onprem_principal_id" {
  value = azurerm_windows_virtual_machine.file_server_onprem.identity.0.principal_id
}