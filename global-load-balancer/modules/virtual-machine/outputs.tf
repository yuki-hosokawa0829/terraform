output "vm_nic_id" {
  value = [for nic in azurerm_network_interface.nics : nic.id]
}

/* output "ps_url" {
  value = azurerm_storage_blob.ps_script.url
} */

/* output "record" {
  value = [for pe in azurerm_private_endpoint.private_endpoint : pe.private_service_connection]
} */