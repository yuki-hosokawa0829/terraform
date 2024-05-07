# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

## Terraform configuration

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.54.0"
    }
  }

  required_version = ">= 1.6.0"
}

provider "azurerm" {
  features {}

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

module "sqldb" {
  source = "./modules/sqldb"

  location            = var.location
  prefix              = var.prefix
  resource_group_name = azurerm_resource_group.example.name
  subnet_ids          = module.network.subnet_ids
}