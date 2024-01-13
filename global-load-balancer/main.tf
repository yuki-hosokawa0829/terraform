provider "azurerm" {
  features {}
  subscription_id = var.usr_subscription_id
  tenant_id       = var.usr_tenant_id
  client_id       = var.usr_client_id
  client_secret   = var.usr_client_secret
}

resource "azurerm_resource_group" "rg" {
  location = var.regions.region1.location
  name     = "${var.prefix}-rg"
}

module "network" {
  source = "./modules/network"

  regions             = var.regions
  resource_group_name = azurerm_resource_group.rg.name
}

module "load_balancer" {
  source = "./modules/load-balancer"

  regions             = var.regions
  prefix              = var.prefix
  resource_group_name = azurerm_resource_group.rg.name
  vm_nic_id           = module.virtual_machine.vm_nic_id
}

module "virtual_machine" {
  source = "./modules/virtual-machine"

  regions                    = var.regions
  prefix                     = var.prefix
  resource_group_name        = azurerm_resource_group.rg.name
  vnet_con_id                = module.network.vnet_con_id
  subnet_private_endpoint_id = module.network.subnet_private_endpoint_id
  subnet_con_id              = module.network.subnet_con_id
  local_admin_username       = var.local_admin_username
  local_admin_password       = module.key_vault.vmpassword
}

module "key_vault" {
  source = "./modules/key-vault"

  regions             = var.regions
  prefix              = var.prefix
  resource_group_name = azurerm_resource_group.rg.name
}

module "bastion" {
  source = "./modules/bastion"

  regions             = var.regions
  prefix              = var.prefix
  resource_group_name = azurerm_resource_group.rg.name
  subnet_bastion_id   = module.network.subnet_bastion_id
}