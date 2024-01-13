### virtual machine on peer network
# add public ip address
resource "azurerm_public_ip" "vm_peer_public_ip" {
  name                = "${var.prefix}-vm-peer-public-ip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Dynamic"
}

# add network interface
resource "azurerm_network_interface" "peer_nic" {
  name                = "${var.prefix}-peer-nic"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "${var.prefix}-nic-ipconfig"
    subnet_id                     = var.peering_subnet_id
    private_ip_address_allocation = "Static"
    private_ip_address            = var.vm_peer_private_ip_address
    public_ip_address_id          = azurerm_public_ip.vm_peer_public_ip.id
  }
}

# add windows server virtual machine
resource "azurerm_windows_virtual_machine" "vm_peer" {
  name                  = "vm-peer"
  resource_group_name   = var.resource_group_name
  location              = var.location
  size                  = "Standard_DS2_v2"
  admin_username        = "adminuser"
  admin_password        = "Password1234!"
  network_interface_ids = [azurerm_network_interface.peer_nic.id]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }

  provision_vm_agent = true

  boot_diagnostics {
    storage_account_uri = azurerm_storage_account.bootdiag_storage_account.primary_blob_endpoint
  }
}


### virtual machine on prem network
# add public ip address
resource "azurerm_public_ip" "vm_onprem_public_ip" {
  name                = "${var.prefix}-vm-onprem-public-ip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Dynamic"
}

# add network interface
resource "azurerm_network_interface" "onprem_nic" {
  name                = "${var.prefix}-onprem-nic"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "${var.prefix}-nic-ipconfig"
    subnet_id                     = var.onprem_subnet_id
    private_ip_address_allocation = "Static"
    private_ip_address            = var.vm_onprem_private_ip_address
    public_ip_address_id          = azurerm_public_ip.vm_onprem_public_ip.id
  }

}

# add windows server virtual machine onprem
resource "azurerm_windows_virtual_machine" "vm_onprem" {
  name                  = local.virtual_machine_name
  resource_group_name   = var.resource_group_name
  location              = var.location
  size                  = "Standard_DS2_v2"
  admin_username        = var.domain_admin_username
  admin_password        = var.domain_admin_password
  network_interface_ids = [azurerm_network_interface.onprem_nic.id]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }

  provision_vm_agent = true

  boot_diagnostics {
    storage_account_uri = azurerm_storage_account.bootdiag_storage_account.primary_blob_endpoint
  }
}

# add create ad forest extention
resource "azurerm_virtual_machine_extension" "create-ad-forest" {
  name                 = "create-active-directory-forest"
  virtual_machine_id   = azurerm_windows_virtual_machine.vm_onprem.id
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.9"
  settings             = <<SETTINGS
  {
    "commandToExecute": "powershell.exe -Command \"${local.powershell_command_to_create_forest}\""
  }
SETTINGS
}


# add random string for storage account name
resource "random_string" "random" {
  length  = 8
  lower   = true
  upper   = false
  special = false
  numeric = false
}

# add storage account for boot diagnostics
resource "azurerm_storage_account" "bootdiag_storage_account" {
  name                     = "${random_string.random.result}bootdiagstorage"
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}