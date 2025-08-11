variable "location" {
  description = "Azure region where resources will be deployed."
  type        = string
  default     = "West Europe"
}

variable "cch_project_name" {
  description = "CCH Project name for resource naming."
  type        = string
}

variable "location_code" {
  description = "Two-letter code for Azure location (e.g., ne for North Europe, we for West Europe)."
  type        = string
}

variable "environment" {
  description = "Environment for resource naming (dev, prd, qlty, tst, sbx, stg, shd)."
  type        = string
  validation {
    condition     = contains(["dev", "prd", "qlty", "tst", "sbx", "stg", "shd"], var.environment)
    error_message = "Invalid environment. Must be one of dev, prd, qlty, tst, sbx, stg, shd."
  }
}

variable "instance_number" {
  description = "Custom instance number from 001 to 007."
  type        = string
  validation {
    condition     = can(regex("^00[1-7]$", var.instance_number))
    error_message = "Invalid instance number. Must be a string from 001 to 007."
  }
}


variable "subscription_id" {
  description = "Azure subscription ID."
  type        = string
}