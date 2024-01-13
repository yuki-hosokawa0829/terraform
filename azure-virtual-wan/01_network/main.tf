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
  location = var.location01
  name     = "${var.prefix}-rg"
}

module "network_component" {
  source = "./modules/network-component"

  location01                               = var.location01
  location02                               = var.location02
  prefix                                   = var.prefix
  resource_group_name                      = azurerm_resource_group.rg.name
  vhub_location01_address_range            = var.vhub_location01_address_range
  vhub_location02_address_range            = var.vhub_location02_address_range
  network_jw_address_range                 = var.network_jw_address_range
  network_je_address_range                 = var.network_je_address_range
  network_onprem_address_range             = var.network_onprem_address_range
  domain_controllers_jw_address_range      = local.domain_controllers_jw_address_range
  domain_controllers_je_address_range      = local.domain_controllers_je_address_range
  domain_controllers_onprem_address_range  = local.domain_controllers_onprem_address_range
  domain_controllers_gateway_address_range = local.domain_controller_onprem_gateway_address_range
  dc_jw_private_address                    = local.dc_jw_private_address
  dc_je_private_address                    = local.dc_je_private_address
  dc_onprem_private_address                = local.dc_onprem_private_address
  instance_0_pip                           = module.azure_virtual_wan.instance_0_pip
  instance_1_pip                           = module.azure_virtual_wan.instance_1_pip
}

module "azure_virtual_wan" {
  source = "./modules/wan"

  location01                    = var.location01
  location02                    = var.location02
  prefix                        = var.prefix
  resource_group_name           = azurerm_resource_group.rg.name
  vhub_location01_address_range = var.vhub_location01_address_range
  vhub_location02_address_range = var.vhub_location02_address_range
  network_onprem_address_range  = var.network_onprem_address_range
  network_jw_id                 = module.network_component.network_jw_id
  network_je_id                 = module.network_component.network_je_id
  vpngw_pip                     = module.network_component.vpngw_pip
  dc_jw_private_address         = local.dc_jw_private_address
}
