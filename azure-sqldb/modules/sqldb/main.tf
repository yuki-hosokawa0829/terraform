# sql server
resource "azurerm_mssql_server" "server_primary" {
  name                         = "${var.prefix}-primary"
  resource_group_name          = var.resource_group_name
  location                     = var.location
  version                      = "12.0"
  administrator_login          = local.sqldatabase_username
  administrator_login_password = local.sqldatabase_password
}

resource "azurerm_mssql_server" "server_secondary" {
  name                         = "${var.prefix}-secondary"
  resource_group_name          = var.resource_group_name
  location                     = var.location
  version                      = "12.0"
  administrator_login          = local.sqldatabase_username
  administrator_login_password = local.sqldatabase_password
}

resource "azurerm_mssql_server" "server_elasticpool" {
  name                         = "${var.prefix}-elasticpool"
  resource_group_name          = var.resource_group_name
  location                     = var.location
  version                      = "12.0"
  administrator_login          = local.sqldatabase_username
  administrator_login_password = local.sqldatabase_password
}

# sql database
resource "azurerm_mssql_database" "db_primary" {
  name        = "${var.prefix}-db-primary"
  sku_name    = local.sku_name
  server_id   = azurerm_mssql_server.server_primary.id
  create_mode = "Default"
}

resource "azurerm_mssql_database" "db_secondary" {
  name                        = "${var.prefix}-db-secondary"
  sku_name                    = local.sku_name
  server_id                   = azurerm_mssql_server.server_secondary.id
  create_mode                 = "OnlineSecondary"
  creation_source_database_id = azurerm_mssql_database.db_primary.id
}

# add service endpoint to the subnet
## primary
resource "azurerm_mssql_virtual_network_rule" "sqlvnetrule_primary" {
  count     = length(var.subnet_ids)
  name      = "${var.prefix}-sqlvnetrule-primary${count.index}"
  server_id = azurerm_mssql_server.server_primary.id
  subnet_id = var.subnet_ids[count.index]
}

## secondary
resource "azurerm_mssql_virtual_network_rule" "sqlvnetrule_secondary" {
  count     = length(var.subnet_ids)
  name      = "${var.prefix}-sqlvnetrule-secondary${count.index}"
  server_id = azurerm_mssql_server.server_secondary.id
  subnet_id = var.subnet_ids[count.index]
}

# SQL elastic pool
resource "azurerm_mssql_elasticpool" "example" {
  name                = "${var.prefix}-elasticpool"
  resource_group_name = var.resource_group_name
  location            = var.location
  server_name         = azurerm_mssql_server.server_elasticpool.name
  max_size_gb         = 100

  sku {
    name     = "StandardPool"
    tier     = "Standard"
    capacity = 50
  }

  per_database_settings {
    min_capacity = 0
    max_capacity = 10
  }
}