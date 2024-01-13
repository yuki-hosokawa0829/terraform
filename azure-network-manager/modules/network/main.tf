################# Create a Virtual Network Manager instance #################
data "azurerm_subscription" "current" {
}

resource "azurerm_network_manager" "network_manager_instance" {
  name                = "network-manager"
  location            = var.location
  resource_group_name = var.resource_group_name
  scope_accesses      = ["Connectivity", "SecurityAdmin"]
  description         = "example network manager"

  scope {
    subscription_ids = [data.azurerm_subscription.current.id]
  }

}

################# Create mesh virtual networks #################
resource "random_string" "random01" {
  length  = 4
  special = false
  upper   = false
}

resource "random_pet" "virtual_network_name01" {
  prefix = "vnet-${random_string.random01.result}"
}

resource "azurerm_virtual_network" "vnet01" {
  count               = local.num01
  name                = "${random_pet.virtual_network_name01.id}-0${count.index}"
  resource_group_name = var.resource_group_name
  location            = var.location
  address_space       = ["10.${count.index}.0.0/16"]
}

# Add a subnet to each virtual network
resource "azurerm_subnet" "subnet_vnet01" {
  count                = local.num01
  name                 = "default"
  virtual_network_name = azurerm_virtual_network.vnet01[count.index].name
  resource_group_name  = var.resource_group_name
  address_prefixes     = ["10.${count.index}.0.0/24"]
}

# Create a network group
resource "azurerm_network_manager_network_group" "network_group01" {
  name               = "network-group01"
  network_manager_id = azurerm_network_manager.network_manager_instance.id
}

# Add virtual networks to a network group as dynamic members with Azure Policy
resource "random_pet" "network_group_policy_name01" {
  prefix = "network-group-policy01"
}

resource "azurerm_policy_definition" "network_group_policy01" {
  name         = random_pet.network_group_policy_name01.id
  policy_type  = "Custom"
  mode         = "Microsoft.Network.Data"
  display_name = "Policy Definition for Network Group"

  metadata = <<METADATA
    {
      "category": "Azure Virtual Network Manager"
    }
  METADATA

  policy_rule = <<POLICY_RULE
    {
      "if": {
        "allOf": [
          {
              "field": "type",
              "equals": "Microsoft.Network/virtualNetworks"
          },
          {
            "allOf": [
              {
              "field": "Name",
              "contains": "${random_pet.virtual_network_name01.id}"
              }
            ]
          }
        ]
      },
      "then": {
        "effect": "addToNetworkGroup",
        "details": {
          "networkGroupId": "${azurerm_network_manager_network_group.network_group01.id}"
        }
      }
    }
  POLICY_RULE
}

resource "azurerm_subscription_policy_assignment" "azure_policy_assignment01" {
  name                 = "${random_pet.network_group_policy_name01.id}-policy-assignment"
  policy_definition_id = azurerm_policy_definition.network_group_policy01.id
  subscription_id      = data.azurerm_subscription.current.id
}

# Create a connectivity configuration
resource "azurerm_network_manager_connectivity_configuration" "connectivity_config01" {
  name                  = "connectivity-config01"
  network_manager_id    = azurerm_network_manager.network_manager_instance.id
  connectivity_topology = "Mesh"

  applies_to_group {
    group_connectivity = "None"
    network_group_id   = azurerm_network_manager_network_group.network_group01.id
  }

}

##################Create Hub and Spoke Virtual Networks #################
resource "random_string" "random02" {
  length  = 4
  special = false
  upper   = false
}

resource "random_pet" "virtual_network_name02" {
  prefix = "vnet-${random_string.random02.result}"
}

resource "azurerm_virtual_network" "vnet02" {
  count               = local.num02
  name                = "${random_pet.virtual_network_name02.id}-0${count.index}"
  resource_group_name = var.resource_group_name
  location            = var.location
  address_space       = ["192.168.${count.index}.0/24"]
}

