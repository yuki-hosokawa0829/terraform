data "azurerm_client_config" "current" {}

# Key Vault
resource "random_id" "kvname" {
  byte_length = 5
  prefix      = "kv-"
}

resource "azurerm_key_vault" "keyvault" {
  name                        = random_id.kvname.hex
  resource_group_name         = var.resource_group_name
  location                    = var.regions.region1.location
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


# Secret for VM Passwords
resource "random_password" "vmpassword" {
  length  = 20
  special = true
}

resource "azurerm_key_vault_secret" "vmpassword" {
  name         = "vmpassword"
  value        = random_password.vmpassword.result
  key_vault_id = azurerm_key_vault.keyvault.id
  depends_on   = [azurerm_key_vault.keyvault]
}


/* # Secret for VPN Pre-Shared Key
resource "random_password" "vpnpsk" {
  length  = 20
  special = true
}

resource "azurerm_key_vault_secret" "vpnpsk" {
  name         = "vpnpsk"
  value        = random_password.vpnpsk.result
  key_vault_id = azurerm_key_vault.keyvault.id
  depends_on   = [azurerm_key_vault.keyvault]
} */