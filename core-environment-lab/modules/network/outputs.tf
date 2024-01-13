# ID for Subnet of Azure Bastion
output "management1_subnet_id" {
  value = [for management1_subnet in azurerm_subnet.management1 : management1_subnet.id]
}

output "management2_subnet_id" {
  value = [for management2_subnet in azurerm_subnet.management2 : management2_subnet.id]
}

output "identity1_subnet_id" {
  value = [for identity1_subnet in azurerm_subnet.identity1 : identity1_subnet.id]
}

output "identity2_subnet_id" {
  value = [for identity2_subnet in azurerm_subnet.identity2 : identity2_subnet.id]
}

output "avd1_subnet_id" {
  value = [for avd1_subnet in azurerm_subnet.avd1 : avd1_subnet.id]
}

output "avd2_subnet_id" {
  value = [for avd2_subnet in azurerm_subnet.avd2 : avd2_subnet.id]
}

output "avd3_subnet_id" {
  value = [for avd3_subnet in azurerm_subnet.avd3 : avd3_subnet.id]
}

output "avd4_subnet_id" {
  value = [for avd4_subnet in azurerm_subnet.avd4 : avd4_subnet.id]
}