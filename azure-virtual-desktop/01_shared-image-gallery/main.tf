# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

provider "azurerm" {
  features {}
  subscription_id = var.usr_subscription_id
  tenant_id       = var.usr_tenant_id
  client_id       = var.usr_client_id
  client_secret   = var.usr_client_secret
}

resource "azurerm_resource_group" "rg" {
  location = var.location
  name     = "${var.prefix}-rg"
}

# add custom role
resource "azurerm_role_definition" "custom_role" {
  name        = "ImageBuilder"
  description = "ImageBuilder"
  scope       = azurerm_resource_group.rg.id

  permissions {

    actions = [
      "Microsoft.Compute/galleries/read",
      "Microsoft.Compute/galleries/images/read",
      "Microsoft.Compute/galleries/images/versions/read",
      "Microsoft.Compute/galleries/images/versions/write",
      "Microsoft.Compute/images/read",
      "Microsoft.Compute/images/write",
      "Microsoft.Compute/images/delete"
    ]

    not_actions = []

  }

  assignable_scopes = [azurerm_resource_group.rg.id]
}

# add managed ID
resource "azurerm_user_assigned_identity" "managed_id" {
  name                = "ImageBuilderManagedId"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
}

# assign custom role to managed ID
resource "azurerm_role_assignment" "managed_id_role" {
  scope                = azurerm_resource_group.rg.id
  role_definition_name = azurerm_role_definition.custom_role.name
  principal_id         = azurerm_user_assigned_identity.managed_id.principal_id
}

# add shared image gallery
resource "azurerm_shared_image_gallery" "sig" {
  name                = "SharedImageGallery"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  description         = "Shared Image Gallery"
}

/* # add random string
resource "random_string" "random" {
  length  = 6
  lower   = true
  upper   = false
  numeric = true
  special = false
} */

# add storage account
resource "azurerm_storage_account" "storage" {
  name                     = "storagenncd2d"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

# add file share
resource "azurerm_storage_share" "share" {
  name                 = "fslogix"
  storage_account_name = azurerm_storage_account.storage.name
  quota                = 50
}