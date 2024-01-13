################# Create machine #################
# Create a public IP address for each virtual machine
resource "azurerm_public_ip" "public_ip" {
  count               = length(var.subnet_id)
  name                = "vm-ip-0${count.index}"
  resource_group_name = var.resource_group_name
  location            = var.location
  allocation_method   = "Dynamic"
}

# Create a network interface for each virtual machine
resource "azurerm_network_interface" "nic" {
  count               = length(var.subnet_id)
  name                = "vm-nic-0${count.index}"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "vm-ipconf-0${count.index}"
    subnet_id                     = var.subnet_id[count.index]
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.public_ip[count.index].id
  }

}

# Create a virtual machine for each virtual network
resource "azurerm_windows_virtual_machine" "vm" {
  count               = length(var.subnet_id)
  name                = "vm-0${count.index}"
  resource_group_name = var.resource_group_name
  location            = var.location
  size                = "Standard_B2ms"
  admin_username      = var.admin_username
  admin_password      = var.admin_password

  network_interface_ids = [
    azurerm_network_interface.nic[count.index].id,
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

################# Create onprem machine #################
# Create a public IP address for each virtual machine
resource "azurerm_public_ip" "onprem_public_ip" {
  count               = length(var.subnet_onprem_id)
  name                = "onprem-vm-ip-0${count.index}"
  resource_group_name = var.resource_group_name
  location            = var.location
  allocation_method   = "Dynamic"
}

# Create a network interface for each virtual machine
resource "azurerm_network_interface" "onprem_nic" {
  count               = length(var.subnet_onprem_id)
  name                = "onprem-vm-nic-0${count.index}"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "onprem-vm-ipconf-0${count.index}"
    subnet_id                     = var.subnet_onprem_id[count.index]
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.onprem_public_ip[count.index].id
  }

}

# Create a virtual machine for each virtual network
resource "azurerm_windows_virtual_machine" "onprem_vm" {
  count               = length(var.subnet_onprem_id)
  name                = "vm-onprem-0${count.index}"
  resource_group_name = var.resource_group_name
  location            = var.location
  size                = "Standard_B2ms"
  admin_username      = var.admin_username
  admin_password      = var.admin_password

  network_interface_ids = [
    azurerm_network_interface.onprem_nic[count.index].id,
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