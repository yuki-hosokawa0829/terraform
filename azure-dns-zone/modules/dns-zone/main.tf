# This Terraform configuration creates a DNS zone and a subdomain in Azure DNS.
#
# The configuration uses the azurerm_dns_zone resource to create a DNS zone and the azurerm_dns_ns_record resource to create a subdomain.
#
# The configuration also uses the azurerm_dns_a_record resource to create an A record in the subdomain.

resource "azurerm_dns_zone" "mydomain" {
  name                = var.domain_name
  resource_group_name = var.resource_group_name
}

resource "azurerm_dns_zone" "sub_mydomain" {
  name                = "${var.subdomain_name}.${var.domain_name}"
  resource_group_name = var.resource_group_name

  depends_on = [azurerm_dns_zone.mydomain]
}

resource "azurerm_dns_ns_record" "example" {
  name                = var.subdomain_name
  zone_name           = azurerm_dns_zone.mydomain.name
  resource_group_name = var.resource_group_name
  ttl                 = 3600

  records = azurerm_dns_zone.sub_mydomain.name_servers

}

resource "azurerm_dns_a_record" "example" {
  name                = "test"
  zone_name           = azurerm_dns_zone.sub_mydomain.name
  resource_group_name = var.resource_group_name
  ttl                 = 300
  records             = ["10.0.180.17"]
}

