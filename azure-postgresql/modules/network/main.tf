resource "azurerm_virtual_network" "example" {
  name                = "vn-${var.prefix}"
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = [var.network_range]
}

resource "azurerm_subnet" "postgressubnet" {
  name                 = "subnet-postgres"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = [cidrsubnet(var.network_range, var.number_of_subnets, 0)]
  service_endpoints    = ["Microsoft.Storage"]

  delegation {
    name = "fs"

    service_delegation {
      name = "Microsoft.DBforPostgreSQL/flexibleServers"

      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action",
      ]
    }
  }
}

resource "azurerm_subnet" "vmsubnet" {
  name                 = "subnet-vm"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = [cidrsubnet(var.network_range, var.number_of_subnets, 1)]
}

resource "azurerm_private_dns_zone" "example" {
  name                = "${var.prefix}-pdz.postgres.database.azure.com"
  resource_group_name = var.resource_group_name
}

resource "azurerm_private_dns_zone_virtual_network_link" "example" {
  name                  = "${var.prefix}-pdzvnetlink.com"
  private_dns_zone_name = azurerm_private_dns_zone.example.name
  virtual_network_id    = azurerm_virtual_network.example.id
  resource_group_name   = var.resource_group_name
}

resource "azurerm_network_security_group" "example" {
  name                = "nsg-${var.prefix}"
  location            = var.location
  resource_group_name = var.resource_group_name

  security_rule {
    name                       = "AllowSSHInbound"
    priority                   = 1000
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

}

resource "azurerm_subnet_network_security_group_association" "example" {
  subnet_id                 = azurerm_subnet.vmsubnet.id
  network_security_group_id = azurerm_network_security_group.example.id
}