# Virtual Networks
resource "azurerm_virtual_network" "vnet_con" {
  for_each            = var.regions
  name                = "vnet-${each.value.location}-con"
  address_space       = [each.value.cidr]
  location            = each.value.location
  resource_group_name = var.resource_group_name
}

# Subnets
resource "azurerm_subnet" "subnet_con" {
  for_each             = var.regions
  name                 = "subnet-${each.value.location}-01"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet_con[each.key].name
  address_prefixes     = [cidrsubnet("${each.value.cidr}", 8, 0)]
  service_endpoints    = ["Microsoft.Storage.Global"]
}

resource "azurerm_subnet" "subnet_bastion" {
  for_each             = var.regions
  name                 = "AzureBastionSubnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet_con[each.key].name
  address_prefixes     = [cidrsubnet("${each.value.cidr}", 8, 1)]
}

resource "azurerm_subnet" "subnet_private_endpoint" {
  for_each             = var.regions
  name                 = "subnet-pe-${each.value.location}"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet_con[each.key].name
  address_prefixes     = [cidrsubnet("${each.value.cidr}", 8, 2)]
}


# Network Security Groups
resource "azurerm_network_security_group" "nsg" {
  for_each            = var.regions
  name                = "nsg-${each.value.location}-01"
  location            = each.value.location
  resource_group_name = var.resource_group_name

  # Inbound Rule
  security_rule {
    name                       = "AllowInternetInbound"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  # Outbound Rule
  security_rule {
    name                       = "AllowHttpsObound"
    priority                   = 100
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

}

# Network Security Group Associations
resource "azurerm_subnet_network_security_group_association" "nsg_assocation" {
  for_each                  = var.regions
  subnet_id                 = azurerm_subnet.subnet_con[each.key].id
  network_security_group_id = azurerm_network_security_group.nsg[each.key].id
}