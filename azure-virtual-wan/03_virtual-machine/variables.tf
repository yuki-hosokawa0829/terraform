# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

variable "prefix" {
  description = "The prefix which should be used for all resources in this example"
  default     = "wan"
}

variable "location01" {
  description = "The Azure Region in which most of all resources in this example should be created."
  default     = "JapanWest"
}

variable "location02" {
  description = "The Azure Region in which a hub resources in this example should be created."
  default     = "JapanEast"
}

variable "domain_name" {
  description = "Name of the domain to join"
  default     = "infra.local"
}

variable "domain_path" {
  description = "dc=yourdomain,dc=com"
  default     = "dc=infra,dc=local"
}

variable "domain_netbios_name" {
  description = "The netbios name of the Active Directory domain, for example `consoto`"
  default     = "INFRA"
}

variable "domain_user_upn" {
  description = "Username for domain join (do not include domain name as this is appended)"
  default     = "ppt-admin" # do not include domain name as this is appended
}

variable "domain_user_password" {
  description = "Password of the user to authenticate with the domain"
  default     = "P@ssw0rd0123"
  sensitive   = true
}

variable "local_admin_username" {
  description = "local admin username"
  default     = "ppt-admin"
}

variable "local_admin_password" {
  description = "local admin password"
  default     = "P@ssw0rd0123"
  sensitive   = true
}

variable "usr_subscription_id" {
  description = "The Azure Subscription ID"
  default     = "4d55c914-726b-4a03-b002-54c4bf217ad5"
}

variable "usr_tenant_id" {
  description = "Tenant ID"
  default     = "9781ab08-ef7d-4e4f-b6f0-c595b7a023cb"
}

variable "usr_client_id" {
  description = "Service Principal ID"
  default     = "78fedf0d-7c87-4643-b4dc-13062b0752ed"
}

variable "usr_client_secret" {
  description = "Password for the Administrator account"
  default     = "eQ28Q~S5MT4nodAKe3MrLD_mnVQyb7zXP3HanaxE"
}

locals {
  virtual_machine_name                = join("-", [var.prefix, "dc"])
  virtual_machine_fqdn                = join(".", [local.virtual_machine_name, var.domain_name])
  auto_logon_data                     = "<AutoLogon><Password><Value>${var.domain_user_password}</Value></Password><Enabled>true</Enabled><LogonCount>1</LogonCount><Username>${var.domain_user_upn}</Username></AutoLogon>"
  first_logon_data                    = file("${path.module}/files/FirstLogonCommands.xml")
  custom_data_params                  = "Param($RemoteHostName = \"${local.virtual_machine_fqdn}\", $ComputerName = \"${local.virtual_machine_name}\")"
  custom_data                         = base64encode(join(" ", [local.custom_data_params, file("${path.module}/files/winrm.ps1")]))
  import_command                      = "Import-Module ADDSDeployment"
  password_command                    = "$password = ConvertTo-SecureString ${var.domain_user_password} -AsPlainText -Force"
  install_ad_command                  = "Add-WindowsFeature -name ad-domain-services -IncludeManagementTools"
  configure_ad_command                = "Install-ADDSForest -CreateDnsDelegation:$false -DomainMode WinThreshold -DomainName ${var.domain_name} -DomainNetbiosName ${var.domain_netbios_name} -ForestMode WinThreshold -InstallDns:$true -SafeModeAdministratorPassword $password -Force:$true"
  shutdown_command                    = "shutdown -r -t 10"
  exit_code_hack                      = "exit 0"
  powershell_command_to_create_forest = "${local.import_command}; ${local.password_command}; ${local.install_ad_command}; ${local.configure_ad_command}; ${local.shutdown_command}; ${local.exit_code_hack}"

  //credential_data                     = "$Cred = New-Object PSCredential ${var.domain_user_upn}@${var.domain_name},${local.password_command}"
  //parameter_list                      = "$Params = @{Credential = ${local.credential_data}; DomainName = ${var.domain_name}; SiteName = Default-First-Site-Name; LogPath = C:\Windows\NTDS; SysvolPath = C:\Windows\SYSVOL ; ReplicationSourceDC = ; NoGlobalCatalog = $false; CriticalReplicationOnly = $false; SafeModeAdministratorPassword = ${local.password_command}; InstallDns = $true; CreateDnsDelegation = $false; NoRebootOnCompletion = $false; Confirm = $false;}"
  //powershell_command_to_add_to_domain = "Install-ADDSDomainController ${local.parameter_list}" 
}
