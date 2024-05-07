# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

## Terraform configuration

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.54.0"
    }

    random = {
      source  = "hashicorp/random"
      version = "3.3.2"
    }
  }

  required_version = ">= 1.6.0"
}

provider "azurerm" {
  features {
    key_vault {
      purge_soft_deleted_secrets_on_destroy = true
      recover_soft_deleted_secrets          = true
    }
  }

  subscription_id = var.subscription_id
  client_id       = var.client_id
  client_secret   = var.client_secret
  tenant_id       = var.tenant_id
}

resource "azurerm_resource_group" "example" {
  name     = "rg-${var.prefix}"
  location = var.location
}

module "network" {
  source = "./modules/network"

  location            = var.location
  prefix              = var.prefix
  resource_group_name = azurerm_resource_group.example.name
  network_range       = var.network_range
  number_of_subnets   = var.number_of_subnets
}

module "virtual-machine" {
  source = "./modules/virtual-machine"

  location            = var.location
  prefix              = var.prefix
  resource_group_name = azurerm_resource_group.example.name
  vm_subnet_id        = module.network.vm_subnet_id
}

module "postgresql" {
  source = "./modules/postgresql"

  location               = var.location
  prefix                 = var.prefix
  resource_group_name    = azurerm_resource_group.example.name
  postgres_subnet_id     = module.network.postgres_subnet_id
  private_dns_zone_id    = module.network.private_dns_zone_id
  administrator_login    = module.key-vault.database_username
  administrator_password = module.key-vault.database_password
}

module "key-vault" {
  source = "./modules/key-vault"

  location            = var.location
  prefix              = var.prefix
  resource_group_name = azurerm_resource_group.example.name
  database_username   = var.database_username
  database_password   = var.database_password
}