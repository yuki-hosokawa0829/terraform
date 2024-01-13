variable "prefix" {}

variable "location" {}

variable "resource_group_name" {}

variable "dns_vnet_address_space" {}

variable "peering_vnet_address_space" {}

variable "inbound_subnet_address_space" {}

variable "outbound_subnet_address_space" {}

variable "gateway_subnet_address_space" {}

variable "peering_subnet_address_space" {}

variable "pe_subnet_address_space" {}

variable "onprem_address_space" {}

variable "onprem_subnet_address_space" {}

variable "onprem_gateway_subnet_address_space" {}

variable "vm_peer_private_ip_address" {}

variable "vm_onprem_private_ip_address" {}

variable "inbound_endpoint_ip_address" {}

locals {
  /* # cloud parameters
    inbound_subnet_address_space        = "cidrsubnet(${var.dns_vnet_address_space}, 8, 0)"
    outbound_subnet_address_space       = "cidrsubnet(${var.dns_vnet_address_space}, 8, 1)"
    gateway_subnet_address_space        = "cidrsubnet(${var.dns_vnet_address_space}, 8, 2)"
    # peering parameters
    peering_vnet_address_space          = "10.1.0.0/16"
    peering_subnet_address_space        = "cidrsubnet(${local.peering_vnet_address_space}, 8, 0)"
    vm_peer_private_ip_address          = "${cidrhost("${local.peering_subnet_address_space}", 4)}"
    # onprem parameters
    onprem_address_space                = "192.168.0.0/24"
    onprem_subnet_address_space         = "cidrsubnet(${local.onprem_address_space}, 4, 0)"
    onprem_gateway_subnet_address_space = "cidrsubnet(${local.onprem_address_space}, 4, 1)"
    vm_onprem_private_ip_address        = "${cidrhost("${local.onprem_subnet_address_space}", 4)}" */
  # PSK
  shared_key = "4-v3ry-53cr37-1p53c-5h4r3d-k3y"
}