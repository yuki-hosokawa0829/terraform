output "connection_string" {
  value = azurerm_redis_cache.example.primary_access_key
}