variable "prefix" {
  default = "dns"
}

variable "location" {
  default = "japanwest"
}

variable "dns_vnet_address_space" {
  default = "10.0.0.0/16"
}

variable "peering_vnet_address_space" {
  default = "10.1.0.0/16"
}

variable "onprem_address_space" {
  default = "192.168.0.0/24"
}

variable "domain_name" {
  default = "example.local"
}

variable "domain_netbios_name" {
  default = "EXAMPLE"
}

variable "domain_admin_username" {
  default = "azureadmin"
}

variable "domain_admin_password" {
  default = "P@ssw0rd0123"
}

variable "usr_subscription_id" {
  description = "The Azure Subscription ID"
  default     = "your-azure-subscription-id"
}

variable "usr_tenant_id" {
  description = "Tenant ID"
  default     = "your-entra-id-tenant-id"
}

variable "usr_client_id" {
  description = "Service Principal ID"
  default     = "your-terraform-service-principal-id"
}

variable "usr_client_secret" {
  description = "Password for the Administrator account"
  default     = "your-terraform-service-principal-secrets"
}

locals {
  # cloud parameters
  inbound_subnet_address_space  = cidrsubnet("${var.dns_vnet_address_space}", 8, 0)
  outbound_subnet_address_space = cidrsubnet("${var.dns_vnet_address_space}", 8, 1)
  gateway_subnet_address_space  = cidrsubnet("${var.dns_vnet_address_space}", 8, 2)
  # peering parameters
  peering_subnet_address_space = cidrsubnet("${var.peering_vnet_address_space}", 8, 0)
  pe_subnet_address_space      = cidrsubnet("${var.peering_vnet_address_space}", 8, 1)
  vm_peer_private_ip_address   = cidrhost("${local.peering_subnet_address_space}", 4)
  # onprem parameters
  onprem_subnet_address_space         = cidrsubnet("${var.onprem_address_space}", 4, 0)
  onprem_gateway_subnet_address_space = cidrsubnet("${var.onprem_address_space}", 4, 1)
  vm_onprem_private_ip_address        = cidrhost("${local.onprem_subnet_address_space}", 4)
}