# Virtual WAN
resource "azurerm_virtual_wan" "vwan1" {
  name                = "${var.prefix}-vWAN-01"
  resource_group_name = var.resource_group_name
  location            = var.location01
}

# Virtual WAN Hubs
resource "azurerm_virtual_hub" "location01_vhub1" {
  name                = "${var.prefix}-vWAN-hub-01"
  resource_group_name = var.resource_group_name
  location            = var.location01
  virtual_wan_id      = azurerm_virtual_wan.vwan1.id
  address_prefix      = var.vhub_location01_address_range

}
resource "azurerm_virtual_hub" "location02_vhub1" {
  name                = "${var.prefix}-vWAN-hub-02"
  resource_group_name = var.resource_group_name
  location            = var.location02
  virtual_wan_id      = azurerm_virtual_wan.vwan1.id
  address_prefix      = var.vhub_location02_address_range
}

#VPN Gateway
resource "azurerm_vpn_gateway" "location02_gateway1" {
  name                = "${var.prefix}-vpngw-01"
  location            = var.location02
  resource_group_name = var.resource_group_name
  virtual_hub_id      = azurerm_virtual_hub.location02_vhub1.id
}

#VPN Site
resource "azurerm_vpn_site" "location02_officesite1" {
  name                = "${var.prefix}-officesite1"
  location            = var.location02
  resource_group_name = var.resource_group_name
  virtual_wan_id      = azurerm_virtual_wan.vwan1.id
  address_cidrs       = ["${var.network_onprem_address_range}"] # Address range of the on-premises network

  link {
    name       = "Office-Link-1"
    ip_address = var.vpngw_pip
  }

}

#Connection between VPN Gateway in vHUB and Azure Virtual WAN Site
resource "azurerm_vpn_gateway_connection" "region1-officesite1" {
  name               = "${var.prefix}-officesite1-connection"
  vpn_gateway_id     = azurerm_vpn_gateway.location02_gateway1.id
  remote_vpn_site_id = azurerm_vpn_site.location02_officesite1.id

  vpn_link {
    name             = "link1"
    vpn_site_link_id = azurerm_vpn_site.location02_officesite1.link.0.id
  }

}


#Firewall Policy
resource "azurerm_firewall_policy" "fw-pol01" {
  name                = "fw-pol01"
  resource_group_name = var.resource_group_name
  location            = var.location01
}

# Add Firewall Routing Intent
resource "azurerm_virtual_hub_routing_intent" "location01-routing-intent" {
  name           = "location01-routing-intent"
  virtual_hub_id = azurerm_virtual_hub.location01_vhub1.id

  routing_policy {
    name         = "InternetTrafficPolicy"
    destinations = ["Internet"]
    next_hop     = azurerm_firewall.location01-fw01.id
  }

  /* routing_policy {
    name         = "PrivateTrafficPolicy"
    destinations = ["PrivateTraffic"]
    next_hop     = azurerm_firewall.location01-fw01.id
  } */

}

# Firewall Policy Rules
resource "azurerm_firewall_policy_rule_collection_group" "location01-policy1" {
  name               = "fw-pol01-rules"
  firewall_policy_id = azurerm_firewall_policy.fw-pol01.id
  priority           = 100

  nat_rule_collection {
    name     = "nat_rules1"
    priority = 990
    action   = "Dnat"

    rule {
      name                = "location01-nat1-rule1"
      protocols           = ["TCP"]
      source_addresses    = ["219.166.164.110"]
      destination_address = azurerm_firewall.location01-fw01.virtual_hub.0.public_ip_addresses.0
      destination_ports   = ["3389"]
      translated_address  = var.dc_jw_private_address
      translated_port     = 3389
    }

  }

  network_rule_collection {
    name     = "deny_https_rule_collection"
    priority = 1000
    action   = "Deny"

    rule {
      name                  = "deny_https_rule"
      protocols             = ["TCP"]
      source_addresses      = ["*"]
      destination_addresses = ["8.8.8.8"]
      destination_ports     = ["*"]
    }

  }

  network_rule_collection {
    name     = "allow_network_rules1"
    priority = 1050
    action   = "Allow"

    rule {
      name                  = "allow_https_rule"
      protocols             = ["TCP"]
      source_addresses      = ["*"]
      destination_addresses = ["*"]
      destination_ports     = ["443"]
    }

    rule {
      name                  = "allow_http_rule"
      protocols             = ["TCP"]
      source_addresses      = ["*"]
      destination_addresses = ["*"]
      destination_ports     = ["80"]
    }

    rule {
      name                  = "allow_dns_rule"
      protocols             = ["UDP"]
      source_addresses      = ["*"]
      destination_addresses = ["*"]
      destination_ports     = ["53"]
    }

    rule {
      name                  = "allow_ntp_rule"
      protocols             = ["UDP"]
      source_addresses      = ["*"]
      destination_addresses = ["*"]
      destination_ports     = ["123"]
    }

    rule {
      name                  = "allow_kms_rule"
      protocols             = ["UDP"]
      source_addresses      = ["*"]
      destination_addresses = ["*"]
      destination_ports     = ["1688"]
    }

    rule {
      name                  = "allow_aims_rule"
      protocols             = ["Any"]
      source_addresses      = ["*"]
      destination_addresses = ["169.254.169.254"]
      destination_ports     = ["*"]
    }

  }

  network_rule_collection {
    name     = "deny_network_rules1"
    priority = 1100
    action   = "Deny"

    rule {
      name                  = "network_rule_collection1_rule1"
      protocols             = ["TCP", "UDP", "ICMP"]
      source_addresses      = ["*"]
      destination_addresses = ["*"]
      destination_ports     = ["*"]
    }

  }

}

# Firewalls 
resource "azurerm_firewall" "location01-fw01" {
  name                = "${var.prefix}-fw01"
  location            = var.location01
  resource_group_name = var.resource_group_name
  sku_tier            = "Standard"
  sku_name            = "AZFW_Hub"
  firewall_policy_id  = azurerm_firewall_policy.fw-pol01.id

  virtual_hub {
    virtual_hub_id  = azurerm_virtual_hub.location01_vhub1.id
    public_ip_count = 1
  }

}