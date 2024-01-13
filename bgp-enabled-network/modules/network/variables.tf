variable "location" {
  description = "The Azure Region in which all resources in this example should be created."
}

variable "resource_group_name" {
  description = "The name of the resource group in which to create the virtual network."
}

locals {
  num01          = 2 # the number of network to create
  bgp_asn        = [65510, 65500]
  onprem_bgp_asn = [65000, 65010]
}