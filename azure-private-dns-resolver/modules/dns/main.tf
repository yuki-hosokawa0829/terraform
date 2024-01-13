# add azure private dns resolver
resource "azurerm_private_dns_resolver" "dns_resolver" {
  name                = "${var.prefix}-dns-resolver"
  resource_group_name = var.resource_group_name
  location            = var.location
  virtual_network_id  = var.dns_virtual_network_id
}

# add azure private dns resolver inbound endpoint
resource "azurerm_private_dns_resolver_inbound_endpoint" "inbound_endpoint" {
  name                    = "${var.prefix}-inbound-endpoint"
  location                = var.location
  private_dns_resolver_id = azurerm_private_dns_resolver.dns_resolver.id

  ip_configurations {
    private_ip_allocation_method = "Dynamic"
    subnet_id                    = var.inbound_subnet_id
  }
}

# add azure private dns resolver outbound endpoint
resource "azurerm_private_dns_resolver_outbound_endpoint" "outbound_endpoint" {
  name                    = "${var.prefix}-outbound-endpoint"
  location                = var.location
  private_dns_resolver_id = azurerm_private_dns_resolver.dns_resolver.id
  subnet_id               = var.outbound_subnet_id
}

# add azure private dns resolver forwarding ruleset
resource "azurerm_private_dns_resolver_dns_forwarding_ruleset" "ruleset" {
  name                                       = "example-ruleset"
  resource_group_name                        = var.resource_group_name
  location                                   = var.location
  private_dns_resolver_outbound_endpoint_ids = [azurerm_private_dns_resolver_outbound_endpoint.outbound_endpoint.id]
}

# add azure private dns forwading rule
resource "azurerm_private_dns_resolver_forwarding_rule" "rule01" {
  name                      = "example-rule"
  dns_forwarding_ruleset_id = azurerm_private_dns_resolver_dns_forwarding_ruleset.ruleset.id
  domain_name               = "${var.domain_name}."
  enabled                   = true

  target_dns_servers {
    ip_address = var.onprem_dns_ip
    port       = 53
  }
}

# add azure private dns resolver virtual network link to dns virtual network
resource "azurerm_private_dns_resolver_virtual_network_link" "link_to_dns_vnet" {
  name                      = "link-to-dns-vnet"
  dns_forwarding_ruleset_id = azurerm_private_dns_resolver_dns_forwarding_ruleset.ruleset.id
  virtual_network_id        = var.dns_virtual_network_id
}

# add azure private dns resolver virtual network link to peering virtual network
resource "azurerm_private_dns_resolver_virtual_network_link" "link_to_peering_vnet" {
  name                      = "link-to-peering-vnet"
  dns_forwarding_ruleset_id = azurerm_private_dns_resolver_dns_forwarding_ruleset.ruleset.id
  virtual_network_id        = var.peering_virtual_network_id
}