variable "resource_group_name" {
  description = "The name of the resource group in which to create the resources."
}

variable "location" {
  description = "The location of the resources."
}

# vnet_peer parameter
variable "vnet_route_server_subnet_id" {
  description = "The ID of the subnet to which the route server will be attached."
}

variable "vnet_peer_as_number" {
  description = "The neighbor AS number for the route server."
}

variable "peer_vpg_ip01" {
  description = "The IP address of the neighbor ip."
}

variable "peer_vpg_ip02" {
  description = "The IP address of the neighbor ip."
}

# vnet_vpn parameter
variable "vnet_as_number" {
  description = "The neighbor AS number for the route server."
}

variable "vnet_vpg_ip01" {
  description = "The IP address of the neighbor ip."
}

variable "vnet_vpg_ip02" {
  description = "The IP address of the neighbor ip."
}