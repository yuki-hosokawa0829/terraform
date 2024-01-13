variable "prefix" {}

variable "location" {}

variable "resource_group_name" {}

variable "peering_subnet_id" {}

variable "onprem_subnet_id" {}

variable "vm_peer_private_ip_address" {}

variable "vm_onprem_private_ip_address" {}

variable "domain_name" {}

variable "domain_netbios_name" {}

variable "domain_admin_username" {}

variable "domain_admin_password" {}

locals {
  virtual_machine_name                = "vm-onprem"
  virtual_machine_fqdn                = join(".", [local.virtual_machine_name, var.domain_name])
  auto_logon_data                     = "<AutoLogon><Password><Value>${var.domain_admin_password}</Value></Password><Enabled>true</Enabled><LogonCount>1</LogonCount><Username>${var.domain_admin_username}</Username></AutoLogon>"
  first_logon_data                    = file("${path.module}/files/FirstLogonCommands.xml")
  custom_data_params                  = "Param($RemoteHostName = \"${local.virtual_machine_fqdn}\", $ComputerName = \"${local.virtual_machine_name}\")"
  custom_data                         = base64encode(join(" ", [local.custom_data_params, file("${path.module}/files/winrm.ps1")]))
  import_command                      = "Import-Module ADDSDeployment"
  password_command                    = "$password = ConvertTo-SecureString ${var.domain_admin_password} -AsPlainText -Force"
  install_ad_command                  = "Add-WindowsFeature -name ad-domain-services -IncludeManagementTools"
  configure_ad_command                = "Install-ADDSForest -CreateDnsDelegation:$false -DomainMode WinThreshold -DomainName ${var.domain_name} -DomainNetbiosName ${var.domain_netbios_name} -ForestMode WinThreshold -InstallDns:$true -SafeModeAdministratorPassword $password -Force:$true"
  shutdown_command                    = "shutdown -r -t 10"
  exit_code_hack                      = "exit 0"
  powershell_command_to_create_forest = "${local.import_command}; ${local.password_command}; ${local.install_ad_command}; ${local.configure_ad_command}; ${local.shutdown_command}; ${local.exit_code_hack}"
}