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

module "network" {
  source = "./modules/network"

  location                      = var.location
  prefix                        = var.prefix
  resource_group_name           = azurerm_resource_group.rg.name
  virtual_network_address_space = var.virtual_network_address_space
}

module "nat_gateway" {
  source = "./modules/nat-gateway"

  location            = var.location
  prefix              = var.prefix
  resource_group_name = azurerm_resource_group.rg.name
  nat_subnet_id       = module.network.nat_subnet_id
}

module "virtual_machine" {
  source = "./modules/virtual-machine"

  location             = var.location
  prefix               = var.prefix
  resource_group_name  = azurerm_resource_group.rg.name
  nat_subnet_id        = module.network.nat_subnet_id
  admin_subnet_id      = module.network.admin_subnet_id
  local_admin_username = var.local_admin_username
  local_admin_password = var.local_admin_password
}