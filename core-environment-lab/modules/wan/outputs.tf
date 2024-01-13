output "virtual_hub_id" {
  value = [for virtual_wan_hub in azurerm_virtual_hub.hub1 : virtual_wan_hub.id]
}