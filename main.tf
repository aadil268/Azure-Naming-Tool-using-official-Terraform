module "naming" {
  source  = "Azure/naming/azurerm"
  version = "0.4.2"

  # Custom naming convention: Resource Type - CCH Project name - Locations - Environments - Custom Instance number
  # The module automatically handles the resource type prefix (e.g., rg, vm, st)
  suffix = [var.cch_project_name, var.location_code, var.environment, var.instance_number]
}

resource "azurerm_resource_group" "example" {
  name     = module.naming.resource_group.name
  location = var.location
}


