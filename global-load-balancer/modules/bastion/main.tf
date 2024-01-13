# Bastion
resource "azurerm_public_ip" "bastion-pip" {
  for_each            = var.regions
  name                = "pip-${each.value.location}-bst-01"
  resource_group_name = var.resource_group_name
  location            = each.value.location
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_bastion_host" "bastion" {
  for_each            = var.regions
  name                = "bst-${each.value.location}-01"
  resource_group_name = var.resource_group_name
  location            = each.value.location

  ip_configuration {
    name                 = "bst-${each.value.location}-01"
    subnet_id            = var.subnet_bastion_id[index(local.region_key, each.key)]
    public_ip_address_id = azurerm_public_ip.bastion-pip[each.key].id
  }

}