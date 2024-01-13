# Virtual WAN
resource "azurerm_virtual_wan" "virtual_wan1" {
  name                = "vwan-${var.regions.region1.code}-01"
  resource_group_name = var.resource_group_name
  location            = var.regions.region1.location
  # Configuration 
  office365_local_breakout_category = "OptimizeAndAllow"
}

# Virtual WAN Hubs
resource "azurerm_virtual_hub" "hub1" {
  for_each            = var.regions
  name                = "hub-${each.value.code}-01"
  resource_group_name = var.resource_group_name
  location            = each.value.location
  virtual_wan_id      = azurerm_virtual_wan.virtual_wan1.id
  address_prefix      = cidrsubnet("${each.value.cidr}", 2, 0)
  sku                 = "Standard"
}

# VPN Gateways
resource "azurerm_vpn_gateway" "vpngw" {
  for_each            = var.regions
  name                = "gw-${each.value.code}-01"
  resource_group_name = var.resource_group_name
  location            = each.value.location
  virtual_hub_id      = azurerm_virtual_hub.hub1[each.key].id
}

/* # P2S Config
resource "azurerm_vpn_server_configuration" "p2svpn1" {
  name                     = "vpnconf-${var.regions.region1.location}-p2s-01"
  resource_group_name      = var.resource_group_name
  location                 = var.regions.region1.location
  vpn_authentication_types = ["AAD"]
  depends_on               = [azurerm_firewall.firewall1]
  azure_active_directory_authentication {
    audience = var.vpn_app_id
    tenant   = "https://login.microsoftonline.com/${var.usr_tenant_id}"
    issuer   = "https://sts.windows.net/${var.usr_tenant_id}/"
  }
}

# P2S Gateway
resource "azurerm_point_to_site_vpn_gateway" "p2svpngw" {
  for_each                    = var.regions
  name                        = "gw-${each.value.code}-p2s-01"
  resource_group_name         = var.resource_group_name
  location                    = each.value.location
  virtual_hub_id              = azurerm_virtual_hub.hub1[each.key].id
  vpn_server_configuration_id = azurerm_vpn_server_configuration.p2svpn1.id
  scale_unit                  = 1
  depends_on                  = [azurerm_firewall.firewall1]
  connection_configuration {
    name = "conn-${each.value.code}-p2s-01"
    vpn_client_address_pool {
      address_prefixes = [
        cidrsubnet("${each.value.cidr}", 5, 30),
      ]
    }
  }
} */