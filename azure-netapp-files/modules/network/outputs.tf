# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

output "domain_controllers_subnet_id" {
  value = azurerm_subnet.dc_subnet.id
}

output "anf_subnet_id" {
  value = azurerm_subnet.anf_subnet.id
}