# Add a subnet to each virtual network
resource "azurerm_subnet" "subnet_vnet02" {
  count                = local.num02
  name                 = "default"
  virtual_network_name = azurerm_virtual_network.vnet02[count.index].name
  resource_group_name  = var.resource_group_name
  address_prefixes     = ["192.168.${count.index}.0/27"]
}

# Create a network group
resource "azurerm_network_manager_network_group" "network_group02" {
  name               = "network-group02"
  network_manager_id = azurerm_network_manager.network_manager_instance.id
}

# Add virtual networks to a network group as dynamic members with Azure Policy
resource "random_pet" "network_group_policy_name02" {
  prefix = "network-group-policy02"
}

resource "azurerm_policy_definition" "network_group_policy02" {
  name         = random_pet.network_group_policy_name02.id
  policy_type  = "Custom"
  mode         = "Microsoft.Network.Data"
  display_name = "Policy Definition for Network Group"

  metadata = <<METADATA
    {
        "category": "Azure Virtual Network Manager"
    }
    METADATA

  policy_rule = <<POLICY_RULE
    {
        "if": {
            "allOf": [
                {
                    "field": "type",
                    "equals": "Microsoft.Network/virtualNetworks"
                },
                {
                    "allOf": [
                        {
                            "field": "Name",
                            "contains": "${random_pet.virtual_network_name02.id}"
                        }
                    ]
                }
            ]
        },
        "then": {
            "effect": "addToNetworkGroup",
            "details": {
                "networkGroupId": "${azurerm_network_manager_network_group.network_group02.id}"
            }
        }
    }
    POLICY_RULE
}

resource "azurerm_subscription_policy_assignment" "azure_policy_assignment02" {
  name                 = "${random_pet.network_group_policy_name02.id}-policy-assignment"
  policy_definition_id = azurerm_policy_definition.network_group_policy02.id
  subscription_id      = data.azurerm_subscription.current.id
}

# Create a connectivity configuration
resource "azurerm_network_manager_connectivity_configuration" "connectivity_config02" {
  name                  = "connectivity-config02"
  network_manager_id    = azurerm_network_manager.network_manager_instance.id
  connectivity_topology = "HubAndSpoke"

  applies_to_group {
    group_connectivity = "None"
    network_group_id   = azurerm_network_manager_network_group.network_group02.id
  }

  hub {
    resource_id   = azurerm_virtual_network.vnet02[0].id
    resource_type = "Microsoft.Network/virtualNetworks"
  }

}

################## Create hub-and-spoke network with VPN Gateway #################
resource "random_string" "random03" {
  length  = 4
  special = false
  upper   = false
}

resource "random_pet" "virtual_network_name03" {
  prefix = "vnet-${random_string.random03.result}"
}

resource "azurerm_virtual_network" "vnet03" {
  count               = local.num03
  name                = "${random_pet.virtual_network_name03.id}-0${count.index}"
  resource_group_name = var.resource_group_name
  location            = var.location
  address_space       = ["172.16.${count.index}.0/24"]
}

# Add a subnet to each virtual network
resource "azurerm_subnet" "subnet_vnet03" {
  count                = local.num03
  name                 = "default"
  virtual_network_name = azurerm_virtual_network.vnet03[count.index].name
  resource_group_name  = var.resource_group_name
  address_prefixes     = ["172.16.${count.index}.0/27"]
}

# add GatewaySubnet to hub virtual network
resource "azurerm_subnet" "gateway_subnet" {
  name                 = "GatewaySubnet"
  virtual_network_name = azurerm_virtual_network.vnet03[0].name
  resource_group_name  = var.resource_group_name
  address_prefixes     = ["${cidrsubnet(azurerm_virtual_network.vnet03[0].address_space[0], 3, 1)}"]
}

# Create a network group
resource "azurerm_network_manager_network_group" "network_group03" {
  name               = "network-group03"
  network_manager_id = azurerm_network_manager.network_manager_instance.id
}

