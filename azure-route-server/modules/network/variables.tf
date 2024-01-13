variable "resource_group_name" {
  description = "The name of the resource group"
}

variable "location" {
  description = "The Azure Region in which most of all resources in this example should be created."
}

# vnet parameter
variable "vnet_address_range" {
  description = "The address range of the virtual network"
}

variable "vnet_subnet_address_range" {
  description = "The address range of the virtual network subnet"
}

variable "vnet_gateway_subnet_address_range" {
  description = "The address range of the virtual network subnet"
}

variable "vnet_route_server_subnet_address_range" {
  description = "The address range of the virtual network subnet"
}

variable "vnet_as_number" {
  description = "The AS number of the virtual network gateway"
}

# vnet peer parameter
variable "vnet_peer_address_range" {
  description = "The address range of the peering virtual network"
}

variable "vnet_peer_subnet_address_range" {
  description = "The address range of the peering virtual network subnet"
}

variable "vnet_peer_gateway_subnet_address_range" {
  description = "The address range of the peering virtual network subnet"
}

variable "vnet_peer_as_number" {
  description = "The AS number of the peering virtual network gateway"
}

# vnet vpn parameter
variable "vnet_vpn_address_range" {
  description = "The address range of the vpn virtual network"
}

variable "vnet_vpn_subnet_address_range" {
  description = "The address range of the vpn virtual network subnet"
}

variable "vnet_vpn_gateway_subnet_address_range" {
  description = "The address range of the vpn virtual network subnet"
}

variable "vnet_vpn_as_number" {
  description = "The AS number of the vpn virtual network gateway"
}

# vnet onprem parameter
variable "vnet_onprem_address_range" {
  description = "The address range of the virtual network onprem"
}

variable "vnet_onprem_subnet_address_range" {
  description = "The address range of the virtual network onprem subnet"
}

variable "vnet_onprem_gateway_subnet_address_range" {
  description = "The address range of the virtual network onprem subnet"
}

variable "vnet_onprem_as_number" {
  description = "The AS number of the onprem virtual network gateway"
}

# vnet onprem02 parameter
variable "vnet_onprem02_address_range" {
  description = "The address range of the virtual network onprem02"
}

variable "vnet_onprem02_subnet_address_range" {
  description = "The address range of the virtual network onprem02 subnet"
}

variable "vnet_onprem02_gateway_subnet_address_range" {
  description = "The address range of the virtual network onprem02 subnet"
}

locals {
  vpn_gateway_conf_name01        = "vnet_gateway_ip_configuration01"
  vpn_gateway_conf_name02        = "vnet_gateway_ip_configuration02"
  vpn_peer_gateway_conf_name01   = "vnet_peer_gateway_ip_configuration01"
  vpn_peer_gateway_conf_name02   = "vnet_peer_gateway_ip_configuration02"
  vpn_onprem_gateway_conf_name01 = "vnet_onprem_gateway_ip_configuration01"
  vpn_onprem_gateway_conf_name02 = "vnet_onprem_gateway_ip_configuration02"
}