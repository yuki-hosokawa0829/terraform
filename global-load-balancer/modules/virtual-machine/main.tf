# NICs
resource "azurerm_network_interface" "nics" {
  for_each            = var.regions
  name                = "nic-${each.value.location}-vm"
  resource_group_name = var.resource_group_name
  location            = each.value.location

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.subnet_con_id[index(local.region_key, each.key)]
    private_ip_address_allocation = "Static"
    private_ip_address            = cidrhost(cidrsubnet("${each.value.cidr}", 2, 0), 4)
  }
}

# Virtual Machines
resource "azurerm_windows_virtual_machine" "vms" {
  for_each                 = var.regions
  name                     = "vm-${each.value.location}"
  resource_group_name      = var.resource_group_name
  location                 = each.value.location
  size                     = "Standard_B4ms"
  admin_username           = var.local_admin_username
  admin_password           = var.local_admin_password
  enable_automatic_updates = "true"

  network_interface_ids = [
    azurerm_network_interface.nics[each.key].id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "StandardSSD_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-Datacenter"
    version   = "latest"
  }

  identity {
    type = "SystemAssigned"
  }

}

# Setup script to install IIS
resource "azurerm_virtual_machine_extension" "vmsetup" {
  for_each             = var.regions
  name                 = "cse-${each.value.location}-01"
  virtual_machine_id   = azurerm_windows_virtual_machine.vms[each.key].id
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.9"

  /* protected_settings = <<SETTINGS
    {
    "commandToExecute": "powershell.exe -ExecutionPolicy Unrestricted -File \"${azurerm_storage_blob.ps_script[each.key].name}\"",
    }

  SETTINGS */

  settings = <<SETTINGS
    {
    "commandToExecute": "powershell -command \"[System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String('${base64encode(data.template_file.webserver_vmsetup.rendered)}')) | Out-File -filepath webserver_vmsetup.ps1\" && powershell -ExecutionPolicy Unrestricted -File webserver_vmsetup.ps1"
    }
  SETTINGS

  /*  depends_on = [
    azurerm_role_assignment.dev-role-vm
  ] */

}

# Script to set as WebServer
data "template_file" "webserver_vmsetup" {
  template = file("${path.module}/files/webserver_vmsetup.ps1")
}

/* # Role for VM to Access to Storage Account
resource "azurerm_role_assignment" "dev-role-vm" {
  for_each             = var.regions
  scope                = azurerm_storage_account.storage[each.key].id
  role_definition_name = "Storage Blob Data Reader"
  principal_id         = azurerm_windows_virtual_machine.vms[each.key].identity.0.principal_id
}


# Storage for PowerShell Script
resource "azurerm_storage_account" "storage" {
  for_each                 = var.regions
  name                     = "${var.prefix}${random_string.random.result}${each.value.location}"
  resource_group_name      = var.resource_group_name
  location                 = each.value.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "container" {
  for_each              = var.regions
  name                  = "container01"
  storage_account_name  = azurerm_storage_account.storage[each.key].name
  container_access_type = "private"
}

resource "azurerm_storage_blob" "ps_script" {
  for_each               = var.regions
  name                   = "webserver_vmsetup.ps1"
  storage_account_name   = azurerm_storage_account.storage[each.key].name
  storage_container_name = azurerm_storage_container.container[each.key].name
  type                   = "Block"
  source_content         = file("./modules/virtual-machine/files/webserver_vmsetup.ps1")
}

resource "azurerm_storage_account_network_rules" "rule01" {
  for_each                   = var.regions
  storage_account_id         = azurerm_storage_account.storage[each.key].id
  ip_rules                   = ["219.166.164.110"]
  default_action             = "Deny"
  virtual_network_subnet_ids = [var.subnet_con_id[index(local.region_key, each.key)]]
  bypass                     = ["AzureServices"]
}

resource "random_string" "random" {
  length  = 10
  lower   = true
  upper   = false
  special = false
  numeric = false
} 


# Private Endpoint
resource "azurerm_private_endpoint" "private_endpoint" {
  for_each            = var.regions
  name                = "endpoint-${each.value.location}"
  location            = each.value.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.subnet_private_endpoint_id[index(local.region_key, each.key)]

  private_service_connection {
    name                           = "privateserviceconnection"
    private_connection_resource_id = azurerm_storage_account.storage[each.key].id
    subresource_names              = ["blob"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "dns-zone-group"
    private_dns_zone_ids = [azurerm_private_dns_zone.storage_dns_zone[each.key].id]
  }
}

resource "azurerm_private_dns_zone" "storage_dns_zone" {
  for_each            = var.regions
  name                = "privatelink-${each.value.location}.blob.core.windows.net"
  resource_group_name = var.resource_group_name
}

# add dns A record for private endpoint
resource "azurerm_private_dns_a_record" "dns_a_record" {
  for_each            = var.regions
  name                = azurerm_storage_account.storage[each.key].name
  zone_name           = azurerm_private_dns_zone.storage_dns_zone[each.key].name
  resource_group_name = var.resource_group_name
  ttl                 = 10
  records             = [azurerm_private_endpoint.private_endpoint[each.key].private_service_connection[0].private_ip_address]
}

resource "azurerm_private_dns_zone_virtual_network_link" "link01" {
  for_each              = var.regions
  name                  = "link01-${each.value.location}"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.storage_dns_zone[each.key].name
  virtual_network_id    = var.vnet_con_id[index(local.region_key, each.key)]
} */