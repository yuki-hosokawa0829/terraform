resource "azurerm_role_assignment" "role_vm" {
  scope                = var.storage_id
  role_definition_name = "Storage Blob Data Reader"
  principal_id         = var.vm_principal_id
}

resource "azurerm_role_assignment" "role_vm_onprem" {
  scope                = var.storage_id
  role_definition_name = "Storage Blob Data Reader"
  principal_id         = var.vm_onprem_principal_id
}

/* data "azuread_service_principal" "example" {
  display_name = "Microsoft.StorageSync"
} */

resource "azurerm_role_assignment" "role_storagesync" {
  scope                = var.storage_id
  role_definition_name = "Reader and Data Access"
  principal_id         = "2a2b9908-6ea1-4ae2-8e65-a410df84e7d1"  //data.azuread_service_principal.example.object_id
}

//resource "azuread_user" "example" {
//    user_principal_name = var.user_principal_name //自テナントに所属するアカウント名を指定
//    display_name        = var.display_name //任意の名前を指定
//    password            = var.password //任意のパスワードを指定
//}

//resource "azurerm_role_assignment" "role_rg" {
//    scope                = var.resource_group_id
//    role_definition_name = "Contributor"
//    principal_id         = azuread_user.example.object_id
//}