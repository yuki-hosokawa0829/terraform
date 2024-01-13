data "azurerm_client_config" "current" {}

# Key Vault
resource "random_id" "kv-name" {
  byte_length = 6
  prefix      = var.prefix
}

resource "azurerm_key_vault" "kv1" {
  name                        = random_id.kv-name.hex
  location                    = var.regions.region1.location
  resource_group_name         = var.resource_group_name
  enabled_for_disk_encryption = true
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false
  sku_name                    = "standard"

  # Policy for VM Password
  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    key_permissions = [
      "Get",
    ]

    secret_permissions = [
      "Get", "Backup", "Delete", "List", "Purge", "Recover", "Restore", "Set",
    ]

    storage_permissions = [
      "Get",
    ]

  }

  #Policy to Show Secret on Azure Portal
  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = local.admin_user_id

    key_permissions = [
      "Get",
    ]

    secret_permissions = [
      "Get", "Backup", "Delete", "List", "Purge", "Recover", "Restore", "Set",
    ]

    storage_permissions = [
      "Get",
    ]

  }

}

# Create VM password
resource "random_password" "vmpassword" {
  length  = 20
  special = true
}

# Create Key Vault Secret
resource "azurerm_key_vault_secret" "vmpassword" {
  name            = "vmpassword"
  value           = random_password.vmpassword.result
  key_vault_id    = azurerm_key_vault.kv1.id
  expiration_date = timeadd(timestamp(), "8760h")
  content_type    = "Password"
}