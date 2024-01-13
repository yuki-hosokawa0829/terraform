# Public IP - Cross Region Load Balancer
# Available in these Regions https://learn.microsoft.com/en-us/azure/load-balancer/cross-region-overview#home-regions 
resource "azurerm_public_ip" "pip_cr_lb" {
  name                = "${var.prefix}-pip-cross-region-lb"
  location            = var.regions.region1.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
  sku_tier            = "Global"
  domain_name_label   = "lb-global-${random_id.dns_name.hex}"
}

# Cross-Region Load Balancer
resource "azurerm_lb" "cross_region_lb" {
  name                = "${var.prefix}-cross-region-lb"
  location            = var.regions.region1.location
  resource_group_name = var.resource_group_name
  sku                 = "Standard"
  sku_tier            = "Global"

  frontend_ip_configuration {
    name                 = "PublicIPAddress"
    public_ip_address_id = azurerm_public_ip.pip_cr_lb.id
  }
}

resource "azurerm_lb_backend_address_pool" "cross_region_lb_pool" {
  loadbalancer_id = azurerm_lb.cross_region_lb.id
  name            = "BackEndAddressPool"
}

resource "azurerm_lb_backend_address_pool_address" "cross_region_lb_pool_address" {
  for_each                            = var.regions
  name                                = "${each.value.location}-regional-lb"
  backend_address_pool_id             = azurerm_lb_backend_address_pool.cross_region_lb_pool.id
  backend_address_ip_configuration_id = azurerm_lb.regional_lb[each.key].frontend_ip_configuration[0].id
}

resource "azurerm_lb_rule" "cross-region_lb_rule" {
  loadbalancer_id                = azurerm_lb.cross_region_lb.id
  name                           = "LBRule"
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = azurerm_lb.cross_region_lb.frontend_ip_configuration[0].name
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.cross_region_lb_pool.id]
}


# Random ID for DNS Label
resource "random_id" "dns_name" {
  byte_length = 4
}

# Public IP - Regional Load Balancer
resource "azurerm_public_ip" "pip_lb" {
  for_each            = var.regions
  name                = "pip-${each.value.location}-lb"
  location            = each.value.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
  domain_name_label   = "lb-${each.value.location}-${random_id.dns_name.hex}"
}

# Regional Load Balancers
resource "azurerm_lb" "regional_lb" {
  for_each            = var.regions
  name                = "regional-lb-${each.value.location}"
  location            = each.value.location
  resource_group_name = var.resource_group_name
  sku                 = "Standard"

  frontend_ip_configuration {
    name                 = "PublicIPAddress"
    public_ip_address_id = azurerm_public_ip.pip_lb[each.key].id
  }
}

resource "azurerm_lb_probe" "regional_lb_probe" {
  for_each        = var.regions
  loadbalancer_id = azurerm_lb.regional_lb[each.key].id
  name            = "probe"
  port            = 80
  protocol        = "Http"
  request_path    = "/"
}

resource "azurerm_lb_backend_address_pool" "regional_lb_pool" {
  for_each        = var.regions
  loadbalancer_id = azurerm_lb.regional_lb[each.key].id
  name            = "BackEndAddressPool"
}

resource "azurerm_lb_rule" "region1_rule" {
  for_each                       = var.regions
  loadbalancer_id                = azurerm_lb.regional_lb[each.key].id
  name                           = "LoadBalancingRule"
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = azurerm_lb.regional_lb[each.key].frontend_ip_configuration[0].name
  probe_id                       = azurerm_lb_probe.regional_lb_probe[each.key].id
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.regional_lb_pool[each.key].id]
}

resource "azurerm_network_interface_backend_address_pool_association" "region1_association" {
  for_each                = var.regions
  network_interface_id    = var.vm_nic_id[index(local.regions_key, each.key)]
  ip_configuration_name   = "internal"
  backend_address_pool_id = azurerm_lb_backend_address_pool.regional_lb_pool[each.key].id
}