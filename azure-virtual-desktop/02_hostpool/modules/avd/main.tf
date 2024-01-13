resource "azurerm_virtual_desktop_workspace" "workspace" {
  resource_group_name = var.resource_group_name
  location            = var.avd_location
  name                = var.workspace_name
  friendly_name       = "${var.prefix} Workspace"
  description         = "${var.prefix} Workspace"
}

resource "azurerm_virtual_desktop_host_pool" "hostpool" {
  resource_group_name      = var.resource_group_name
  location                 = var.avd_location
  name                     = var.hostpool_name
  friendly_name            = var.hostpool_name
  validate_environment     = true
  custom_rdp_properties    = "drivestoredirect:s:;redirectclipboard:i:0;redirectprinters:i:0;redirectsmartcards:i:0;camerastoredirect:s:*;audiocapturemode:i:1;"
  description              = "${var.prefix} Terraform HostPool"
  type                     = "Pooled"
  maximum_sessions_allowed = 16
  load_balancer_type       = "DepthFirst" #[BreadthFirst DepthFirst]
}

resource "azurerm_virtual_desktop_host_pool_registration_info" "registrationinfo" {
  hostpool_id     = azurerm_virtual_desktop_host_pool.hostpool.id
  expiration_date = var.rfc3339
}

resource "azurerm_virtual_desktop_application_group" "dag" {
  resource_group_name          = var.resource_group_name
  host_pool_id                 = azurerm_virtual_desktop_host_pool.hostpool.id
  location                     = var.avd_location
  type                         = "Desktop"
  name                         = "${var.prefix}-dag"
  friendly_name                = "Desktop AppGroup"
  description                  = "AVD application group"
  default_desktop_display_name = "AVD検証環境"

  depends_on = [
    azurerm_virtual_desktop_host_pool.hostpool, azurerm_virtual_desktop_workspace.workspace
  ]
}

resource "azurerm_virtual_desktop_workspace_application_group_association" "ws-dag" {
  application_group_id = azurerm_virtual_desktop_application_group.dag.id
  workspace_id         = azurerm_virtual_desktop_workspace.workspace.id
}