# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

#domain contoller
resource "azurerm_public_ip" "static01" {
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
    subnet_id                     = var.subnet_dc_id
    private_ip_address_allocation = "Static"
    private_ip_address            = local.domain_controller_private_ip_address
    public_ip_address_id          = azurerm_public_ip.static01.id
  }
}

resource "azurerm_windows_virtual_machine" "domain_controller" {
  name                = local.virtual_machine_name_dc
  resource_group_name = var.resource_group_name
  location            = var.location
  size                = "Standard_B2ms"
  admin_username      = var.admin_username
  admin_password      = var.admin_password
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

resource "azurerm_virtual_machine_extension" "create-ad-forest" {
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


#file server in cloud
resource "azurerm_public_ip" "static" {
  name                = "${var.prefix}-fs-pip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_network_interface" "primary" {
  name                = "${var.prefix}-fs-nic"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "primary"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.static.id
  }
}

resource "azurerm_windows_virtual_machine" "file_server" {
  name                     = local.virtual_machine_name
  resource_group_name      = var.resource_group_name
  location                 = var.location
  size                     = "Standard_B2ms"
  admin_username           = var.admin_username
  admin_password           = var.admin_password
  provision_vm_agent       = true
  enable_automatic_updates = true

  network_interface_ids = [
    azurerm_network_interface.primary.id,
  ]

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-datacenter-g2"
    version   = "latest"
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  identity {
    type = "SystemAssigned"
  }

}

resource "azurerm_managed_disk" "attached_disk" {
  name                 = "attached-disk"
  resource_group_name  = var.resource_group_name
  location             = var.location
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = "10"
}

resource "azurerm_virtual_machine_data_disk_attachment" "example" {
  managed_disk_id    = azurerm_managed_disk.attached_disk.id
  virtual_machine_id = azurerm_windows_virtual_machine.file_server.id
  lun                = "10"
  caching            = "ReadWrite"
}

resource "azurerm_virtual_machine_extension" "install_storage_sync_agent" {
  name                       = "install-storage-sync-agent"
  virtual_machine_id         = azurerm_windows_virtual_machine.file_server.id
  publisher                  = "Microsoft.Compute"
  type                       = "CustomScriptExtension"
  type_handler_version       = "1.3"
  auto_upgrade_minor_version = true

  protected_settings = <<-SETTINGS
  {
    "fileUris": [
      "${var.storage_blob_url}"
      ],
    "commandToExecute": "powershell.exe -ExecutionPolicy Unrestricted -File \"init_storagesyncagent.ps1\"",
    "managedIdentity" : {}
  }
  SETTINGS

}

resource "azurerm_virtual_machine_extension" "join_domain_fs01" {
  name                 = azurerm_windows_virtual_machine.file_server.name
  publisher            = "Microsoft.Compute"
  type                 = "JsonADDomainExtension"
  type_handler_version = "1.3"
  virtual_machine_id   = azurerm_windows_virtual_machine.file_server.id

  settings = <<SETTINGS
    {
        "Name": "${var.active_directory_domain_name}",
        "OUPath": "",
        "User": "${var.admin_username}@${var.active_directory_domain_name}",
        "Restart": "true",
        "Options": "3"
    }
SETTINGS

  protected_settings = <<SETTINGS
    {
        "Password": "${var.admin_password}"
    }
SETTINGS

  depends_on = [
    azurerm_virtual_machine_extension.create-ad-forest
  ]

}


#file server on premises
resource "azurerm_public_ip" "static_onprem" {
  name                = "${var.prefix}-fs-onprem-pip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_network_interface" "primary_onprem" {
  name                = "${var.prefix}-fs-onprem-nic"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "primary"
    subnet_id                     = var.subnet_onprem_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.static_onprem.id
  }
}

resource "azurerm_windows_virtual_machine" "file_server_onprem" {
  name                     = local.virtual_machine_name_onprem
  resource_group_name      = var.resource_group_name
  location                 = var.location
  size                     = "Standard_B2ms"
  admin_username           = var.admin_username
  admin_password           = var.admin_password
  provision_vm_agent       = true
  enable_automatic_updates = true

  network_interface_ids = [
    azurerm_network_interface.primary_onprem.id,
  ]

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-datacenter-g2"
    version   = "latest"
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  identity {
    type = "SystemAssigned"
  }

}

resource "azurerm_managed_disk" "attached_disk_onprem" {
  name                 = "attached-disk-onprem"
  resource_group_name  = var.resource_group_name
  location             = var.location
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = "10"
}

resource "azurerm_virtual_machine_data_disk_attachment" "attach_disk_onprem" {
  managed_disk_id    = azurerm_managed_disk.attached_disk_onprem.id
  virtual_machine_id = azurerm_windows_virtual_machine.file_server_onprem.id
  lun                = "10"
  caching            = "ReadWrite"
}

resource "azurerm_virtual_machine_extension" "install_storage_sync_agent_onprem" {
  name                       = "dev-vm-extension-onprem"
  virtual_machine_id         = azurerm_windows_virtual_machine.file_server_onprem.id
  publisher                  = "Microsoft.Compute"
  type                       = "CustomScriptExtension"
  type_handler_version       = "1.3"
  auto_upgrade_minor_version = true

  protected_settings = <<-SETTINGS
  {
    "fileUris": [
      "${var.storage_blob_url}"
      ],
    "commandToExecute": "powershell.exe -ExecutionPolicy Unrestricted -File \"init_storagesyncagent.ps1\"",
    "managedIdentity" : {}
  }
  SETTINGS

}

resource "azurerm_virtual_machine_extension" "join_domain_onprem" {
  name                 = azurerm_windows_virtual_machine.file_server_onprem.name
  publisher            = "Microsoft.Compute"
  type                 = "JsonADDomainExtension"
  type_handler_version = "1.3"
  virtual_machine_id   = azurerm_windows_virtual_machine.file_server_onprem.id

  settings = <<SETTINGS
    {
        "Name": "${var.active_directory_domain_name}",
        "OUPath": "",
        "User": "${var.admin_username}@${var.active_directory_domain_name}",
        "Restart": "true",
        "Options": "3"
    }
SETTINGS

  protected_settings = <<SETTINGS
    {
        "Password": "${var.admin_password}"
    }
SETTINGS

  depends_on = [
    azurerm_virtual_machine_extension.create-ad-forest
  ]

}