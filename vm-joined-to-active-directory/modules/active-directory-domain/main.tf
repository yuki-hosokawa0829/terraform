# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

# three WIndows Server 2022 VMs as domain controllers
# first VM is promoted as domain controller
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

  boot_diagnostics {}

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


#member server01 (as domain controller)
resource "azurerm_public_ip" "static01" {
  name                = "${var.prefix}-member01-pip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_network_interface" "member_nic01" {
  name                = "${var.prefix}-member01-nic"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "primary"
    subnet_id                     = var.domain_controllers_subnet_id
    private_ip_address_allocation = "Static"
    private_ip_address            = var.domain_member01_private_ip_address
    public_ip_address_id          = azurerm_public_ip.static01.id
  }

}

resource "azurerm_windows_virtual_machine" "member01" {
  name                     = "${var.prefix}-member01"
  resource_group_name      = var.resource_group_name
  location                 = var.location
  size                     = "Standard_B2ms"
  admin_username           = var.admin_username
  admin_password           = var.admin_password
  provision_vm_agent       = true
  enable_automatic_updates = true

  network_interface_ids = [
    azurerm_network_interface.member_nic01.id,
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

  boot_diagnostics {}

}


resource "azurerm_virtual_machine_extension" "join_domain" {
  name                 = azurerm_windows_virtual_machine.member01.name
  publisher            = "Microsoft.Compute"
  type                 = "JsonADDomainExtension"
  type_handler_version = "1.3"
  virtual_machine_id   = azurerm_windows_virtual_machine.member01.id

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

# promote VM as domain controller
resource "azurerm_virtual_machine_extension" "promote_as_domain_controller" {
  name                 = "promote-as-domain-controller"
  virtual_machine_id   = azurerm_windows_virtual_machine.member01.id
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.9"
  settings             = <<SETTINGS
  {
    "commandToExecute": "powershell -command \"[System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String('${base64encode(data.template_file.promote_as_domain_script.rendered)}')) | Out-File -filepath PromoteAsDomain.ps1\" && powershell -ExecutionPolicy Unrestricted -File PromoteAsDomain.ps1 -domain_name ${data.template_file.promote_as_domain_script.vars.domain_name} -domain_user_upn ${data.template_file.promote_as_domain_script.vars.domain_user_upn} -domain_user_password ${data.template_file.promote_as_domain_script.vars.domain_user_password}"
  }
SETTINGS

  depends_on = [
    azurerm_virtual_machine_extension.join_domain
  ]
}

#Script to promote a server as a domain controller
data "template_file" "promote_as_domain_script" {
  template = file("${path.module}/files/PromoteAsDomain.ps1")

  vars = {
    domain_name          = "${var.active_directory_domain_name}"
    domain_user_upn      = "${var.admin_username}"
    domain_user_password = "${var.admin_password}"
  }

}


#member server02
resource "azurerm_public_ip" "static02" {
  name                = "${var.prefix}-member02-pip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_network_interface" "member02_nic" {
  name                = "${var.prefix}-member02-nic"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "primary"
    subnet_id                     = var.domain_members_subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.static02.id
  }

}

resource "azurerm_windows_virtual_machine" "member02" {
  name                     = "${var.prefix}-member02"
  resource_group_name      = var.resource_group_name
  location                 = var.location
  size                     = "Standard_B2ms"
  admin_username           = var.admin_username
  admin_password           = var.admin_password
  provision_vm_agent       = true
  enable_automatic_updates = true

  network_interface_ids = [
    azurerm_network_interface.member02_nic.id,
  ]

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-datacenter-gensecond"
    version   = "latest"
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  boot_diagnostics {}

}


resource "azurerm_virtual_machine_extension" "join_domain02" {
  name                 = azurerm_windows_virtual_machine.member02.name
  publisher            = "Microsoft.Compute"
  type                 = "JsonADDomainExtension"
  type_handler_version = "1.3"
  virtual_machine_id   = azurerm_windows_virtual_machine.member02.id

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

# member computers
resource "azurerm_public_ip" "static" {
  count               = local.vm_count
  name                = "${var.prefix}-member${count.index}-pip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_network_interface" "nic" {
  count               = local.vm_count
  name                = "${var.prefix}-computer${count.index}-nic"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "primary"
    subnet_id                     = var.domain_members_subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.static[count.index].id
  }

}

resource "azurerm_windows_virtual_machine" "member" {
  count                    = local.vm_count
  name                     = "${var.prefix}-computer${count.index}"
  resource_group_name      = var.resource_group_name
  location                 = var.location
  size                     = "Standard_B2ms"
  admin_username           = var.admin_username
  admin_password           = var.admin_password
  provision_vm_agent       = true
  enable_automatic_updates = true

  network_interface_ids = [
    azurerm_network_interface.nic[count.index].id,
  ]

  source_image_reference {
    publisher = "microsoftwindowsdesktop"
    offer     = "windows-11"
    sku       = "win11-22h2-ent"
    version   = "latest"
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  boot_diagnostics {}

}

# join-domain VMs
resource "azurerm_virtual_machine_extension" "join_domain_computers" {
  count                = local.vm_count
  name                 = "Join-Domain-${azurerm_windows_virtual_machine.member[count.index].name}"
  publisher            = "Microsoft.Compute"
  type                 = "JsonADDomainExtension"
  type_handler_version = "1.3"
  virtual_machine_id   = azurerm_windows_virtual_machine.member[count.index].id

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


# VM for Intune
resource "azurerm_public_ip" "static_mem" {
  name                = "${var.prefix}-member-pip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_network_interface" "nic_mem" {
  name                = "${var.prefix}-computer-nic"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "primary"
    subnet_id                     = var.domain_members_subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.static_mem.id
  }

}

resource "azurerm_windows_virtual_machine" "mem" {
  name                     = "${var.prefix}-computer"
  resource_group_name      = var.resource_group_name
  location                 = var.location
  size                     = "Standard_B2ms"
  admin_username           = var.admin_username
  admin_password           = var.admin_password
  provision_vm_agent       = true
  enable_automatic_updates = true

  network_interface_ids = [
    azurerm_network_interface.nic_mem.id,
  ]

  source_image_reference {
    publisher = "microsoftwindowsdesktop"
    offer     = "windows-11"
    sku       = "win11-22h2-ent"
    version   = "latest"
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  boot_diagnostics {}

}

# test VM
resource "azurerm_public_ip" "static_test" {
  count               = 2
  name                = "Intune-test-pip${count.index}"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_network_interface" "nic_test" {
  count               = 2
  name                = "Intune-test-nic${count.index}"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "primary"
    subnet_id                     = var.domain_members_subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.static_test[count.index].id
  }

}

resource "azurerm_windows_virtual_machine" "test" {
  count                    = 2
  name                     = "Intune-test${count.index}"
  resource_group_name      = var.resource_group_name
  location                 = var.location
  size                     = "Standard_B2ms"
  admin_username           = var.admin_username
  admin_password           = var.admin_password
  provision_vm_agent       = true
  enable_automatic_updates = true

  network_interface_ids = [
    azurerm_network_interface.nic_test[count.index].id,
  ]

  source_image_reference {
    publisher = "microsoftwindowsdesktop"
    offer     = "windows-11"
    sku       = "win11-22h2-ent"
    version   = "latest"
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  boot_diagnostics {}

}

resource "azurerm_public_ip" "static_avd02" {
  name                = "avd02-pip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_network_interface" "nic_avd02" {
  name                = "avd02-nic"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "primary"
    subnet_id                     = var.domain_members_subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.static_avd02.id
  }

}

resource "azurerm_windows_virtual_machine" "avd02" {
  name                     = "avd02"
  resource_group_name      = var.resource_group_name
  location                 = var.location
  size                     = "Standard_B2ms"
  admin_username           = var.admin_username
  admin_password           = var.admin_password
  provision_vm_agent       = true
  enable_automatic_updates = true

  network_interface_ids = [
    azurerm_network_interface.nic_avd02.id,
  ]

  source_image_reference {
    publisher = "microsoftwindowsdesktop"
    offer     = "windows-11"
    sku       = "win11-22h2-avd"
    version   = "latest"
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  boot_diagnostics {}

}

resource "azurerm_virtual_machine_extension" "join_domain_avd02" {
  name                 = "Join-Domain-${azurerm_windows_virtual_machine.avd02.name}"
  publisher            = "Microsoft.Compute"
  type                 = "JsonADDomainExtension"
  type_handler_version = "1.3"
  virtual_machine_id   = azurerm_windows_virtual_machine.avd02.id

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
        "Password": "Cul33329"
    }
SETTINGS

  depends_on = [
    azurerm_virtual_machine_extension.create-ad-forest
  ]

}