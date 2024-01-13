resource "azurerm_storage_sync" "example" {
  name                = "sync01"
  resource_group_name = var.resource_group_name
  location            = var.location
}

resource "azurerm_storage_sync_group" "example" {
  name            = "group01"
  storage_sync_id = azurerm_storage_sync.example.id
}

resource "azurerm_storage_sync_cloud_endpoint" "example" {
  name                  = "cloudendpoint01"
  storage_sync_group_id = azurerm_storage_sync_group.example.id
  file_share_name       = var.share_name
  storage_account_id    = var.storage_id
}