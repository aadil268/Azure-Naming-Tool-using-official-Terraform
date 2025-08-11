terraform {
  ##---------------------------------------------------------------------
  ## Terraform and provider version constraints
  ##
  ## Pinning the Terraform version helps guarantee consistent behaviour
  ## across environments.  Likewise, pinning the provider prevents
  ## un‑intentional upgrades that could introduce breaking changes.
  required_version = ">= 1.5.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.99"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.3.2"
    }
  }
}

provider "azurerm" {
  features {}
}