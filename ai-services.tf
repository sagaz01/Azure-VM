terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.0.0"
    }
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  skip_provider_registration = true # This is only required when the User, Service Principal, or Identity running Terraform lacks the permissions to register Azure Resource Providers.
  features {}
}

# Create a resource group
resource "azurerm_resource_group" "RG1" {
  name     = "RG1"
  location = "Brazil South"
}

resource "azurerm_cognitive_account" "ai-sagazz" {
  name                = "ai-sagazz"
  location            = azurerm_resource_group.RG1.location
  resource_group_name = azurerm_resource_group.RG1.name
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