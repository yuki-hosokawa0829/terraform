# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

output "domain_controllers_subnet_id" {
  value = azurerm_subnet.domain_controllers.id
}

output "sessionhost_subnet_id" {
  value = azurerm_subnet.sessionhost.id
}