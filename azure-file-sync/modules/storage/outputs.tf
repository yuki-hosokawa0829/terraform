# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

output "storage_share_name" {
  value = azurerm_storage_share.example.name
}

output "storage_account_id" {
  value = azurerm_storage_account.example.id
}

output "storage_blob_url" {
  value = azurerm_storage_blob.example.url
}