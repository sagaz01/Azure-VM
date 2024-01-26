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

resource "azurerm_resource_group" "RG1" {
  name     = "RG1"
  location = "Brazil South"
}

resource "azurerm_virtual_network" "VNET1" {
  name                = "VNET1"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.RG1.brazilsouth
  resource_group_name = azurerm_resource_group.RG1.name
}

resource "azurerm_subnet" "SNET1" {
  name                 = "SNET1"
  resource_group_name  = azurerm_resource_group.RG1.name
  virtual_network_name = azurerm_virtual_network.VNET1.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_network_interface" "DC1-NIC" {
  name                = "DC1-NIC"
  location            = azurerm_resource_group.brazilsouth.location
  resource_group_name = azurerm_resource_group.RG1.name

  ip_configuration {
    name                          = "DC1-IP"
    subnet_id                     = azurerm_subnet.SNET1.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_windows_virtual_machine" "DC1" {
  name                = "DC1"
  resource_group_name = azurerm_resource_group.RG1.name
  location            = azurerm_resource_group.brazilsouth.location
  size                = "Standard_D4_v4"
  admin_username      = "adminuser"
  admin_password      = "P@$$w0rd1234!"
  network_interface_ids = [
    azurerm_network_interface.DC1-NIC.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }
}