# These are the lab specs:
# Free SQL Server License: SQL 2019 Developer on Windows Server 2022.
# Subscription: <Your subscription>
# Resource group: <Your resource group>
# virtual machine name: azureSQLServerVM
# Region: <your local region, same as the selected region for your resource group>
# Availability Options: No infrastructure redundancy required
# Image: Free SQL Server License: SQL 2019 Developer on Windows Server 2022 - Gen1
# Azure spot instance: No (unchecked)
# Size: Standard D2s_v3 (2 vCPUs, 8 GiB memory). You may need to select the "See all sizes" link to see this option)
# Administrator account username: sqladmin (or whatever you want)
# Administrator account password: pwd!DP300lab01 (or your own password that meets the criteria)
# Select inbound ports: RDP (3389)
# Would you like to use an existing Windows Server license?: No (unchecked)
#

provider "azurerm" {
  features {}
}

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.0.0"
    }
  }
}

resource "azurerm_resource_group" "RG1" {
  name     = "RG1"
  location = "eastus2"
}

resource "azurerm_virtual_network" "VNET1" {
  name                = "VNET1"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.RG1.location
  resource_group_name = azurerm_resource_group.RG1.name
}

resource "azurerm_subnet" "SNET1" {
  name                 = "SNET1"
  resource_group_name  = azurerm_resource_group.RG1.name
  virtual_network_name = azurerm_virtual_network.VNET1.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_network_interface" "azureSQLServerVM-NIC" {
  name                = "azureSQLServerVM-NIC"
  location            = azurerm_resource_group.RG1.location
  resource_group_name = azurerm_resource_group.RG1.name

  ip_configuration {
    name                          = "azureSQLServerVM-IP"
    subnet_id                     = azurerm_subnet.SNET1.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_windows_virtual_machine" "azureSQLServerVM" {
  name                = "azureSQLServerVM"
  resource_group_name = azurerm_resource_group.RG1.name
  location            = azurerm_resource_group.eastus2.location
  size                = "Standard_D4_v4"
  admin_username      = "adminuser"
  admin_password      = "P@$$w0rd1234!"
  network_interface_ids = [
    azurerm_network_interface.azureSQLServerVM-NIC.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }
}

resource "azurerm_mssql_virtual_machine" "azureSQLServerVM" {
  virtual_machine_id               = data.azurerm_virtual_machine.azureSQLServerVM.id
  sql_license_type                 = "Free"
  r_services_enabled               = true
  sql_connectivity_port            = 1433
  sql_connectivity_type            = "PRIVATE"
  sql_connectivity_update_password = "Password1234!"
  sql_connectivity_update_username = "sqllogin"

  auto_patching {
    day_of_week                            = "Sunday"
    maintenance_window_duration_in_minutes = 60
    maintenance_window_starting_hour       = 2
  }
}


