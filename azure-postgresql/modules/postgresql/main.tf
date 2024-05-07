resource "azurerm_postgresql_flexible_server" "example" {
  name                   = "${var.prefix}-postgreserver"
  resource_group_name    = var.resource_group_name
  location               = var.location
  version                = "13"
  delegated_subnet_id    = var.postgres_subnet_id
  private_dns_zone_id    = var.private_dns_zone_id
  administrator_login    = var.administrator_login
  administrator_password = var.administrator_password
  zone                   = "1"
  storage_mb             = 32768
  sku_name               = "GP_Standard_D2s_v3"
  backup_retention_days  = 7
}

resource "azurerm_postgresql_flexible_server_database" "example" {
  name      = "${var.prefix}-db"
  server_id = azurerm_postgresql_flexible_server.example.id
  collation = "en_US.utf8"
  charset   = "UTF8"
}