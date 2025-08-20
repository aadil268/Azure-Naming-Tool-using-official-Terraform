output "resource_group_name" {
  description = "The generated name for the resource group."
  value       = module.naming.resource_group.name
}

output "storage_account_name" {
  description = "The generated name for a storage account."
  value       = module.naming.storage_account.name
}

output "virtual_network_name" {
  description = "The generated name for a virtual network."
  value       = module.naming.virtual_network.name
}