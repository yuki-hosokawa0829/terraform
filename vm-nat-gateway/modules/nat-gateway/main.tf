#NAT Gateway
resource "azurerm_public_ip" "nat_pip" {
  name                = "${var.prefix}-pip-natgw"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_nat_gateway" "nat_gw" {
  name                = "${var.prefix}-natgw"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku_name            = "Standard"
}

resource "azurerm_nat_gateway_public_ip_association" "example" {
  nat_gateway_id       = azurerm_nat_gateway.nat_gw.id
  public_ip_address_id = azurerm_public_ip.nat_pip.id
}

resource "azurerm_subnet_nat_gateway_association" "nat-assoc1" {
  subnet_id      = var.nat_subnet_id
  nat_gateway_id = azurerm_nat_gateway.nat_gw.id
}