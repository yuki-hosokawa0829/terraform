# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

provider "azurerm" {
  features {}
  subscription_id = var.usr_subscription_id
  tenant_id       = var.usr_tenant_id
  client_id       = var.usr_client_id
  client_secret   = var.usr_client_secret
}

provider "azuread" {}

resource "azurerm_resource_group" "example" {
  location = var.location
  name     = "${var.prefix}-rg"
}

module "network" {
  source = "./modules/network"

  location                             = var.location
  prefix                               = var.prefix
  resource_group_name                  = azurerm_resource_group.example.name
  virtual_network_address_space        = var.virtual_network_address_space
  virtual_network_onprem_address_space = var.virtual_network_onprem_address_space
}

module "storage" {
  source = "./modules/storage"

  location            = var.location
  prefix              = var.prefix
  resource_group_name = azurerm_resource_group.example.name
  subnet_id           = module.network.file_server_subnet_id
  subnet_onprem_id    = module.network.file_server_onprem_subnet_id
  resource_group_id   = azurerm_resource_group.example.id
}

module "virtual_machines" {
  source = "./modules/virtual-machines"

  location                      = var.location
  prefix                        = var.prefix
  resource_group_name           = azurerm_resource_group.example.name
  active_directory_domain_name  = "${var.prefix}.local"
  active_directory_netbios_name = var.prefix
  admin_username                = var.admin_username
  admin_password                = var.admin_password
  virtual_network_address_space = var.virtual_network_address_space
  subnet_id                     = module.network.file_server_subnet_id
  subnet_onprem_id              = module.network.file_server_onprem_subnet_id
  subnet_dc_id                  = module.network.domain_contoller_subnet_id
  storage_id                    = module.storage.storage_account_id
  storage_blob_url              = module.storage.storage_blob_url
}

module "role" {
  source = "./modules/role"

  vm_principal_id        = module.virtual_machines.principal_id
  vm_onprem_principal_id = module.virtual_machines.onprem_principal_id
  storage_id             = module.storage.storage_account_id
}

module "azure_file_sync" {
  source = "./modules/azure-file-sync"

  location            = var.location
  resource_group_name = azurerm_resource_group.example.name
  share_name          = module.storage.storage_share_name
  storage_id          = module.storage.storage_account_id
}
