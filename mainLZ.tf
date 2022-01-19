#main.tf 
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "2.90.0"
    }
  }
  backend "azurerm" {
    resource_group_name  = "tfstate"
    storage_account_name = "tfstate878806923"
    container_name       = "tfstate"
    key                  = "terraform.tfstate"
  }
}

provider "azurerm" {
  features {
  }
  # Configuration options */
  /*subscription_id   = "<azure_subscription_id>"
  tenant_id         = "<azure_subscription_tenant_id>"
  client_id         = "<service_principal_appid>"
  client_secret     = "<service_principal_password>" */
}

data "azurerm_client_config" "current" {}

# Create a resource group
resource "azurerm_resource_group" "NBOS_AZ_RG" {
  name     = "NBOS_AZ_RG${var.az_suffix}"
  location = "eastus2"
}

resource "azurerm_key_vault" "AZ_KV" {
  name                        = "NBOS-AZ-KV"
  location                    = azurerm_resource_group.NBOS_AZ_RG.location
  resource_group_name         = azurerm_resource_group.NBOS_AZ_RG.name
  enabled_for_disk_encryption = true
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false

  sku_name = "standard"

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    key_permissions = [
      "Get",
    ]

    secret_permissions = [
      "Get",
    ]
  }
}
# Create a virtual network within the resource group
resource "azurerm_virtual_network" "NBOS_AZ_VN" {
  name                = "NBOS-VN-network${var.az_suffix}"
  resource_group_name = azurerm_resource_group.NBOS_AZ_RG.name
  location            = azurerm_resource_group.NBOS_AZ_RG.location
  address_space       = [var.vnet_cidr]
}

locals {
  svcEndpoints = {
    subnet1 = [ "Microsoft.AzureActiveDirectory", "Microsoft.AzureCosmosDB", "Microsoft.ContainerRegistry", "Microsoft.EventHub", "Microsoft.KeyVault", "Microsoft.ServiceBus", "Microsoft.Sql", "Microsoft.Storage", "Microsoft.Web"]
    subnet2 = [ "Microsoft.AzureActiveDirectory", "Microsoft.AzureCosmosDB", "Microsoft.ContainerRegistry", "Microsoft.EventHub", "Microsoft.KeyVault", "Microsoft.ServiceBus", "Microsoft.Sql", "Microsoft.Storage", "Microsoft.Web"]
    subnet3 = [ "Microsoft.AzureActiveDirectory" ]
    subnet4 = [ "Microsoft.ContainerRegistry", "Microsoft.KeyVault", "Microsoft.ServiceBus", "Microsoft.Sql", "Microsoft.Storage", "Microsoft.Web"]
  }
}

resource "azurerm_subnet" "nbos_az_subnet" {
  for_each             = var.subnet_list
  name                 = each.value
  resource_group_name  = azurerm_resource_group.NBOS_AZ_RG.name
  virtual_network_name = azurerm_virtual_network.NBOS_AZ_VN.name
  address_prefix       = cidrsubnet(var.vnet_cidr, 8, index(tolist(var.subnet_list), each.value) + 1)
  service_endpoints = local.svcEndpoints[each.value]
  delegation {
    name = "serverFarms"

    service_delegation {
      name    = "Microsoft.Web/serverFarms"
    }
  }
}
#another way to loop create subnets

# resource "azurerm_subnet" "nbos_az_subnet" {
#     count = 4
#     resource_group_name = azurerm_resource_group.NBOS_AZ_RG.name
#     virtual_network_name = azurerm_virtual_network.NBOS_AZ_VN.name
#     address_prefix = cidrsubnet(var.vnet_cidr, 8, count.index)
#    name           = "subnet${count.index + 1}"
#   }
