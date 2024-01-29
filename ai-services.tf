terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.0.0"
    }
  }
}


provider "azurerm" {
  features {}
}

# Resource Group
resource "azurerm_resource_group" "RG2" {
  name     = "RG2"
  location = "East US" # Latest version on specific locations only.
}

# Multi services AI account
resource "azurerm_cognitive_account" "ai-sagazz" {
  name                = "ai-sagazz"
  location            = azurerm_resource_group.RG2.location
  resource_group_name = azurerm_resource_group.RG2.name
  kind                = "CognitiveServices"

  sku_name = "S0"
}

# Create a virtual network within the resource group
#resource "azurerm_virtual_network" "example" {
#  name                = "example-network"
#  resource_group_name = azurerm_resource_group.example.name
#  location            = azurerm_resource_group.example.location
#  address_space       = ["10.0.0.0/16"]
#}