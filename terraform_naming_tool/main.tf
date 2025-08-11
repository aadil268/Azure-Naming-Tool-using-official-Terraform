/*
 * Example implementation of the Azure Naming tool using the official
 * Terraform module (Azure/naming/azurerm).  This configuration
 * demonstrates two scenarios:
 *
 *   1. Generating compliant names for new resources using the naming
 *      module.  A single environment is defined via input variables and
 *      names are composed from the business unit, workload, environment
 *      and instance identifier.
 *
 *   2. Reusing the same naming convention across multiple
 *      deployments.  A map of environments is defined in variables.tf
 *      and the module is invoked once per environment using `for_each`.
 */

######################################################################
## Scenario 1: Generate compliant names for new resources
######################################################################

locals {
  /*
   * Map of full Azure region names (without spaces) to two‑letter
   * abbreviations.  Extend this map as needed.  When a region is
   * not found, the first two characters of the lower‑cased region
   * name are used as a fallback.
   */
  location_code_map = {
    northeurope = "ne"
    westeurope  = "we"
  }

  # Lowercase the location and strip hyphens to match keys in the map
  region_lower = replace(lower(var.location), "-", "")

  # Determine the location code: use the override if provided,
  # otherwise look up the region in the map, and fall back to the
  # first two characters of the region name.
  location_code = var.location_code_override != "" ? var.location_code_override : (
    contains(keys(local.location_code_map), local.region_lower) ? local.location_code_map[local.region_lower] : substr(local.region_lower, 0, 2)
  )

  # Pad the instance number to three digits (e.g. 1 -> 001).
  instance_padded = format("%03d", var.instance_number)

  # Compose the list of suffix components following the pattern:
  #   <project_name>-<location_code>-<environment>-<instance_number>
  # The naming module automatically prepends the resource type
  # abbreviation (e.g. rg, vnet, vm).
  suffixes = [
    var.project_name,
    local.location_code,
    var.environment,
    local.instance_padded
  ]
}

module "naming" {
  # Use the Azure verified module to generate resource names
  source  = "Azure/naming/azurerm"
  version = "0.4.2"  # specify a version for repeatable builds

  # It is recommended to use suffixes rather than prefixes per
  # Microsoft guidance.  The suffixes defined above follow the
  # convention: <project>-<location code>-<environment>-<instance>.
  suffix = local.suffixes
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

######################################################################
## Scenario 2: Reuse naming convention across multiple deployments
######################################################################

# This section demonstrates how to apply the same naming convention
# across several environments (dev/test/prod) using a map of values
# defined in variables.tf.  Each environment gets its own instance
# of the naming module, ensuring that names remain consistent
# between runs while avoiding conflicts.  The resources created here
# are minimal examples; extend them as needed for your workloads.

module "naming_multi" {
  for_each = var.environments

  source  = "Azure/naming/azurerm"
  version = "0.4.2"

  # Prepend the project name to the environment‑specific suffix list.
  # Each suffix list must contain the location code, environment
  # code and instance number (e.g. ["ne", "dev", "001"]).
  suffix = concat([var.project_name], each.value.suffix)
}

resource "azurerm_resource_group" "multi_rg" {
  for_each = var.environments

  name     = module.naming_multi[each.key].resource_group.name
  location = each.value.location
}

# Example storage accounts for each environment with unique names.  Using
# name_unique avoids collisions between environments because the
# module appends a random string【732611034378564†L75-L86】.
resource "azurerm_storage_account" "multi_storage" {
  for_each = var.environments

  name                     = module.naming_multi[each.key].storage_account.name_unique
  resource_group_name      = azurerm_resource_group.multi_rg[each.key].name
  location                 = azurerm_resource_group.multi_rg[each.key].location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}