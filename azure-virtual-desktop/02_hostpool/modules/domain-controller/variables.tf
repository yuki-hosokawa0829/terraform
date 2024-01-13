# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

variable "prefix" {
  description = "The prefix which should be used for all resources in this example"
}

variable "location" {
  description = "The Azure Region in which all resources in this example should be created."
}

variable "resource_group_name" {
  description = "The name of the resource group"
}

variable "domain_controller_private_ip_address" {
  description = "The private IP address of the domain controller"
}

variable "aadc_server_private_ip_address" {
  description = "The private IP address of the AADC server"
}

variable "domain_controllers_subnet_id" {
  description = "Subnet ID for the Domain Controllers"
}

variable "domain_name" {
  description = "the domain name for Active Directory, for example `consoto.local`"
}

variable "domain_path" {
  description = "dc=yourdomain,dc=com"
}

variable "domain_netbios_name" {
  description = "The netbios name of the Active Directory domain, for example `consoto`"
}

variable "ou_path" {
  description = "OU for session host"
}

variable "domain_user_upn" {
  description = "Username for the Domain Administrator user"
}

variable "domain_user_password" {
  description = "Password for the Adminstrator user"
}

variable "aad_domain" {
  description = "The Azure Active Directory domain name"
}

locals {
  virtual_machine_name = join("-", [var.prefix, "dc"])
  virtual_machine_fqdn = join(".", [local.virtual_machine_name, var.domain_name])
  auto_logon_data      = "<AutoLogon><Password><Value>${var.domain_user_password}</Value></Password><Enabled>true</Enabled><LogonCount>1</LogonCount><Username>${var.domain_user_upn}</Username></AutoLogon>"
  first_logon_data     = file("${path.module}/files/FirstLogonCommands.xml")
  custom_data_params   = "Param($RemoteHostName = \"${local.virtual_machine_fqdn}\", $ComputerName = \"${local.virtual_machine_name}\")"
  custom_data          = base64encode(join(" ", [local.custom_data_params, file("${path.module}/files/winrm.ps1")]))
  module_list          = "ADDSDeployment,ActiveDirectory"
  import_command       = "Import-Module ${local.module_list}"
  password_command     = "$password = ConvertTo-SecureString ${var.domain_user_password} -AsPlainText -Force"
  install_ad_command   = "Add-WindowsFeature -name ad-domain-services -IncludeManagementTools"
  configure_ad_command = "Install-ADDSForest -CreateDnsDelegation:$false -DomainMode Win2012R2 -DomainName ${var.domain_name} -DomainNetbiosName ${var.domain_netbios_name} -ForestMode Win2012R2 -InstallDns:$true -SafeModeAdministratorPassword $password -Force:$true"
  shutdown_command     = "shutdown -r -t 10"
  exit_code_hack       = "exit 0"
  //create_ou_command                      = "New-ADOrganizationalUnit -Name ${var.ou_path} -Path ${var.domain_path}"
  //powershell_command                     = "${local.import_command}; ${local.password_command}; ${local.install_ad_command}; ${local.configure_ad_command}; ${local.shutdown_command}; ${local.exit_code_hack}; ${local.create_ou_command}"
  powershell_command      = "${local.import_command}; ${local.password_command}; ${local.install_ad_command}; ${local.configure_ad_command}; ${local.shutdown_command}; ${local.exit_code_hack}"
  aadc_powershell_command = "msiexec.exe /i https://download.microsoft.com/download/B/0/0/B00291D0-5A83-4DE7-86F5-980BC00DE05A/AzureADConnect.msi /qn /passive"
}
