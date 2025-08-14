/*
 * Input variables for the Azure Naming tool example.
 *
 * The variables defined here allow this module to be reused across
 * different deployments.  They capture environment specific inputs
 * (such as the Azure region and naming suffix) as well as core
 * information about the workload and business unit.  These values
 * are combined with the official Azure naming module to produce
 * consistent resource names.
 */

variable "environment" {
  type        = string
  description = "The environment for the deployment (e.g. dev, test, prod)."
}

variable "location" {
  type        = string
  description = "Azure region where resources will be deployed (e.g. eastus, westus)."
}

variable "project_name" {
  type        = string
  description = "Name of the CCH project or application.  This value appears in the resource name (e.g. 'sirvis' in app-sirvis-ne-dev-001)."
}

variable "instance_number" {
  type        = number
  description = "Instance number used to differentiate resources.  Values between 1 and 7 are supported and will be zero‑padded to three digits (e.g. 001, 002)."
  default     = 1
}

/*
 * Override for the two‑letter location code.  When empty the
 * configuration will attempt to infer the code from the full Azure
 * region name using a built‑in map (see main.tf).  Use this when you
 * deploy to a region not covered by the map or when you prefer
 * different abbreviations.  Examples: 'ne' for North Europe,
 * 'we' for West Europe.
 */
variable "location_code_override" {
  type        = string
  description = "Two‑letter abbreviation of the Azure region (e.g. 'ne', 'we').  Leave empty to infer from the region name."
  default     = ""
}

/*
 * A map of environment definitions used to demonstrate reusing the naming
 * convention across multiple deployments.  Keys correspond to the
 * environment names and each value contains the region and suffix
 * components used for naming.  Feel free to override this map in
 * terraform.tfvars to reflect your own environments.
 */
variable "environments" {
  type = map(object({
    location = string
    suffix   = list(string)
  }))
  description = <<EOT
Map of environment definitions for the multi‑deployment scenario.  Each key
represents an environment (dev, prd, qlty, tst, sbx, stg, shd, etc.) and
the value contains the Azure region and a list of suffix components.

The suffix list must include the location code, environment code and
instance number, because the naming module will prepend the resource
type abbreviation automatically.  The project name from
`var.project_name` is prepended to this list in main.tf.

For example, a storage account in the `dev` environment located in
North Europe with instance number 001 should have the suffix list
`["ne", "dev", "001"]`.  When combined with the project name `sirvis`
and the resource slug `app`, the generated name becomes
`app-sirvis-ne-dev-001`.
EOT

  # Provide example environments as defaults.  Override this map in
  # terraform.tfvars when you have different regions or instance
  # numbers.
  default = {
    dev = {
      location = "northeurope"
      suffix   = ["ne", "dev", "001"]
    }
    prd = {
      location = "westeurope"
      suffix   = ["we", "prd", "001"]
    }
  }
}