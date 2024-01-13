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
  default = "ppt-admin"
}

variable "domain_admin_password" {
  default = "P@ssw0rd0123"
}

variable "subscription_id" {
  default = "4d55c914-726b-4a03-b002-54c4bf217ad5"
}

variable "tenant_id" {
  default = "9781ab08-ef7d-4e4f-b6f0-c595b7a023cb"
}

variable "client_id" {
  default = "78fedf0d-7c87-4643-b4dc-13062b0752ed"
}

variable "client_secret" {
  default = "eQ28Q~S5MT4nodAKe3MrLD_mnVQyb7zXP3HanaxE"
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