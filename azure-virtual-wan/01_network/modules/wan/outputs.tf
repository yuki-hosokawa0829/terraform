output "instance_0_pip" {
  value = tolist(azurerm_vpn_gateway.location02_gateway1.bgp_settings.0.instance_0_bgp_peering_address.0.tunnel_ips).1
}

output "instance_1_pip" {
  value = tolist(azurerm_vpn_gateway.location02_gateway1.bgp_settings.0.instance_1_bgp_peering_address.0.tunnel_ips).1
}