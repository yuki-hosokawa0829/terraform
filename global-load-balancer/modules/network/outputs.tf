output "vnet_con_id" {
  value = [for vnet in azurerm_virtual_network.vnet_con : vnet.id]
}

output "subnet_con_id" {
  value = [for subnet in azurerm_subnet.subnet_con : subnet.id]
}

output "subnet_bastion_id" {
  value = [for subnet in azurerm_subnet.subnet_bastion : subnet.id]
}

output "subnet_private_endpoint_id" {
  value = [for subnet in azurerm_subnet.subnet_private_endpoint : subnet.id]
}