resource "azurerm_netapp_account" "example" {
  name                = "netappaccount"
  location            = var.location
  resource_group_name = var.resource_group_name

  active_directory {
    username        = var.admin_username
    password        = var.admin_password
    smb_server_name = "NETAPP"
    dns_servers     = ["${var.domain_controller_private_ip_address}", "${var.domain_member01_private_ip_address}"]
    domain          = "${var.prefix}.local"
  }

  timeouts {
    create = "60m"
    read   = "60m"
  }

}

resource "azurerm_netapp_pool" "example" {
  name                = "netapppool"
  location            = var.location
  resource_group_name = var.resource_group_name
  account_name        = azurerm_netapp_account.example.name
  service_level       = "Standard"
  size_in_tb          = 4
}

resource "azurerm_netapp_volume" "volume01" {
  name     = "example-netappvolume01"
  location = var.location
  resource_group_name        = var.resource_group_name
  account_name               = azurerm_netapp_account.example.name
  pool_name                  = azurerm_netapp_pool.example.name
  volume_path                = "my-unique-file-path01"
  service_level              = "Standard"
  subnet_id                  = var.anf_subnet_id
  network_features           = "Basic"
  protocols                  = ["CIFS"]
  security_style             = "ntfs"
  storage_quota_in_gb        = 1000
  snapshot_directory_visible = false

  data_protection_snapshot_policy {
    snapshot_policy_id = azurerm_netapp_snapshot_policy.example.id
  }

  timeouts {
    create = "60m"
    read   = "60m"
  }

}

resource "azurerm_netapp_volume" "volume02" {
  name     = "example-netappvolume02"
  location = var.location
  resource_group_name        = var.resource_group_name
  account_name               = azurerm_netapp_account.example.name
  pool_name                  = azurerm_netapp_pool.example.name
  volume_path                = "my-unique-file-path02"
  service_level              = "Standard"
  subnet_id                  = var.anf_subnet_id
  network_features           = "Basic"
  protocols                  = ["CIFS"]
  security_style             = "ntfs"
  storage_quota_in_gb        = 1000
  snapshot_directory_visible = false

  data_protection_snapshot_policy {
    snapshot_policy_id = azurerm_netapp_snapshot_policy.example.id
  }

  timeouts {
    create = "60m"
    read   = "60m"
  }

}

# add snapshot
resource "azurerm_netapp_snapshot" "snapshot01" {
  name                = "example-netappsnapshot01"
  location            = var.location
  resource_group_name = var.resource_group_name
  account_name        = azurerm_netapp_account.example.name
  pool_name           = azurerm_netapp_pool.example.name
  volume_name         = azurerm_netapp_volume.volume01.name
}

resource "azurerm_netapp_snapshot" "snapshot02" {
  name                = "example-netappsnapshot02"
  location            = var.location
  resource_group_name = var.resource_group_name
  account_name        = azurerm_netapp_account.example.name
  pool_name           = azurerm_netapp_pool.example.name
  volume_name         = azurerm_netapp_volume.volume02.name
}

# add snapshot policy
resource "azurerm_netapp_snapshot_policy" "example" {
  name                = "snapshotpolicy-01"
  location            = var.location
  resource_group_name = var.resource_group_name
  account_name        = azurerm_netapp_account.example.name
  enabled             = true

  hourly_schedule {
    snapshots_to_keep = 4
    minute            = 15
  }

  daily_schedule {
    snapshots_to_keep = 2
    hour              = 18
    minute            = 0
  }

  weekly_schedule {
    snapshots_to_keep = 1
    days_of_week      = ["Monday", "Tuesday"]
    hour              = 20
    minute            = 0
  }

  monthly_schedule {
    snapshots_to_keep = 1
    days_of_month     = [19, 20, 30]
    hour              = 21
    minute            = 0
  }

}