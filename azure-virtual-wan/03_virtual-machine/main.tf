# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

provider "azurerm" {
  features {}
  subscription_id = var.usr_subscription_id
  tenant_id       = var.usr_tenant_id
  client_id       = var.usr_client_id
  client_secret   = var.usr_client_secret
}

################### import data source ###################
# add resource group data source
data "azurerm_resource_group" "rg" {
  name = "${var.prefix}-rg"
}

# add domain controller subnet in Japan West data source
data "azurerm_subnet" "domain_controllers_jw" {
  name                 = "domain-controllers"
  resource_group_name  = data.azurerm_resource_group.rg.name
  virtual_network_name = join("-", [var.prefix, "network-jw"])
}

# add domain controller subnet in Japan East data source
data "azurerm_subnet" "domain_controllers_je" {
  name                 = "domain-controllers"
  resource_group_name  = data.azurerm_resource_group.rg.name
  virtual_network_name = join("-", [var.prefix, "network-je"])
}

# add domain controller subnet on Premises data source
data "azurerm_subnet" "domain_controllers_onprem" {
  name                 = "domain-controllers"
  resource_group_name  = data.azurerm_resource_group.rg.name
  virtual_network_name = join("-", [var.prefix, "network-onprem"])
}

#Script to promote as a domain controller
data "template_file" "promote_as_domain_script" {
  template = file("${path.module}/files/PromoteAsDomain.ps1")

  vars = {
    domain_name          = "${var.domain_name}"
    domain_user_upn      = "${var.domain_user_upn}"
    domain_user_password = "${var.domain_user_password}"
  }

}

################### create resource ###################
#VM in Japan West
/* resource "azurerm_public_ip" "static_jw" {
  name                = "${var.prefix}-dc-jw-pip"
  location            = var.location01
  resource_group_name = data.azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
} */

resource "azurerm_network_interface" "dc_jw_nic" {
  name                = join("-", [var.prefix, "dc-jw-primary"])
  location            = var.location01
  resource_group_name = data.azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "primary"
    subnet_id                     = data.azurerm_subnet.domain_controllers_jw.id
    private_ip_address_allocation = "Static"
    private_ip_address            = cidrhost(data.azurerm_subnet.domain_controllers_jw.address_prefixes.0, 4)
    /* public_ip_address_id          = azurerm_public_ip.static_jw.id */
  }

}

resource "azurerm_windows_virtual_machine" "domain_controller_jw" {
  name                = "${local.virtual_machine_name}-jw"
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = var.location01
  size                = "Standard_B2ms"
  admin_username      = var.domain_user_upn
  admin_password      = var.domain_user_password
  custom_data         = local.custom_data

  network_interface_ids = [
    azurerm_network_interface.dc_jw_nic.id
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
  virtual_machine_id   = azurerm_windows_virtual_machine.domain_controller_jw.id
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.9"
  settings             = <<SETTINGS
  {
    "commandToExecute": "powershell.exe -Command \"${local.powershell_command_to_create_forest}\""
  }
SETTINGS

}


#VM in Japan East
/* resource "azurerm_public_ip" "static_je" {
  name                = "${var.prefix}-dc-je-pip"
  location            = var.location02
  resource_group_name = data.azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
} */

resource "azurerm_network_interface" "dc_je_nic" {
  name                = join("-", [var.prefix, "dc-je-primary"])
  location            = var.location02
  resource_group_name = data.azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "primary"
    subnet_id                     = data.azurerm_subnet.domain_controllers_je.id
    private_ip_address_allocation = "Static"
    private_ip_address            = cidrhost(data.azurerm_subnet.domain_controllers_je.address_prefixes.0, 4)
    /* public_ip_address_id          = azurerm_public_ip.static_je.id */
  }

}

