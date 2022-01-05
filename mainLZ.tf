#main.tf 
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "2.90.0"
    }
  }
}

provider "azurerm" {
  features {
  }
  # Configuration options */
}
# Create a resource group
resource "azurerm_resource_group" "NBOS_AZ_RG" {
  name     = "NBOS_AZ_RG${var.az_prefix}"
  location = "eastus2"
}

# Create a virtual network within the resource group
resource "azurerm_virtual_network" "NBOS_AZ_VN" {
  name                = "example-network${var.az_prefix}"
  resource_group_name = azurerm_resource_group.NBOS_AZ_RG.name
  location            = azurerm_resource_group.NBOS_AZ_RG.location
  address_space       = ["10.0.0.0/16"]
}