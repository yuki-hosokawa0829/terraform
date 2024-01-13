terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.79.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.5.1"
    }
  }
}

provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy = true
    }
  }

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
  prefix              = var.prefix
  resource_group_name = azurerm_resource_group.rg.name
  virtual_hub_id      = module.azure_virtual_wan.virtual_hub_id
}

module "azure_virtual_wan" {
  source = "./modules/wan"

  regions             = var.regions
  prefix              = var.prefix
  resource_group_name = azurerm_resource_group.rg.name
  virtual_hub_id      = module.azure_virtual_wan.virtual_hub_id
  #usr_tenant_id       = var.usr_tenant_id
}

module "virtual_machine" {
  source = "./modules/virtual-machine"

  regions              = var.regions
  prefix               = var.prefix
  resource_group_name  = azurerm_resource_group.rg.name
  identity1_subnet_id  = module.network.identity1_subnet_id
  identity2_subnet_id  = module.network.identity2_subnet_id
  local_admin_username = var.local_admin_username
  vmpassword           = module.key_vault.vmpassword
  vmsize               = var.vmsize
}

module "key_vault" {
  source = "./modules/key-vault"

  regions             = var.regions
  resource_group_name = azurerm_resource_group.rg.name
}

module "azure_firewall" {
  source = "./modules/firewall"

  regions             = var.regions
  prefix              = var.prefix
  resource_group_name = azurerm_resource_group.rg.name
  virtual_hub_id      = module.azure_virtual_wan.virtual_hub_id
}

module "azure_bastion" {
  source = "./modules/bastion"

  regions               = var.regions
  prefix                = var.prefix
  resource_group_name   = azurerm_resource_group.rg.name
  management1_subnet_id = module.network.management1_subnet_id
}