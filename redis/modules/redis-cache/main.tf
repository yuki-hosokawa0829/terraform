resource "azurerm_redis_cache" "example" {
  name                = "redis-${var.prefix}"
  location            = var.location
  resource_group_name = var.resource_group_name
  capacity            = 1
  family              = "C"
  sku_name            = "Basic"
  enable_non_ssl_port = false
  redis_version       = "6"
  minimum_tls_version = "1.2"

  redis_configuration {}
}