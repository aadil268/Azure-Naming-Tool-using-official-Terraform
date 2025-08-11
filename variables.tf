variable "environment_suffix" {
  description = "Suffix for resource names, e.g., 'dev', 'test', 'prod'."
  type        = list(string)
}

variable "location" {
  description = "Azure region where resources will be deployed."
  type        = string
  default     = "West Europe"
}

variable "subscription_id" {
  description = "Azure subscription ID where resources will be deployed."
  type        = string
}