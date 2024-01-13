# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

output "subnet_id" {
  value = azurerm_subnet.subnet.id
}

output "member_subnet_id" {
  value = azurerm_subnet.member.id
}