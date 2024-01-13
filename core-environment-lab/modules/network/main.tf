# VNet management
resource "azurerm_virtual_network" "management" {
  for_each            = var.regions
  name                = "vnet-${each.value.code}-man-01"
  resource_group_name = var.resource_group_name
  location            = each.value.location
  address_space       = [cidrsubnet("${each.value.cidr}", 5, 8)]
}

resource "azurerm_subnet" "management1" {
  for_each             = var.regions
  name                 = "AzureBastionSubnet"
  resource_group_name  = var.resource_group_name
  address_prefixes     = [cidrsubnet("${each.value.cidr}", 6, 16)]
  virtual_network_name = azurerm_virtual_network.management[each.key].name
}

resource "azurerm_subnet" "management2" {
  for_each             = var.regions
  name                 = "snet-${each.value.code}-man-01"
  resource_group_name  = var.resource_group_name
  address_prefixes     = [cidrsubnet("${each.value.cidr}", 6, 17)]
  virtual_network_name = azurerm_virtual_network.management[each.key].name
}

resource "azurerm_virtual_hub_connection" "management" {
  for_each                  = var.regions
  name                      = "${each.value.code}-management-to-${each.value.code}-hub"
  virtual_hub_id            = var.virtual_hub_id[index(local.regions_key, each.key)]
  remote_virtual_network_id = azurerm_virtual_network.management[each.key].id
  internet_security_enabled = true
}


# VNet identity
resource "azurerm_virtual_network" "identity" {
  for_each            = var.regions
  name                = "vnet-${each.value.code}-ide-01"
  resource_group_name = var.resource_group_name
  location            = each.value.location
  address_space       = [cidrsubnet("${each.value.cidr}", 5, 9)]
}

resource "azurerm_subnet" "identity1" {
  for_each             = var.regions
  name                 = "snet-${each.value.code}-ide-01"
  resource_group_name  = var.resource_group_name
  address_prefixes     = [cidrsubnet("${each.value.cidr}", 6, 18)]
  virtual_network_name = azurerm_virtual_network.identity[each.key].name
}

resource "azurerm_subnet" "identity2" {
  for_each             = var.regions
  name                 = "snet-${each.value.code}-ide-02"
  resource_group_name  = var.resource_group_name
  address_prefixes     = [cidrsubnet("${each.value.cidr}", 6, 19)]
  virtual_network_name = azurerm_virtual_network.identity[each.key].name
}

resource "azurerm_virtual_hub_connection" "identity" {
  for_each                  = var.regions
  name                      = "${each.value.code}-identity-to-${each.value.code}-hub"
  virtual_hub_id            = var.virtual_hub_id[index(local.regions_key, each.key)]
  remote_virtual_network_id = azurerm_virtual_network.identity[each.key].id
  internet_security_enabled = true
}


#Peering management to identity
resource "azurerm_virtual_network_peering" "management_to_identity" {
  for_each                     = var.regions
  name                         = "${each.value.code}-identity-to-${each.value.code}-management"
  resource_group_name          = var.resource_group_name
  virtual_network_name         = azurerm_virtual_network.identity[each.key].name
  remote_virtual_network_id    = azurerm_virtual_network.management[each.key].id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = false
  use_remote_gateways          = false
  depends_on                   = [azurerm_subnet.identity1, azurerm_subnet.identity2, azurerm_subnet.management1, azurerm_subnet.management2]

}
resource "azurerm_virtual_network_peering" "identity_to_management" {
  for_each                     = var.regions
  name                         = "${each.value.code}-management-to-${each.value.code}-identity"
  resource_group_name          = var.resource_group_name
  virtual_network_name         = azurerm_virtual_network.management[each.key].name
  remote_virtual_network_id    = azurerm_virtual_network.identity[each.key].id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = false
  use_remote_gateways          = false
  depends_on                   = [azurerm_subnet.identity1, azurerm_subnet.identity2, azurerm_subnet.management1, azurerm_subnet.management2]
}


# VNet avd01
resource "azurerm_virtual_network" "avd1" {
  for_each            = var.regions
  name                = "vnet-${each.value.code}-avd-01"
  resource_group_name = var.resource_group_name
  location            = each.value.location
  address_space       = [cidrsubnet("${each.value.cidr}", 5, 10)]
}

resource "azurerm_subnet" "avd1" {
  for_each             = var.regions
  name                 = "snet-${each.value.code}-avd-01"
  resource_group_name  = var.resource_group_name
  address_prefixes     = [cidrsubnet("${each.value.cidr}", 6, 20)]
  virtual_network_name = azurerm_virtual_network.avd1[each.key].name
}

resource "azurerm_subnet" "avd2" {
  for_each             = var.regions
  name                 = "snet-${each.value.code}-avd-02"
  resource_group_name  = var.resource_group_name
  address_prefixes     = [cidrsubnet("${each.value.cidr}", 6, 21)]
  virtual_network_name = azurerm_virtual_network.avd1[each.key].name
}

resource "azurerm_virtual_hub_connection" "avd1" {
  for_each                  = var.regions
  name                      = "${each.value.code}-avd1-to-${each.value.code}-hub"
  virtual_hub_id            = var.virtual_hub_id[index(local.regions_key, each.key)]
  remote_virtual_network_id = azurerm_virtual_network.avd1[each.key].id
  internet_security_enabled = true
}


#VNet avd02
resource "azurerm_virtual_network" "avd2" {
  for_each            = var.regions
  name                = "vnet-${each.value.code}-avd-02"
  resource_group_name = var.resource_group_name
  location            = each.value.location
  address_space       = [cidrsubnet("${each.value.cidr}", 5, 11)]
}

resource "azurerm_subnet" "avd3" {
  for_each             = var.regions
  name                 = "snet-${each.value.code}-avd-03"
  resource_group_name  = var.resource_group_name
  address_prefixes     = [cidrsubnet("${each.value.cidr}", 6, 22)]
  virtual_network_name = azurerm_virtual_network.avd2[each.key].name
}
resource "azurerm_subnet" "avd4" {
  for_each             = var.regions
  name                 = "snet-${each.value.code}-avd-04"
  resource_group_name  = var.resource_group_name
  address_prefixes     = [cidrsubnet("${each.value.cidr}", 6, 23)]
  virtual_network_name = azurerm_virtual_network.avd2[each.key].name
}

resource "azurerm_virtual_hub_connection" "avd2" {
  for_each                  = var.regions
  name                      = "${each.value.code}-avd2-to-${each.value.code}-hub"
  virtual_hub_id            = var.virtual_hub_id[index(local.regions_key, each.key)]
  remote_virtual_network_id = azurerm_virtual_network.avd2[each.key].id
  internet_security_enabled = true
}