# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

resource "azurerm_storage_account" "example" {
  name                     = join("", ["${var.prefix}", "${random_string.random.result}"])
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_share" "example" {
  name                 = "share01"
  storage_account_name = azurerm_storage_account.example.name
  quota                = 50
}

resource "azurerm_storage_container" "example" {
  name                  = "blob01"
  storage_account_name  = azurerm_storage_account.example.name
  container_access_type = "private"
}

resource "azurerm_storage_blob" "example" {
  name                   = "init_storagesyncagent.ps1"
  storage_account_name   = azurerm_storage_account.example.name
  storage_container_name = azurerm_storage_container.example.name
  type                   = "Block"
  source_content         = file("./modules/storage/init_storagesyncagent.ps1")
}

resource "azurerm_storage_account_network_rules" "example" {
  storage_account_id         = azurerm_storage_account.example.id
  ip_rules                   = ["219.166.164.110"]
  default_action             = "Deny"
  virtual_network_subnet_ids = [var.subnet_id, var.subnet_onprem_id]
  bypass                     = ["AzureServices"]
}

resource "random_string" "random" {
  length  = 10
  lower   = true
  upper   = false
  special = false
  numeric = false
}