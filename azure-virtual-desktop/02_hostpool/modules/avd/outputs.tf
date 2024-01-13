output "registration_token" {
  value = azurerm_virtual_desktop_host_pool_registration_info.registrationinfo.token
}

output "azure_virtual_desktop_application_group_id" {
  value = azurerm_virtual_desktop_application_group.dag.id
}