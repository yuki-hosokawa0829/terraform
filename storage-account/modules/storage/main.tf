resource "azurerm_storage_account" "name" {
  name                            = "storageykfortest${var.prefix}"
  resource_group_name             = var.resource_group_name
  location                        = var.location
  account_tier                    = "Standard"
  account_replication_type        = "LRS"
  enable_https_traffic_only       = true
  allow_nested_items_to_be_public = false
  is_hns_enabled                  = false

  dynamic "blob_properties" {
    for_each = var.storage_type < 3 ? [1] : []
    content {
      cors_rule {
        allowed_headers    = ["*"]
        allowed_methods    = ["GET", "PUT"]
        allowed_origins    = ["https://${var.blob_allowed_origin_url}"]
        exposed_headers    = ["*"]
        max_age_in_seconds = 3600
      }
      cors_rule {
        allowed_headers    = ["*"]
        allowed_methods    = ["GET", "PUT"]
        allowed_origins    = ["https://www.${var.blob_allowed_origin_url}"]
        exposed_headers    = ["*"]
        max_age_in_seconds = 3600
      }
      cors_rule {
        allowed_headers    = ["*"]
        allowed_methods    = ["GET", "PUT"]
        allowed_origins    = ["https://${var.agw_pip}"]
        exposed_headers    = ["*"]
        max_age_in_seconds = 3600
      }
    }
  }
}