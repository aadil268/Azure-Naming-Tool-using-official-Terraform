module "naming" {
  source  = "Azure/naming/azurerm"
  version = "0.4.2"

  # Example usage for a resource group name
  suffix = var.environment_suffix
}

# Example resource group definition using the naming module
resource "azurerm_resource_group" "example" {
  name     = module.naming.resource_group.name
  location = var.location
}

