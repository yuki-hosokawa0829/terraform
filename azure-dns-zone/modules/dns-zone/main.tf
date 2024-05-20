# This Terraform configuration creates a DNS zone and a subdomain in Azure DNS.
#
# The configuration uses the azurerm_dns_zone resource to create a DNS zone and the azurerm_dns_ns_record resource to create a subdomain.
resource "azurerm_dns_zone" "sub_mydomain" {
  name                = "${var.subdomain_name}.${var.domain_name}"
  resource_group_name = var.resource_group_name
}

resource "azurerm_dns_txt_record" "example" {
  name                = var.host_name
  zone_name           = azurerm_dns_zone.sub_mydomain.name
  resource_group_name = var.resource_group_name
  ttl                 = var.ttl

  record {
    value = var.text_record
  }
}

resource "azurerm_dns_a_record" "a_record" {
  name                = "hogehoge"
  zone_name           = azurerm_dns_zone.sub_mydomain.name
  resource_group_name = var.resource_group_name
  ttl                 = 3600

  records = ["1.1.1.1"]
}