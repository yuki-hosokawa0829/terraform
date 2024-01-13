# random string for storage account name
resource "random_string" "random" {
  length  = 8
  lower   = true
  upper   = false
  special = false
  numeric = false
}

# add storage account
resource "azurerm_storage_account" "storage" {
  name                     = "sto${random_string.random.result}"
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

# add storage account blob container
resource "azurerm_storage_container" "storage" {
  name                  = "container01"
  storage_account_name  = azurerm_storage_account.storage.name
  container_access_type = "private"
}

# add private endpoint to the storage account
resource "azurerm_private_endpoint" "endpoint" {
  name                = "storage-private-endpoint"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.pe_subnet_id

  private_service_connection {
    name                           = "storage-private-endpoint-connection"
    private_connection_resource_id = azurerm_storage_account.storage.id
    subresource_names              = ["blob"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "storage-private-endpoint-dns-zone-group"
    private_dns_zone_ids = [azurerm_private_dns_zone.zone.id]
  }
}

# add private dns zone
resource "azurerm_private_dns_zone" "zone" {
  name                = "privatelink.blob.core.windows.net"
  resource_group_name = var.resource_group_name
}

# add private dns zone virtual network link
resource "azurerm_private_dns_zone_virtual_network_link" "link" {
  name                  = "link01"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.zone.name
  virtual_network_id    = var.dns_virtual_network_id
}