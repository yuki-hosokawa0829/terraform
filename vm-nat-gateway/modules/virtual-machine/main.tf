#vm associated with nat gateway
resource "azurerm_network_interface" "vm_nat_nic" {
  count               = local.vm_count
  name                = "${var.prefix}-nic-${count.index}"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "primary"
    subnet_id                     = var.nat_subnet_id
    private_ip_address_allocation = "Dynamic"
  }

}

resource "azurerm_windows_virtual_machine" "vm_nat" {
  count                    = local.vm_count
  name                     = "${var.prefix}-vm-${count.index}"
  resource_group_name      = var.resource_group_name
  location                 = var.location
  size                     = "Standard_B2ms"
  admin_username           = var.local_admin_username
  admin_password           = var.local_admin_password
  provision_vm_agent       = true
  enable_automatic_updates = true

  network_interface_ids = [
    azurerm_network_interface.vm_nat_nic[count.index].id,
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

}

#vm with default public ip address
resource "azurerm_public_ip" "static" {
  name                = "${var.prefix}-admin-pip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_network_interface" "vm_admin_nic" {
  name                = "${var.prefix}-admin-nic"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "primary"
    subnet_id                     = var.admin_subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.static.id
  }
}

resource "azurerm_windows_virtual_machine" "vm_admin" {
  name                     = "${var.prefix}-vm-admin"
  resource_group_name      = var.resource_group_name
  location                 = var.location
  size                     = "Standard_B2ms"
  admin_username           = var.local_admin_username
  admin_password           = var.local_admin_password
  provision_vm_agent       = true
  enable_automatic_updates = true

  network_interface_ids = [
    azurerm_network_interface.vm_admin_nic.id,
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

}