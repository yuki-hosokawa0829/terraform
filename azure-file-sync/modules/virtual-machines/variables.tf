# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

variable "prefix" {
  description = "The prefix which should be used for all resources in this example"
}

variable "location" {
  description = "The Azure Region in which all resources in this example should be created."
}

variable "resource_group_name" {
  description = "The name of the Resource Group"
}

variable "virtual_network_address_space" {
  description = "IP Address Space of Virtual Network"
}

variable "subnet_id" {
  description = "Subnet ID for the File Server"
}

variable "subnet_onprem_id" {
  description = "Subnet ID for the File Server on premise"
}

variable "subnet_dc_id" {
  description = "Subnet ID for the Domain Contoller"
}

variable "storage_id" {
  description = "Id for the storage account"
}

variable "active_directory_domain_name" {
  description = "the domain name for Active Directory, for example `consoto.local`"
}

variable "active_directory_netbios_name" {
  description = "The netbios name of the Active Directory domain, for example `consoto`"
}

variable "admin_username" {
  description = "Username for the Administrator account"
}

variable "admin_password" {
  description = "Password for the Administrator account"
}

variable "storage_blob_url" {
  description = "URL for blob container"
}

locals {
  domain_controller_subnet             = cidrsubnet("${var.virtual_network_address_space}", 2, 0)
  domain_controller_private_ip_address = cidrhost("${local.domain_controller_subnet}", 4)
  virtual_machine_name                 = join("-", [var.prefix, "fs"])
  virtual_machine_name_onprem          = join("-", [var.prefix, "fs-onprem"])
  virtual_machine_name_dc              = join("-", [var.prefix, "dc"])
  virtual_machine_fqdn                 = join(".", [local.virtual_machine_name_dc, var.active_directory_domain_name])
  auto_logon_data                      = "<AutoLogon><Password><Value>${var.admin_password}</Value></Password><Enabled>true</Enabled><LogonCount>1</LogonCount><Username>${var.admin_username}</Username></AutoLogon>"
  first_logon_data                     = file("${path.module}/files/FirstLogonCommands.xml")
  custom_data_params                   = "Param($RemoteHostName = \"${local.virtual_machine_fqdn}\", $ComputerName = \"${local.virtual_machine_name}\")"
  custom_data                          = base64encode(join(" ", [local.custom_data_params, file("${path.module}/files/winrm.ps1")]))
  import_command                       = "Import-Module ADDSDeployment"
  password_command                     = "$password = ConvertTo-SecureString ${var.admin_password} -AsPlainText -Force"
  install_ad_command                   = "Add-WindowsFeature -name ad-domain-services -IncludeManagementTools"
  configure_ad_command                 = "Install-ADDSForest -CreateDnsDelegation:$false -DomainMode Win2012R2 -DomainName ${var.active_directory_domain_name} -DomainNetbiosName ${var.active_directory_netbios_name} -ForestMode Win2012R2 -InstallDns:$true -SafeModeAdministratorPassword $password -Force:$true"
  shutdown_command                     = "shutdown -r -t 10"
  exit_code_hack                       = "exit 0"
  powershell_command                   = "${local.import_command}; ${local.password_command}; ${local.install_ad_command}; ${local.configure_ad_command}; ${local.shutdown_command}; ${local.exit_code_hack}"
}