# Add virtual networks to a network group as static members
resource "azurerm_network_manager_static_member" "example" {
  count = local.num03
  name                      = "example-nmsm${count.index}"
  network_group_id          = azurerm_network_manager_network_group.network_group03.id
  target_virtual_network_id = azurerm_virtual_network.vnet03[count.index].id
}

# Create a connectivity configuration
resource "azurerm_network_manager_connectivity_configuration" "connectivity_config03" {
  name                  = "connectivity-config03"
  network_manager_id    = azurerm_network_manager.network_manager_instance.id
  connectivity_topology = "HubAndSpoke"

  applies_to_group {
    group_connectivity = "None"
    network_group_id   = azurerm_network_manager_network_group.network_group03.id
    use_hub_gateway    = true
  }

  hub {
    resource_id   = azurerm_virtual_network.vnet03[0].id
    resource_type = "Microsoft.Network/virtualNetworks"
  }

}

################## add VPN Gateway to hub virtual network ###################
resource "azurerm_public_ip" "gateway_public_ip" {
  name                = "gateway-pip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_virtual_network_gateway" "gateway" {
  name                = "gateway"
  location            = var.location
  resource_group_name = var.resource_group_name
  type                = "Vpn"
  vpn_type            = "RouteBased"
  sku                 = "VpnGw1"
  active_active       = false

  ip_configuration {
    name                 = "gw-ip-config"
    public_ip_address_id = azurerm_public_ip.gateway_public_ip.id
    subnet_id            = azurerm_subnet.gateway_subnet.id
  }

}

################## Commit Connectivity deployment #################
resource "azurerm_network_manager_deployment" "commit_deployment01" {
  network_manager_id = azurerm_network_manager.network_manager_instance.id
  location           = var.location
  scope_access       = "Connectivity"

  configuration_ids = [
    azurerm_network_manager_connectivity_configuration.connectivity_config01.id,
    azurerm_network_manager_connectivity_configuration.connectivity_config02.id,
    azurerm_network_manager_connectivity_configuration.connectivity_config03.id
  ]

  depends_on = [
    azurerm_network_manager_connectivity_configuration.connectivity_config01,
    azurerm_network_manager_connectivity_configuration.connectivity_config02,
    azurerm_network_manager_connectivity_configuration.connectivity_config03
  ]

}

################## Create admin rule #################
resource "azurerm_network_manager_security_admin_configuration" "example" {
  name               = "example-admin-conf"
  network_manager_id = azurerm_network_manager.network_manager_instance.id
}

resource "azurerm_network_manager_admin_rule_collection" "example" {
  name                            = "example-admin-rule-collection"
  security_admin_configuration_id = azurerm_network_manager_security_admin_configuration.example.id

  network_group_ids = [
    azurerm_network_manager_network_group.network_group01.id,
    azurerm_network_manager_network_group.network_group02.id,
    azurerm_network_manager_network_group.network_group03.id
  ]

}

resource "azurerm_network_manager_admin_rule" "admin_rule" {
  name                     = "admin-rule"
  admin_rule_collection_id = azurerm_network_manager_admin_rule_collection.example.id
  description              = "example admin rule"
  action                   = "Allow"
  direction                = "Inbound"
  priority                 = 1000
  protocol                 = "Tcp"
  destination_port_ranges  = ["3389"]

  source {
    address_prefix_type = "IPPrefix"
    address_prefix      = "219.166.164.110/32"
  }

  destination {
    address_prefix_type = "IPPrefix"
    address_prefix      = "*"
  }

}

################## Commit Security Admin deployment #################
resource "azurerm_network_manager_deployment" "commit_deployment02" {
  network_manager_id = azurerm_network_manager.network_manager_instance.id
  location           = var.location
  scope_access       = "SecurityAdmin"

  configuration_ids = [
    azurerm_network_manager_security_admin_configuration.example.id
  ]

  depends_on = [
    azurerm_network_manager_security_admin_configuration.example
  ]

}