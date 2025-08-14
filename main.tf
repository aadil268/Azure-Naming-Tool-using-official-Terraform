module "naming" {
  source  = "Azure/naming/azurerm"
  version = "0.4.2"

  # Custom naming convention: Resource Type - CCH Project name - Locations - Environments - Custom Instance number
  # The module automatically handles the resource type prefix (e.g., rg, vm, st)
  suffix = [var.cch_project_name, var.location_code, var.environment, var.instance_number]
}

resource "azurerm_resource_group" "rg" {
  name     = module.naming.resource_group.name
  location = var.location
}

resource "azurerm_storage_account" "storage" {
  name                      = module.naming.storage_account.name_unique
  resource_group_name       = azurerm_resource_group.rg.name
  location                  = azurerm_resource_group.rg.location
  account_tier              = "Standard"
  account_replication_type  = "LRS"
  # Additional configuration such as network rules, tags or encryption can
  # be specified here.  They are omitted for brevity.
}

resource "azurerm_virtual_network" "vnet" {
  name                = module.naming.virtual_network.name
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  address_space       = ["10.1.0.0/16"]
}

resource "azurerm_subnet" "subnet" {
  name                 = module.naming.subnet.name
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.1.1.0/24"]
}