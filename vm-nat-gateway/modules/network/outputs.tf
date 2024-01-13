# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

output "nat_subnet_id" {
  value = azurerm_subnet.nat_subnet.id
}

output "admin_subnet_id" {
  value = azurerm_subnet.admin_subnet.id
}