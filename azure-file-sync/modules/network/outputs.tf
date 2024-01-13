# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

output "file_server_subnet_id" {
  value = azurerm_subnet.file_server_subnet.id
}

output "file_server_onprem_subnet_id" {
  value = azurerm_subnet.file_server_subnet_onprem.id
}

output "domain_contoller_subnet_id" {
  value = azurerm_subnet.domain_controller_subnet.id
}