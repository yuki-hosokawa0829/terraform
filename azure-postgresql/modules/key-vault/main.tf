data "azurerm_client_config" "current" {}

resource "random_string" "keyvault_name" {
  length  = 6
  special = false
}

resource "azurerm_key_vault" "example" {
  name                       = "${var.prefix}${random_string.keyvault_name.result}keyvault"
  location                   = var.location
  resource_group_name        = var.resource_group_name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  sku_name                   = "standard"
  soft_delete_retention_days = 7

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    key_permissions = [
      "Create",
      "Get",
    ]

    secret_permissions = [
      "Set",
      "Get",
      "Delete",
      "Purge",
      "Recover"
    ]
  }
}

resource "azurerm_key_vault_secret" "database_username" {
  name         = "${var.prefix}-username"
  value        = var.database_username
  key_vault_id = azurerm_key_vault.example.id
}

resource "azurerm_key_vault_secret" "database_password" {
  name         = "${var.prefix}-password"
  value        = var.database_password
  key_vault_id = azurerm_key_vault.example.id
}