resource "azurerm_windows_virtual_machine" "domain_controller_je" {
  name                     = "${local.virtual_machine_name}-je"
  resource_group_name      = data.azurerm_resource_group.rg.name
  location                 = var.location02
  size                     = "Standard_B2ms"
  admin_username           = var.local_admin_username
  admin_password           = var.local_admin_password
  provision_vm_agent       = true
  enable_automatic_updates = true

  network_interface_ids = [
    azurerm_network_interface.dc_je_nic.id
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
  name                 = azurerm_windows_virtual_machine.domain_controller_je.name
  publisher            = "Microsoft.Compute"
  type                 = "JsonADDomainExtension"
  type_handler_version = "1.3"
  virtual_machine_id   = azurerm_windows_virtual_machine.domain_controller_je.id

  settings = <<SETTINGS
    {
        "Name": "${var.domain_name}",
        "OUPath": "",
        "User": "${var.domain_user_upn}@${var.domain_name}",
        "Restart": "true",
        "Options": "3"
    }
SETTINGS

  protected_settings = <<SETTINGS
    {
        "Password": "${var.domain_user_password}"
    }
SETTINGS

  depends_on = [
    azurerm_virtual_machine_extension.create-ad-forest
  ]

}

resource "azurerm_virtual_machine_extension" "promote_as_domain_controller" {
  name                 = "promote-as-domain-controller"
  virtual_machine_id   = azurerm_windows_virtual_machine.domain_controller_je.id
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

#VM on Premises
/* resource "azurerm_public_ip" "static_onprem" {
  name                = "${var.prefix}-dc-onprem-pip"
  location            = var.location02
  resource_group_name = data.azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
} */

resource "azurerm_network_interface" "dc_onprem_nic" {
  name                = join("-", [var.prefix, "dc-onprem-primary"])
  location            = var.location02
  resource_group_name = data.azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "primary"
    subnet_id                     = data.azurerm_subnet.domain_controllers_onprem.id
    private_ip_address_allocation = "Static"
    private_ip_address            = cidrhost(data.azurerm_subnet.domain_controllers_onprem.address_prefixes.0, 4)
    /* public_ip_address_id          = azurerm_public_ip.static_onprem.id */
  }

}

resource "azurerm_windows_virtual_machine" "domain_controller_onprem" {
  name                     = "${local.virtual_machine_name}-onprem"
  resource_group_name      = data.azurerm_resource_group.rg.name
  location                 = var.location02
  size                     = "Standard_B2ms"
  admin_username           = var.local_admin_username
  admin_password           = var.local_admin_password
  provision_vm_agent       = true
  enable_automatic_updates = true

  network_interface_ids = [
    azurerm_network_interface.dc_onprem_nic.id
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

#Join Domain
resource "azurerm_virtual_machine_extension" "join_domain_onprem" {
  name                 = azurerm_windows_virtual_machine.domain_controller_onprem.name
  publisher            = "Microsoft.Compute"
  type                 = "JsonADDomainExtension"
  type_handler_version = "1.3"
  virtual_machine_id   = azurerm_windows_virtual_machine.domain_controller_onprem.id

  settings = <<SETTINGS
    {
        "Name": "${var.domain_name}",
        "OUPath": "",
        "User": "${var.domain_user_upn}@${var.domain_name}",
        "Restart": "true",
        "Options": "3"
    }
SETTINGS

  protected_settings = <<SETTINGS
    {
        "Password": "${var.domain_user_password}"
    }
SETTINGS

  depends_on = [
    azurerm_virtual_machine_extension.create-ad-forest
  ]

}

resource "azurerm_virtual_machine_extension" "promote_as_domain_controller_onprem" {
  name                 = "promote-as-domain-controller-onprem"
  virtual_machine_id   = azurerm_windows_virtual_machine.domain_controller_onprem.id
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.9"
  settings             = <<SETTINGS
  {
    "commandToExecute": "powershell -command \"[System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String('${base64encode(data.template_file.promote_as_domain_script.rendered)}')) | Out-File -filepath PromoteAsDomain.ps1\" && powershell -ExecutionPolicy Unrestricted -File PromoteAsDomain.ps1 -domain_name ${data.template_file.promote_as_domain_script.vars.domain_name} -domain_user_upn ${data.template_file.promote_as_domain_script.vars.domain_user_upn} -domain_user_password ${data.template_file.promote_as_domain_script.vars.domain_user_password}"
  }
SETTINGS

  depends_on = [
    azurerm_virtual_machine_extension.join_domain_onprem
  ]

}


