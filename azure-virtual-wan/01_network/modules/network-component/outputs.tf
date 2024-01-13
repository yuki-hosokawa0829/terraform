# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

output "network_jw_id" {
  value = azurerm_virtual_network.network_jw.id
}

output "network_je_id" {
  value = azurerm_virtual_network.network_je.id
}

output "subnet_domain_controllers_jw_id" {
  value = azurerm_subnet.domain_controllers_jw.id
}

output "subnet_domain_controllers_je_id" {
  value = azurerm_subnet.domain_controllers_je.id
}

output "subnet_domain_controllers_onprem_id" {
  value = azurerm_subnet.domain_controllers_onprem.id
}

output "vpngw_pip" {
  value = azurerm_public_ip.gateway_pip.ip_address
}