# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

#VM in mesh network
resource "azurerm_public_ip" "static01" {
  count               = length(var.subnet_id01)
  name                = "${var.prefix}-pip${count.index}"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_network_interface" "nic01" {
  count               = length(var.subnet_id01)
  name                = join("-", [var.prefix, "primary${count.index}"])
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "primary"
    subnet_id                     = var.subnet_id01[count.index]
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.static01[count.index].id
  }

}

resource "azurerm_windows_virtual_machine" "vm" {
  count               = length(var.subnet_id01)
  name                = "${var.prefix}-vm${count.index}"
  resource_group_name = var.resource_group_name
  location            = var.location
  size                = "Standard_B2ms"
  admin_username      = var.admin_username
  admin_password      = var.admin_password

  network_interface_ids = [
    azurerm_network_interface.nic01[count.index].id,
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

#VM in hub-and-spoke network
resource "azurerm_public_ip" "static02" {
  count               = length(var.subnet_id02)
  name                = "${var.prefix}-hs-pip${count.index}"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_network_interface" "nic02" {
  count               = length(var.subnet_id02)
  name                = join("-", [var.prefix, "hs-primary${count.index}"])
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "primary"
    subnet_id                     = var.subnet_id02[count.index]
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.static02[count.index].id
  }

}

resource "azurerm_windows_virtual_machine" "vm02" {
  count               = length(var.subnet_id02)
  name                = "${var.prefix}-hs-vm${count.index}"
  resource_group_name = var.resource_group_name
  location            = var.location
  size                = "Standard_B2ms"
  admin_username      = var.admin_username
  admin_password      = var.admin_password

  network_interface_ids = [
    azurerm_network_interface.nic02[count.index].id,
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

#VM in hub-and-spoke network with VPN Gateway
resource "azurerm_public_ip" "static03" {
  count               = length(var.subnet_id03)
  name                = "${var.prefix}-gw-pip${count.index}"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_network_interface" "nic03" {
  count               = length(var.subnet_id03)
  name                = join("-", [var.prefix, "gw-primary${count.index}"])
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "primary"
    subnet_id                     = var.subnet_id03[count.index]
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.static03[count.index].id
  }

}

resource "azurerm_windows_virtual_machine" "vm03" {
  count               = length(var.subnet_id03)
  name                = "${var.prefix}-gw-vm${count.index}"
  resource_group_name = var.resource_group_name
  location            = var.location
  size                = "Standard_B2ms"
  admin_username      = var.admin_username
  admin_password      = var.admin_password

  network_interface_ids = [
    azurerm_network_interface.nic03[count.index].id,
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