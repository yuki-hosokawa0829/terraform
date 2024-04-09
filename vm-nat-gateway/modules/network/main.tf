#network on cloud
resource "azurerm_virtual_network" "example" {
  name                = join("-", [var.prefix, "network"])
  location            = var.location
  address_space       = ["${var.virtual_network_address_space}"]
  resource_group_name = var.resource_group_name
  dns_servers         = ["168.63.129.16", "8.8.8.8"]
}

resource "azurerm_subnet" "nat_subnet" {
  name                 = local.subnet_name_nat
  address_prefixes     = ["${local.nat_subnet_prefix}"]
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.example.name
}

resource "azurerm_subnet" "admin_subnet" {
  name                 = local.subnet_name_admin
  address_prefixes     = ["${local.admin_subnet_prefix}"]
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.example.name
}


#NSG
resource "azurerm_network_security_group" "nsg_nat" {
  name                = "nsg-fs"
  location            = var.location
  resource_group_name = var.resource_group_name
}

resource "azurerm_network_security_rule" "AllowRDPInbound" {
  name                        = "AllowRDPInbound"
  priority                    = 1000
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "3389"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.nsg_nat.name
}

resource "azurerm_subnet_network_security_group_association" "nsg_as_fs" {
  subnet_id                 = azurerm_subnet.admin_subnet.id
  network_security_group_id = azurerm_network_security_group.nsg_nat.id
}