terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.8"
    }
  }
}

provider "azurerm" {
  features {}

  subscription_id = var.subscription_id
  tenant_id       = var.tenant_id
  client_id       = var.client_id
  client_secret   = var.client_secret
}

# add resource group
resource "azurerm_resource_group" "rg" {
  name     = "${var.prefix}-rg"
  location = var.location
}

#add module for network
module "network" {
  source = "./modules/network"

  prefix              = var.prefix
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  # dns vnet parameters
  dns_vnet_address_space        = var.dns_vnet_address_space
  inbound_subnet_address_space  = local.inbound_subnet_address_space
  outbound_subnet_address_space = local.outbound_subnet_address_space
  gateway_subnet_address_space  = local.gateway_subnet_address_space
  # peering vnet parameters
  peering_vnet_address_space   = var.peering_vnet_address_space
  peering_subnet_address_space = local.peering_subnet_address_space
  pe_subnet_address_space      = local.pe_subnet_address_space
  vm_peer_private_ip_address   = local.vm_peer_private_ip_address
  # onprem vnet parameters
  onprem_address_space                = var.onprem_address_space
  onprem_subnet_address_space         = local.onprem_subnet_address_space
  onprem_gateway_subnet_address_space = local.onprem_gateway_subnet_address_space
  vm_onprem_private_ip_address        = local.vm_onprem_private_ip_address
  inbound_endpoint_ip_address         = module.dns.inbound_endpoint_ip_address
}

# add module for dns zone
module "dns" {
  source = "./modules/dns"

  prefix                     = var.prefix
  location                   = var.location
  resource_group_name        = azurerm_resource_group.rg.name
  dns_virtual_network_id     = module.network.dns_virtual_network_id
  peering_virtual_network_id = module.network.peering_virtual_network_id
  inbound_subnet_id          = module.network.inbound_subnet_id
  outbound_subnet_id         = module.network.outbound_subnet_id
  onprem_dns_ip              = local.vm_onprem_private_ip_address
  domain_name                = var.domain_name
}

# add module for virtual machine
module "vm" {
  source = "./modules/virtual-machine"

  prefix                       = var.prefix
  location                     = var.location
  resource_group_name          = azurerm_resource_group.rg.name
  onprem_subnet_id             = module.network.onprem_subnet_id
  peering_subnet_id            = module.network.peering_subnet_id
  vm_peer_private_ip_address   = local.vm_peer_private_ip_address
  vm_onprem_private_ip_address = local.vm_onprem_private_ip_address
  domain_name                  = var.domain_name
  domain_netbios_name          = var.domain_netbios_name
  domain_admin_username        = var.domain_admin_username
  domain_admin_password        = var.domain_admin_password
}

#add module for private endpoint
module "private_endpoint" {
  source = "./modules/pe"

  location               = var.location
  resource_group_name    = azurerm_resource_group.rg.name
  dns_virtual_network_id = module.network.dns_virtual_network_id
  pe_subnet_id           = module.network.peering_subnet_id
}