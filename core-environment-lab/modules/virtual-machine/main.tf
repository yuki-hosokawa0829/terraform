# Identity Resources
resource "azurerm_availability_set" "ide_as" {
  for_each                    = var.regions
  name                        = "as-${each.value.code}-ide"
  location                    = each.value.location
  resource_group_name         = var.resource_group_name
  platform_fault_domain_count = 2
}


# NICs
resource "azurerm_network_interface" "idenic1" {
  for_each            = var.regions
  name                = "nic-${each.value.code}-ide-1"
  location            = each.value.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "ipconfig-ide-${each.value.code}"
    subnet_id                     = var.identity1_subnet_id[index(local.regions_key, each.key)]
    private_ip_address_allocation = "Dynamic"
  }

}

resource "azurerm_network_interface" "idenic2" {
  for_each            = var.regions
  name                = "nic-${each.value.code}-ide-2"
  location            = each.value.location
  resource_group_name = var.resource_group_name
  ip_configuration {
    name                          = "ipconfig-ide-${each.value.code}"
    subnet_id                     = var.identity2_subnet_id[index(local.regions_key, each.key)]
    private_ip_address_allocation = "Dynamic"
  }

}


# Virtual Machines
resource "azurerm_windows_virtual_machine" "idevm1" {
  for_each            = var.regions
  name                = "vm-${each.value.code}-ide-01"
  location            = each.value.location
  resource_group_name = var.resource_group_name
  size                = var.vmsize
  admin_username      = var.local_admin_username
  admin_password      = var.vmpassword
  availability_set_id = azurerm_availability_set.ide_as[each.key].id

  network_interface_ids = [
    azurerm_network_interface.idenic1[each.key].id,
  ]

  os_disk {
    name                 = "disk-${each.value.code}-ide-01"
    caching              = "ReadWrite"
    storage_account_type = "StandardSSD_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-Datacenter"
    version   = "latest"
  }

}

resource "azurerm_windows_virtual_machine" "idevm2" {
  for_each            = var.regions
  name                = "vm-${each.value.code}-ide-02"
  location            = each.value.location
  resource_group_name = var.resource_group_name
  size                = var.vmsize
  admin_username      = var.local_admin_username
  admin_password      = var.vmpassword
  availability_set_id = azurerm_availability_set.ide_as[each.key].id

  network_interface_ids = [
    azurerm_network_interface.idenic2[each.key].id,
  ]

  os_disk {
    name                 = "disk-${each.value.code}-ide-02"
    caching              = "ReadWrite"
    storage_account_type = "StandardSSD_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-Datacenter"
    version   = "latest"
  }

}