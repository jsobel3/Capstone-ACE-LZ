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
  name     = "NBOS_AZ_RG${var.az_suffix}" #to do, remove suffix after recreate
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
  name                = "NBOS-VN-network${var.az_suffix}" #to do, remove suffix after recreate
  resource_group_name = azurerm_resource_group.NBOS_AZ_RG.name
  location            = azurerm_resource_group.NBOS_AZ_RG.location
  address_space       = ["10.0.0.0/16"]


  subnet {
    #Subnet connected to: CosmosDB
    name                = "subnet1"
    address_prefix      = "10.0.1.0/24"

  }

  subnet {
        #Subnet connected to:SqlServer/DB/SA
    name                = "subnet2"
    address_prefix      = "10.0.2.0/24"
  }

  subnet {
        #Subnet connected to:App-Service
    name                = "subnet3"
    address_prefix      = "10.0.3.0/24"
  }

  subnet {
        #Subnet connected to:Function App
    name                = "subnet4"
    address_prefix      = "10.0.4.0/24"
  }

  /*
  for NBOS_AZ_RG_jss{
       zipmap(Subnets["name", "address_prefix"], ["subnet$(var.subnet_count)", "10.0.$(var.subnet_count).0/24"])
        {
          
        }
  }
  */

  tags = {
    environment = "dev"
    costcenter  = "it"
  }
}