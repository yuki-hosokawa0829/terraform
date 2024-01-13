# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

# add AD DC server
resource "azurerm_public_ip" "static_dc" {
  name                = "${var.prefix}-dc-pip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_network_interface" "dc_nic" {
  name                = join("-", [var.prefix, "dc-primary"])
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "primary"
    subnet_id                     = var.domain_controllers_subnet_id
    private_ip_address_allocation = "Static"
    private_ip_address            = var.domain_controller_private_ip_address
    public_ip_address_id          = azurerm_public_ip.static_dc.id
  }

}

resource "azurerm_windows_virtual_machine" "domain_controller" {
  name                = local.virtual_machine_name
  resource_group_name = var.resource_group_name
  location            = var.location
  size                = "Standard_B2ms"
  admin_username      = var.domain_user_upn
  admin_password      = var.domain_user_password
  custom_data         = local.custom_data

  network_interface_ids = [
    azurerm_network_interface.dc_nic.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-datacenter-g2"
    version   = "latest"
  }

  additional_unattend_content {
    content = local.auto_logon_data
    setting = "AutoLogon"
  }

  additional_unattend_content {
    content = local.first_logon_data
    setting = "FirstLogonCommands"
  }

}

resource "azurerm_virtual_machine_extension" "create_ad_forest_and_ou" {
  name                 = "create-active-directory-forest"
  virtual_machine_id   = azurerm_windows_virtual_machine.domain_controller.id
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.9"
  settings             = <<SETTINGS
  {
    "commandToExecute": "powershell.exe -Command \"${local.powershell_command}\""
  }
SETTINGS
}


# add AADC server
resource "azurerm_public_ip" "static_aadc" {
  name                = "${var.prefix}-aadc-pip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_network_interface" "aadc_nic" {
  name                = join("-", [var.prefix, "aadc-primary"])
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "primary"
    subnet_id                     = var.domain_controllers_subnet_id
    private_ip_address_allocation = "Static"
    private_ip_address            = var.aadc_server_private_ip_address
    public_ip_address_id          = azurerm_public_ip.static_aadc.id
  }

}

resource "azurerm_windows_virtual_machine" "aadc_server" {
  name                = "vm-aadc"
  resource_group_name = var.resource_group_name
  location            = var.location
  size                = "Standard_B2ms"
  admin_username      = var.domain_user_upn
  admin_password      = var.domain_user_password

  network_interface_ids = [
    azurerm_network_interface.aadc_nic.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-datacenter-g2"
    version   = "latest"
  }

  boot_diagnostics {}
}

resource "azurerm_virtual_machine_extension" "domain_join" {
  name                       = "${azurerm_windows_virtual_machine.aadc_server.name}-domainJoin"
  virtual_machine_id         = azurerm_windows_virtual_machine.aadc_server.id
  publisher                  = "Microsoft.Compute"
  type                       = "JsonADDomainExtension"
  type_handler_version       = "1.3"
  auto_upgrade_minor_version = true

  settings = <<SETTINGS
    {
      "Name": "${var.domain_name}",
      "OUPath":"",
      "User": "${var.domain_user_upn}@${var.domain_name}",
      "Restart": "true",
      "Options": "3"
    }
SETTINGS

  protected_settings = <<PROTECTED_SETTINGS
    {
      "Password": "${var.domain_user_password}"
    }
PROTECTED_SETTINGS

  lifecycle {
    ignore_changes = [settings, protected_settings]
  }

  depends_on = [
    azurerm_virtual_machine_extension.create_ad_forest_and_ou
  ]

}

resource "azurerm_virtual_machine_extension" "install_aadc" {
  name                 = "install_aadc"
  virtual_machine_id   = azurerm_windows_virtual_machine.aadc_server.id
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.9"
  settings             = <<SETTINGS
  {
    "commandToExecute": "${local.aadc_powershell_command}"
  }
SETTINGS
}

// Azure AD Global Admin user account
resource "azuread_user" "aad_admin" {
  user_principal_name = "terraformaadadmin@${var.aad_domain}"
  display_name        = "Terraform AAD Admin"
  password            = "P@ssw0rd0123"
}

resource "azuread_directory_role" "global_admin" {
  display_name = "Global administrator"
}

resource "azuread_directory_role_assignment" "assign_role" {
  role_id             = azuread_directory_role.global_admin.id
  principal_object_id = azuread_user.aad_admin.object_id
}