provider "azurerm" {
  features {}
  subscription_id = var.usr_subscription_id
  tenant_id       = var.usr_tenant_id
  client_id       = var.usr_client_id
  client_secret   = var.usr_client_secret
}

data "azurerm_resource_group" "rg" {
  name = "${var.prefix}-rg"
}

################## user/group  role assignment setting ##################
# access avd users
data "azuread_user" "avd_user" {
  for_each            = toset(local.avd_user_name)
  user_principal_name = "${each.value}@${var.aad_domain}"
}

# access an existing built-in role
data "azurerm_role_definition" "role" {
  name = "Desktop Virtualization User"
}

# access an existing user group
data "azuread_group" "avd_user_group" {
  display_name     = local.avd_user_group_name
  security_enabled = true
}

# assign role to user group
resource "azurerm_role_assignment" "role" {
  scope              = "/subscriptions/${var.usr_subscription_id}/resourceGroups/${data.azurerm_resource_group.rg.name}/providers/Microsoft.DesktopVirtualization/applicationgroups/${local.app_group_name}"
  role_definition_id = data.azurerm_role_definition.role.id
  principal_id       = data.azuread_group.avd_user_group.id
}

################## storage role assignment setting ##################
## Azure built-in roles
## https://docs.microsoft.com/en-us/azure/role-based-access-control/built-in-roles
data "azurerm_role_definition" "storage_role" {
  name = "Storage File Data SMB Share Contributor"
}

# access an existing storage account
data "azurerm_storage_account" "storage" {
  name                = "storagenncd2d"
  resource_group_name = data.azurerm_resource_group.rg.name
}

# assign role to user group
resource "azurerm_role_assignment" "af_role" {
  scope              = data.azurerm_storage_account.storage.id
  role_definition_id = data.azurerm_role_definition.storage_role.id
  principal_id       = data.azuread_group.avd_user_group.id
}