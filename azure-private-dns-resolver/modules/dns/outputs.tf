output "inbound_endpoint_ip_address" {
  value = azurerm_private_dns_resolver_inbound_endpoint.inbound_endpoint.ip_configurations[0].private_ip_address
}