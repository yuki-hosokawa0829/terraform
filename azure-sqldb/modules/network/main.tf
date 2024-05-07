resource "azurerm_virtual_network" "example" {
  name                = "vn-${var.prefix}"
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = [var.network_range]
}

resource "azurerm_subnet" "example" {
  count                = var.number_of_subnets
  name                 = "subnet-${count.index}"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = [cidrsubnet(var.network_range, var.number_of_subnets, count.index)]
  service_endpoints    = ["Microsoft.Sql"]
}