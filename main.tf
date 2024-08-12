# Using Azurerm as my provider for this project 

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.115.0"  # or the latest version you prefer
    }
  }

  required_version = ">= 1.0.0"
}

provider "azurerm" {
  features {}
}

# Creating a Resource Group
resource "azurerm_resource_group" "rg" {
  name     = "rg-secure-healthcare"
  location = "East US"
}

# Creating a Virtual Network
resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-secure-healthcare"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = ["10.0.0.0/16"]
}

# Creating a Subnet
resource "azurerm_subnet" "subnet" {
  name                 = "subnet-secure-healthcare"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Defining a NIC so the VM can connect to the VNet
resource "azurerm_network_interface" "nic" {
  name                = "nic-secure-healthcare"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

# Creating a Virtual Machine 
resource "azurerm_virtual_machine" "vm" {
  name                  = "vm-secure-healthcare"
  location              = azurerm_resource_group.rg.location
  resource_group_name   = azurerm_resource_group.rg.name
  network_interface_ids = [azurerm_network_interface.nic.id]
  vm_size               = "Standard_DS1_v2"

  # Creating an OS disk
  storage_os_disk {
    name              = "osdisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  # Using Ubuntu Server
  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  os_profile {
    computer_name  = "FloridaBlue"
    admin_username = "Davidof-t"
    admin_password = "JobHunt@2023"
  }

  # Enhancing security by turning off SSH
  os_profile_linux_config {
    disable_password_authentication = false
  }
}

